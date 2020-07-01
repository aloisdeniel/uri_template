Build and parse URIs with simple declarations based on Dart extensions.

## Install

```yaml
# pubspec.yaml
dependencies:
  uri_template:
```

## Quickstart

```dart
final template =
    'album' / 'id'(int) / 'photos' & 'theme'.q<String>('dark');

final uri = template.build(
  {
    'id': 7,
    'theme': 'light',
  },
); // "album/7/photos?theme=light"

final match = template.match('album/7/photos?theme=light');
if(match.isSuccess) {
  int id = match['id']; // 7
  String theme = match['theme']; // "light"
}
```

## Roadmap

* Template equality & comparer