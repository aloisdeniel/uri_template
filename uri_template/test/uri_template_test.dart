import 'package:uri_template/uri_template.dart';
import 'package:test/test.dart';

void main() {
  group('Build an uri', () {
    UriTemplate template;

    setUp(() {
      template =
          'album' / req<int>('id') / 'photos' & opt<String>('theme', 'dark');
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
