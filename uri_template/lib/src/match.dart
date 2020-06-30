import 'package:meta/meta.dart';

class UriMatch {
  final String value;
  final bool isSuccess;
  final Map<String, dynamic> arguments;
  final dynamic error;
  const UriMatch.success({
    @required this.value,
    @required this.arguments,
  })  : isSuccess = true,
        error = null;

  const UriMatch.failure({
    @required this.error,
    @required this.value,
  })  : isSuccess = false,
        arguments = const <String, dynamic>{};

  @override
  String toString() {
    return 'UriMatch($isSuccess)' +
        (isSuccess ? arguments.toString() : '[$error]');
  }
}
