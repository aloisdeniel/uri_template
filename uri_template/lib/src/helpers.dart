import '../uri_typed_template.dart';

extension ArgumentStringExtensions on String {
  DynamicSegment call(Type type) => DynamicSegment(this, type);

  QueryParameter<T> q<T>([T defaultValue]) => QueryParameter<T>(
        this,
        defaultValue: defaultValue,
      );
}
