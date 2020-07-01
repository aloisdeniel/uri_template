import '../uri_template.dart';

extension ArgumentStringExtensions on String {
  DynamicSegment<T> req<T>() => DynamicSegment<T>(this);

  QueryParameter<T> opt<T>([T defaultValue]) => QueryParameter<T>(
        this,
        defaultValue: defaultValue,
      );
}
