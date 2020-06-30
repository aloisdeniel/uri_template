import 'package:uri_template/uri_template.dart';

void main() {
  final template =
      'album' / req<int>('id') / 'photos' & opt<String>('theme', 'dark');

  final uri = template.build(
    {
      'id': 7,
      'theme': 'light',
    },
  );
  print('Uri: $template');

  final match1 = template.match('album/7/photos?theme=light');
  print('Match "${match1.value}": ${match1.toString()}');

  final match2 = template.match('album/photos?theme=light');
  print('Match "${match2.value}": ${match2.toString()}');

  final match3 = template.match('album/true/photos?theme=light');
  print('Match "${match3.value}": ${match3.toString()}');
}
