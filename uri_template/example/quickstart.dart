import 'package:uri_typed_template/uri_typed_template.dart';

void main() {
  final template =
      'album' / 'id'.req<int>() / 'photos' & 'theme'.opt<String>('dark');

  print('Templates: $template');

  final uri = template.build(
    {
      'id': 7,
      'theme': 'light',
    },
  );
  print('Uri: $uri');

  final match1 = template.match('album/7/photos?theme=light');
  print('Match "${match1.value}": ${match1.toString()}');

  final match2 = template.match('album/photos?theme=light');
  print('Match "${match2.value}": ${match2.toString()}');

  final match3 = template.match('album/true/photos?theme=light');
  print('Match "${match3.value}": ${match3.toString()}');
}
