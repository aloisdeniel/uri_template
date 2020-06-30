import 'package:uri_template/src/serializers.dart';

import 'match.dart';

/// A template that can be used to build or match URI strings.
class UriTemplate {
  static const String defaultSeparator = '/';

  /// The serializer registry used to serializer arguments.
  final ArgumentSerializerRegistry argumentSerializerRegistry;

  /// The separator used between segments.
  final String separator;

  /// All the segments of the path.
  final List<Segment> segments;

  /// The optionnal query arguments.
  final List<QueryParameter> query;

  List<DynamicSegment> get requiredArguments =>
      segments.whereType<DynamicSegment>().toList();

  const UriTemplate({
    this.separator = defaultSeparator,
    this.segments = const <Segment>[],
    this.query = const <QueryParameter>[],
    this.argumentSerializerRegistry,
  });

  /// Build a URI string from the given [arguments].
  ///
  /// The [arguments] should contains all [requiredArguments] values, and may
  /// contain [query] parameters values.
  ///
  /// If [scheme] is provider, then it is appened at the beginning of the result.
  String build(
    Map<String, dynamic> arguments, {
    String scheme,
  }) {
    final serializers =
        argumentSerializerRegistry ?? ArgumentSerializerRegistry.instance;
    final buffer = StringBuffer();

    /// Leading scheme
    if (scheme != null) {
      buffer.write(scheme);
    }

    // Segments
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (i > 0) {
        buffer.write(separator);
      }
      if (segment is StaticSegment) {
        buffer.write(Uri.encodeComponent(segment.value));
      }
      if (segment is DynamicSegment) {
        final value = arguments[segment.name];
        assert(value != null, 'Argument ${segment.name} is required');
        assert(value.runtimeType == segment.valueType,
            'Required argument "${segment.name}" has invalid type ${value.runtimeType}, expected ${segment.valueType}');
        final serialized = serializers.serialize(value);
        buffer.write(Uri.encodeComponent(serialized));
      }
    }

    // Query
    for (var i = 0; i < query.length; i++) {
      final definition = query[i];
      final name = definition.name;
      final value = arguments[name];
      if (value != null) {
        assert(value.runtimeType == definition.valueType,
            'Optional argument "$name" has invalid type : ${value.runtimeType}, expected ${definition.valueType}');
        buffer.write(i == 0 ? '?' : '&');
        buffer.write(Uri.encodeComponent(name));
        buffer.write('=');
        final serialized = serializers.serialize(value);
        buffer.write(Uri.encodeComponent(serialized));
      }
    }

    return buffer.toString();
  }

  /// Parse a [value] and indicates whether it matches
  /// this template.
  UriMatch match(String value) {
    if (value == null || value.isEmpty) {
      if (segments.isEmpty) {
        return UriMatch.success(
          value: value,
          arguments: {},
        );
      }
      return UriMatch.failure(
        value: value,
        error: Exception('Different number of segments'),
      );
    }

    final arguments = <String, dynamic>{};
    final serializers =
        argumentSerializerRegistry ?? ArgumentSerializerRegistry.instance;
    final splits = value.split('?');
    final segmentSplits =
        splits.isEmpty ? [] : splits[0].split(RegExp(r'[/\\]'));

    // If not the same number of segments, then not match
    if (segmentSplits.length != segments.length) {
      return UriMatch.failure(
        value: value,
        error: Exception(
            'Different number of segments (expected ${segmentSplits.length}, actual ${segments.length}'),
      );
    }

    // Parsing each segment
    for (var i = 0; i < segments.length; i++) {
      final expectedSegment = segments[i];
      final actualSegment = Uri.decodeComponent(segmentSplits[i]);

      if (expectedSegment is StaticSegment &&
          expectedSegment.value != actualSegment) {
        return UriMatch.failure(
          value: value,
          error: Exception(
              'Expected segment $i "${expectedSegment.value}", actual "${actualSegment}"'),
        );
      } else if (expectedSegment is DynamicSegment) {
        try {
          final deserialized =
              serializers.deserialize(expectedSegment.valueType, actualSegment);
          arguments[expectedSegment.name] = deserialized;
        } catch (e) {
          return UriMatch.failure(
            value: value,
            error: SegmentParsingError(i, e),
          );
        }
      }
    }

    // Parsing query
    final querySplits = splits.length < 2 ? <String>[] : splits[1].split('&');
    for (var p in querySplits) {
      final argSplit = p.split('=');
      final name = argSplit.isNotEmpty ? Uri.decodeComponent(argSplit[0]) : '';
      final serialized =
          argSplit.length > 1 ? Uri.decodeComponent(argSplit[1]) : '';
      final parameter = query.firstWhere(
        (x) => x.name == name,
        orElse: () => null,
      );
      if (parameter != null) {
        try {
          final deserialized =
              serializers.deserialize(parameter.valueType, serialized);
          arguments[name] = deserialized;
        } catch (e) {
          return UriMatch.failure(
            value: value,
            error: QueryParsingError(name, e),
          );
        }
      }
    }

    return UriMatch.success(
      value: value,
      arguments: arguments,
    );
  }

  /// Append a query parameter.
  UriTemplate operator &(QueryParameter other) {
    return copyWith(query: [
      ...query,
      other,
    ]);
  }

  /// Append [other] elements to this template.
  ///
  /// It can be an [UriTemplate], a [Segment], or
  /// a [String].
  UriTemplate operator /(dynamic other) {
    if (other is UriTemplate) {
      return copyWith(segments: [
        ...segments,
        ...other.segments,
      ]);
    }

    if (other is Segment) {
      return copyWith(segments: [
        ...segments,
        other,
      ]);
    }

    if (other is String) {
      return copyWith(segments: [
        ...segments,
        StaticSegment(other),
      ]);
    }

    throw Error();
  }

  /// Create a new template and optionnaly overriding
  /// the given parameters.
  UriTemplate copyWith({
    String separator,
    List<Segment> segments,
    List<QueryParameter> query,
  }) =>
      UriTemplate(
        separator: separator ?? this.separator,
        query: query ?? this.query,
        segments: segments ?? this.segments,
      );
}

abstract class Segment {
  const Segment();

  UriTemplate operator /(dynamic other) {
    if (other is UriTemplate) {
      return UriTemplate(
          separator: other.separator,
          query: other.query,
          segments: [
            this,
            ...other.segments,
          ]);
    }

    if (other is Segment) {
      return UriTemplate(segments: [
        this,
        other,
      ]);
    }

    if (other is String) {
      return UriTemplate(segments: [
        this,
        StaticSegment(other),
      ]);
    }

    throw Error();
  }
}

class StaticSegment extends Segment {
  final String value;
  const StaticSegment(this.value);
}

class DynamicSegment<T> extends Segment {
  final String name;
  Type get valueType => T;
  const DynamicSegment(this.name);
}

extension UriTemplateStringExtensions on String {
  UriTemplate operator /(dynamic other) => StaticSegment(this) / other;
}

class QueryParameter<T> {
  final String name;
  final T defaultValue;
  Type get valueType => T;
  const QueryParameter(
    this.name, {
    this.defaultValue,
  });
}

class SegmentParsingError extends Error {
  final int segmentIndex;
  final Exception inner;
  SegmentParsingError(this.segmentIndex, this.inner);

  @override
  String toString() {
    return 'Failed to parse segment $segmentIndex : $inner';
  }
}

class QueryParsingError extends Error {
  final String name;
  final Exception inner;
  QueryParsingError(this.name, this.inner);

  @override
  String toString() {
    return 'Failed to parse query parameter $name : $inner';
  }
}
