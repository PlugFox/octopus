// ignore_for_file: avoid_print

import 'dart:io' as io;

import 'package:path/path.dart' as p;

void main() {
  final current = io.Directory.current;

  // Move images
  final src = io.Directory(p.join(current.path, 'assets', 'data', 'images'));
  final dst =
      io.Directory(p.join(current.path, 'web', 'assets', 'data', 'images'))
        ..createSync(recursive: true);
  final files = src
      .listSync(recursive: false)
      .whereType<io.File>()
      .where((e) => e.path.endsWith('.webp'))
      .toList(growable: false);
  for (final file in files) {
    final newPath = p.join(dst.path, p.basename(file.path));
    file
      ..copySync(newPath)
      ..deleteSync();
    print('${file.path} -> $newPath');
  }

  // Change pubspec.yaml
  final pubspec = io.File(p.join(current.path, 'pubspec.yaml'));
  final content = pubspec
      .readAsStringSync()
      .replaceAll(RegExp(r'\s+\-\s*assets\/data\/images.*'), '');
  pubspec.writeAsStringSync(content);
}
