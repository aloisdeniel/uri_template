import '../uri_template.dart';

DynamicSegment<T> req<T>(String name) => DynamicSegment<T>(name);

QueryParameter<T> opt<T>(String name, [T defaultValue]) => QueryParameter<T>(
      name,
      defaultValue: defaultValue,
    );
