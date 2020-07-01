import 'package:uri_typed_template/uri_typed_template.dart';
import 'package:test/test.dart';

void main() {
  group('Build an uri', () {
    UriTemplate template;

    setUp(() {
      template = 'album' / 'id'(int) / 'photos' &
          'theme'.q<String>('dark') &
          'date'.q<DateTime>();
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
