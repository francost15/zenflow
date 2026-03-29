import 'package:app/tool/quality/repo_structure_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('handwritten dart files stay below the size threshold', () {
    final oversizedFiles = findOversizedHandwrittenDartFiles();

    expect(
      oversizedFiles,
      isEmpty,
      reason:
          'Files over $maxHandwrittenLinesPerFile lines:\n'
          '${oversizedFiles.join('\n')}',
    );
  });

  test('app and test code avoid relative imports and exports', () {
    final offendingDirectives = findRelativeImportExportDirectives();

    expect(
      offendingDirectives,
      isEmpty,
      reason:
          'Relative import/export directives found:\n'
          '${offendingDirectives.join('\n')}',
    );
  });
}
