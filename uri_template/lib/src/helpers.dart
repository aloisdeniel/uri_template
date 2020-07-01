import '../uri_typed_template.dart';

extension ArgumentStringExtensions on String {
  dynamic call<T>([T value]) {
    if ((T == Type || T == dynamic) && value != null) {
      return DynamicSegment(this, value as Type);
    }

    return QueryParameter(
      this,
      T,
      defaultValue: value,
    );
  }
}
