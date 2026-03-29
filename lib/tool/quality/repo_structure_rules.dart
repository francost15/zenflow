import 'dart:io';

const trackedSourceRoots = ['lib', 'test'];
const maxHandwrittenLinesPerFile = 250;

const _generatedSuffixes = [
  '.freezed.dart',
  '.g.dart',
  '.gen.dart',
  '.gr.dart',
  '.mocks.dart',
];

const _excludedPathFragments = [
  '/fixtures/',
  '/goldens/',
  '/snapshot/',
  '/snapshots/',
];

List<String> findOversizedHandwrittenDartFiles({
  List<String> roots = trackedSourceRoots,
  int maxLinesPerFile = maxHandwrittenLinesPerFile,
}) {
  final oversizedFiles = <String>[];

  for (final file in handwrittenDartFilesUnder(roots)) {
    final lineCount = file.readAsLinesSync().length;
    if (lineCount > maxLinesPerFile) {
      oversizedFiles.add('${file.path} ($lineCount lines)');
    }
  }

  return oversizedFiles;
}

List<String> findRelativeImportExportDirectives({
  List<String> roots = trackedSourceRoots,
}) {
  final offendingDirectives = <String>[];
  final directivePattern = RegExp(r"^(import|export)\s+'([^']+)';$");

  for (final file in handwrittenDartFilesUnder(roots)) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final match = directivePattern.firstMatch(lines[index].trim());
      if (match == null) {
        continue;
      }

      final uri = match.group(2)!;
      if (_isRelativeImportOrExport(uri)) {
        offendingDirectives.add('${file.path}:${index + 1} -> $uri');
      }
    }
  }

  return offendingDirectives;
}

Iterable<File> handwrittenDartFilesUnder(List<String> roots) sync* {
  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) {
      continue;
    }

    final files =
        directory
            .listSync(recursive: true)
            .whereType<File>()
            .where(_isTrackedHandwrittenDartFile)
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    yield* files;
  }
}

bool _isTrackedHandwrittenDartFile(File file) {
  final normalizedPath = file.path.replaceAll('\\', '/');

  return normalizedPath.endsWith('.dart') &&
      !_generatedSuffixes.any(normalizedPath.endsWith) &&
      !_excludedPathFragments.any(normalizedPath.contains);
}

bool _isRelativeImportOrExport(String uri) {
  return !uri.startsWith('dart:') && !uri.startsWith('package:');
}
