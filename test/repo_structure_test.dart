import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('handwritten dart files stay below the size threshold', () {
    const maxLinesPerFile = 250;
    final oversizedFiles = <String>[];

    for (final file in _dartFilesUnder(const ['lib', 'test'])) {
      final lineCount = file.readAsLinesSync().length;
      if (lineCount > maxLinesPerFile) {
        oversizedFiles.add('${file.path} ($lineCount lines)');
      }
    }

    expect(
      oversizedFiles,
      isEmpty,
      reason: 'Files over $maxLinesPerFile lines:\n${oversizedFiles.join('\n')}',
    );
  });

  test('app and test code avoid relative imports and exports', () {
    final offendingDirectives = <String>[];
    final directivePattern = RegExp(r"^(import|export)\s+'([^']+)';$");

    for (final file in _dartFilesUnder(const ['lib', 'test'])) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        final match = directivePattern.firstMatch(lines[index].trim());
        if (match == null) {
          continue;
        }

        final uri = match.group(2)!;
        if (!uri.startsWith('dart:') && !uri.startsWith('package:')) {
          offendingDirectives.add('${file.path}:${index + 1} -> $uri');
        }
      }
    }

    expect(
      offendingDirectives,
      isEmpty,
      reason: 'Relative import/export directives found:\n'
          '${offendingDirectives.join('\n')}',
    );
  });
}

Iterable<File> _dartFilesUnder(List<String> roots) sync* {
  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) {
      continue;
    }

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        yield entity;
      }
    }
  }
}
