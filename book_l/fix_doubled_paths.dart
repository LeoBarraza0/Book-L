import 'dart:io';

/// Fixes doubled paths like:
///   features/X/infrastructure/adapters/in/infrastructure/adapters/in/presentation/...
/// into:
///   features/X/infrastructure/adapters/in/presentation/...
void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  final doubledPattern = RegExp(r'infrastructure/adapters/(in|out)/infrastructure/adapters/(in|out)/');

  int fixedFiles = 0;
  int fixedImports = 0;

  for (var file in files) {
    String content = await file.readAsString();

    if (doubledPattern.hasMatch(content)) {
      // Replace: infrastructure/adapters/X/infrastructure/adapters/X/ -> infrastructure/adapters/X/
      final newContent = content.replaceAllMapped(doubledPattern, (m) {
        return 'infrastructure/adapters/${m.group(2)}/';
      });

      if (newContent != content) {
        await file.writeAsString(newContent);
        fixedFiles++;
        // Count how many replacements
        final orig = doubledPattern.allMatches(content).length;
        fixedImports += orig;
        print('Fixed $orig import(s) in ${file.path}');
      }
    }
  }

  print('\nTotal files fixed: $fixedFiles | Total imports fixed: $fixedImports');
}
