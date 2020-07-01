import 'package:uri_typed_template/uri_typed_template.dart';
import 'package:test/test.dart';

void main() {
  group('Build an uri', () {
    UriTemplate template;

    setUp(() {
      template = 'album' / 'id'.req<int>() / 'photos' &
          'theme'.opt<String>('dark') &
          'date'.opt<DateTime>();
    });

    test('Valid', () {
      final uri = template.build(
        {
          'id': 7,
          'theme': 'light',
        },
      );
      expect('album/7/photos?theme=light' == uri, isTrue);
    });
  });
}
