import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final dir = Directory.current
      .listSync()
      .firstWhereOrNull((e) => e.path.endsWith('assets')) as Directory;
  final dest = Directory('${dir.path}/data/images');
  final files = Directory('${dir.path}/images')
      .listSync(recursive: true)
      .whereType<File>()
      .where((e) => e.path.endsWith('.webp'))
      .toList(growable: false);
  for (final file in files) {
    final [..., id, name] = file.path
        .split('/')
        .expand<String>((e) => e.split(r'\'))
        .toList(growable: false);
    final newPath = '${dest.path}/product-$id-$name';
    file.copySync(newPath);
    print('Copied $name'); // ignore: avoid_print
  }
}
