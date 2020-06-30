class ArgumentSerializerRegistry {
  static final ArgumentSerializerRegistry instance =
      ArgumentSerializerRegistry();

  final Map<Type, ArgumentSerializer> serializers =
      <Type, ArgumentSerializer>{};

  ArgumentSerializerRegistry() {
    serializers[String] = const StringArgumentSerializer();
    serializers[int] = const IntArgumentSerializer();
    serializers[double] = const DoubleArgumentSerializer();
    serializers[bool] = const BoolArgumentSerializer();
  }

  void add<T>(ArgumentSerializer<T> serializer) {
    serializers[T] = serializer;
  }

  ArgumentSerializer getSerializer(Type type) {
    final result = serializers[type];
    assert(result != null, 'No serializer found for type $type');
    return result;
  }

  dynamic deserialize(Type type, String value) {
    final serializer = getSerializer(type);
    return serializer.deserialize(value);
  }

  String serialize(dynamic value) {
    if (value == null) {
      return null;
    }
    final serializer = getSerializer(value.runtimeType);
    return serializer.serialize(value);
  }
}

abstract class ArgumentSerializer<T> {
  const ArgumentSerializer();
  String serialize(T value);
  T deserialize(String value);
}

class StringArgumentSerializer extends ArgumentSerializer<String> {
  const StringArgumentSerializer();

  @override
  String deserialize(String value) => value;

  @override
  String serialize(String value) => value;
}

class IntArgumentSerializer extends ArgumentSerializer<int> {
  const IntArgumentSerializer();

  @override
  int deserialize(String value) => value == null ? null : int.parse(value);

  @override
  String serialize(int value) => value?.toString();
}

class DoubleArgumentSerializer extends ArgumentSerializer<double> {
  const DoubleArgumentSerializer();

  @override
  double deserialize(String value) =>
      value == null ? null : double.parse(value);

  @override
  String serialize(double value) => value?.toString();
}

class BoolArgumentSerializer extends ArgumentSerializer<bool> {
  const BoolArgumentSerializer();

  @override
  bool deserialize(String value) => value == null ? null : value == 'true';

  @override
  String serialize(bool value) =>
      value == null ? null : (value ? 'true' : 'false');
}
