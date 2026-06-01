import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  final libDir = Directory('lib');
  final allFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
  
  // Build an index of filename -> absolute file path
  final Map<String, List<String>> fileIndex = {};
  for (var file in allFiles) {
    final name = p.basename(file.path);
    if (!fileIndex.containsKey(name)) {
      fileIndex[name] = [];
    }
    fileIndex[name]!.add(file.path);
  }

  int fixedCount = 0;

  for (var file in allFiles) {
    String content = await file.readAsString();
    bool changed = false;

    // We will look for imports using a regex
    final importRegex = RegExp(r"import\s+['""]([^'""]+)['""]");
    
    String newContent = content.replaceAllMapped(importRegex, (match) {
      final importPath = match.group(1)!;
      
      // Ignore dart: and package: imports
      if (importPath.startsWith('dart:') || importPath.startsWith('package:')) {
        return match.group(0)!;
      }
      
      // Resolve the relative path
      final currentDir = file.parent.path;
      final resolvedPath = p.normalize(p.join(currentDir, importPath));
      
      // Check if it exists
      if (!File(resolvedPath).existsSync()) {
        // The import is broken! Let's find the target file.
        final targetName = p.basename(importPath);
        
        if (fileIndex.containsKey(targetName)) {
          final candidates = fileIndex[targetName]!;
          if (candidates.length == 1) {
            // Exactly one match, we can safely replace it with a package import
            // Compute the package path
            // e.g. lib/features/auth/domain/models/usuario.dart -> package:book_l/features/auth/domain/models/usuario.dart
            final relativeToLib = p.relative(candidates.first, from: 'lib');
            final packageImport = 'package:book_l/${relativeToLib.replaceAll(r"\", "/")}';
            changed = true;
            print('Fixed in ${file.path}: $importPath -> $packageImport');
            return "import '$packageImport'";
          } else {
            // Multiple candidates, we must use heuristics.
            // Let's pick the candidate that has the most path segments in common with the original broken import's expected path
            // Or just print a warning for manual fixing.
            String bestCandidate = candidates.first;
            int bestScore = -1;
            
            for (var candidate in candidates) {
              // naive heuristic: count matching folders from the end
              final candidateSegments = p.split(candidate).reversed.toList();
              final importSegments = p.split(importPath).reversed.toList();
              int score = 0;
              for (int i = 0; i < candidateSegments.length && i < importSegments.length; i++) {
                // Ignore .. and .
                if (importSegments[i] == '..' || importSegments[i] == '.') continue;
                if (candidateSegments[i] == importSegments[i]) score++;
              }
              if (score > bestScore) {
                bestScore = score;
                bestCandidate = candidate;
              }
            }
            
            final relativeToLib = p.relative(bestCandidate, from: 'lib');
            final packageImport = 'package:book_l/${relativeToLib.replaceAll(r"\", "/")}';
            changed = true;
            print('Fixed (heuristic) in ${file.path}: $importPath -> $packageImport');
            return "import '$packageImport'";
          }
        } else {
          print('WARNING: Could not find any file named $targetName for import in ${file.path}');
        }
      }
      
      return match.group(0)!;
    });

    if (changed) {
      await file.writeAsString(newContent);
      fixedCount++;
    }
  }
  
  print('Total files fixed: $fixedCount');
}
