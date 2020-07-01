class UriArgumentSerializers {
  static final UriArgumentSerializers instance = UriArgumentSerializers();

  final Map<Type, UriArgumentSerializer> serializers =
      <Type, UriArgumentSerializer>{};

  UriArgumentSerializers() {
    addSerializer<String>(const StringArgumentSerializer());
    addSerializer<int>(const IntArgumentSerializer());
    addSerializer<double>(const DoubleArgumentSerializer());
    addSerializer<bool>(const BoolArgumentSerializer());
  }

  void addSerializer<T>(UriArgumentSerializer<T> serializer) {
    assert(serializer != null);
    serializers[T] = serializer;
  }

  void add<T>(
    SerializeArgument<T> serialize,
    DeserializeArgument<T> deserialize,
  ) {
    addSerializer<T>(_ArgumentSerializer<T>(serialize, deserialize));
  }

  UriArgumentSerializer getSerializer(Type type) {
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

abstract class UriArgumentSerializer<T> {
  const UriArgumentSerializer();
  String serialize(T value);
  T deserialize(String value);
}

typedef SerializeArgument<T> = String Function(T value);
typedef DeserializeArgument<T> = T Function(String value);

class _ArgumentSerializer<T> extends UriArgumentSerializer<T> {
  final SerializeArgument<T> _serialize;
  final DeserializeArgument<T> _deserialize;
  const _ArgumentSerializer(this._serialize, this._deserialize)
      : assert(_serialize != null),
        assert(_deserialize != null);

  @override
  String serialize(T value) => _serialize(value);

  @override
  T deserialize(String value) => _deserialize(value);
}

class StringArgumentSerializer extends UriArgumentSerializer<String> {
  const StringArgumentSerializer();

  @override
  String deserialize(String value) => value;

  @override
  String serialize(String value) => value;
}

class IntArgumentSerializer extends UriArgumentSerializer<int> {
  const IntArgumentSerializer();

  @override
  int deserialize(String value) => value == null ? null : int.parse(value);

  @override
  String serialize(int value) => value?.toString();
}

class DoubleArgumentSerializer extends UriArgumentSerializer<double> {
  const DoubleArgumentSerializer();

  @override
  double deserialize(String value) =>
      value == null ? null : double.parse(value);

  @override
  String serialize(double value) => value?.toString();
}

class BoolArgumentSerializer extends UriArgumentSerializer<bool> {
  const BoolArgumentSerializer();

  @override
  bool deserialize(String value) => value == null ? null : value == 'true';

  @override
  String serialize(bool value) =>
      value == null ? null : (value ? 'true' : 'false');
}
