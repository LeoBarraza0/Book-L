import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found.');
    return;
  }

  // 1. Move folders in features
  final featuresDir = Directory('lib/features');
  if (featuresDir.existsSync()) {
    for (var entity in featuresDir.listSync()) {
      if (entity is Directory) {
        moveFeatureFolders(entity);
      }
    }
  }

  // 2. Move folders in core
  final coreDir = Directory('lib/core');
  if (coreDir.existsSync()) {
    moveCoreFolders(coreDir);
  }

  // 3. Update imports in all dart files
  await updateImports(libDir);
  
  print('Migration completed!');
}

void moveFeatureFolders(Directory featureDir) {
  final featurePath = featureDir.path;

  // mapping: old path relative to feature -> new path relative to feature
  final moves = {
    'domain/entities': 'domain/models',
    'domain/usecases': 'application/usecases',
    'domain/repositories': 'application/ports/out',
    'presentation': 'infrastructure/adapters/in/presentation',
    'data/dto': 'infrastructure/adapters/out/dtos',
    'data/repositories': 'infrastructure/adapters/out/repositories',
  };

  for (var entry in moves.entries) {
    final oldDir = Directory('$featurePath/${entry.key}');
    final newDir = Directory('$featurePath/${entry.value}');

    if (oldDir.existsSync()) {
      if (!newDir.parent.existsSync()) {
        newDir.parent.createSync(recursive: true);
      }
      oldDir.renameSync(newDir.path);
    }
  }

  // Cleanup old empty directories
  final dataDir = Directory('$featurePath/data');
  if (dataDir.existsSync() && dataDir.listSync().isEmpty) {
    dataDir.deleteSync();
  }
}

void moveCoreFolders(Directory coreDir) {
  final corePath = coreDir.path;

  final moves = {
    'network': 'infrastructure/network',
    'services': 'infrastructure/services',
    'storage': 'infrastructure/storage',
  };

  for (var entry in moves.entries) {
    final oldDir = Directory('$corePath/${entry.key}');
    final newDir = Directory('$corePath/${entry.value}');

    if (oldDir.existsSync()) {
      if (!newDir.parent.existsSync()) {
        newDir.parent.createSync(recursive: true);
      }
      oldDir.renameSync(newDir.path);
    }
  }
}

Future<void> updateImports(Directory dir) async {
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    String content = await file.readAsString();
    String originalContent = content;

    // Apply replacements
    content = content.replaceAll(RegExp(r'/domain/entities/'), '/domain/models/');
    content = content.replaceAll(RegExp(r'/domain/usecases/'), '/application/usecases/');
    content = content.replaceAll(RegExp(r'/domain/repositories/'), '/application/ports/out/');
    content = content.replaceAll(RegExp(r'/data/dto/'), '/infrastructure/adapters/out/dtos/');
    content = content.replaceAll(RegExp(r'/data/repositories/'), '/infrastructure/adapters/out/repositories/');
    content = content.replaceAll(RegExp(r'/presentation/'), '/infrastructure/adapters/in/presentation/');
    
    // Core replacements
    content = content.replaceAll(RegExp(r'/core/network/'), '/core/infrastructure/network/');
    content = content.replaceAll(RegExp(r'/core/services/'), '/core/infrastructure/services/');
    content = content.replaceAll(RegExp(r'/core/storage/'), '/core/infrastructure/storage/');

    // Handle relative imports without leading slash that might just be the folder name
    // e.g. import 'presentation/screens/...' when currently in the feature root
    // But usually imports are either package:.../features/auth/presentation/... or ../../presentation/...
    // So the ones with slash will catch mostly everything. 
    // What if someone imported `import '../../domain/entities/usuario.dart'`? The slash prefix replacement catches it: `/domain/entities/` -> `/domain/models/`.
    
    // Let's also handle relative paths starting without a slash (e.g. from data/repositories to domain/repositories)
    // Wait, if a file in data/repositories does `import '../../domain/repositories/X.dart'`, it has `/domain/repositories/`. 
    // What if it's `import 'domain/repositories/X.dart'`? We should probably just replace the exact folder names where they appear as part of the path.
    
    // safer replacements for start of string or after a quote or after a slash
    final paths = {
      'domain/entities': 'domain/models',
      'domain/usecases': 'application/usecases',
      'domain/repositories': 'application/ports/out',
      'data/dto': 'infrastructure/adapters/out/dtos',
      'data/repositories': 'infrastructure/adapters/out/repositories',
      'presentation': 'infrastructure/adapters/in/presentation',
      'core/network': 'core/infrastructure/network',
      'core/services': 'core/infrastructure/services',
      'core/storage': 'core/infrastructure/storage',
    };

    for (var entry in paths.entries) {
      // Look for the exact folder path segment within an import string
      // Example: 'package:book_l/features/auth/domain/entities/usuario.dart'
      // Example: '../../domain/entities/usuario.dart'
      // Example: 'domain/entities/usuario.dart'
      content = content.replaceAll(
        RegExp('(?<=[\'\"/])' + entry.key + '(?=/)'), 
        entry.value
      );
    }

    if (content != originalContent) {
      await file.writeAsString(content);
    }
  }
}
