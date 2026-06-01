import 'dart:io';

void main() async {
  final dir = Directory('lib/features/ejercicio');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  for (var file in files) {
    String content = await file.readAsString();
    if (content.contains('package:book_l/features/busqueda/infrastructure/adapters/in/presentation/screens/resultado_screen.dart')) {
      final newContent = content.replaceAll(
        'package:book_l/features/busqueda/infrastructure/adapters/in/presentation/screens/resultado_screen.dart',
        'package:book_l/features/calificacion/infrastructure/adapters/in/presentation/screens/resultado_screen.dart',
      );
      await file.writeAsString(newContent);
      print('Fixed ${file.path}');
    }
  }
  print('Done.');
}
