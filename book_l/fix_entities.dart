import 'dart:io';

void main() async {
  final dir = Directory('lib/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    String content = await file.readAsString();
    bool changed = false;
    
    if (content.contains('../repositories/')) {
      // In application/usecases, ../repositories/ should become ../ports/out/
      content = content.replaceAll('../repositories/', '../ports/out/');
      changed = true;
    }

    if (changed) {
      await file.writeAsString(content);
      print('Fixed ${file.path}');
    }
  }
}
