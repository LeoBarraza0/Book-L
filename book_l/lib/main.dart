import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/bookl_service.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession().init();   // SharedPreferences — sesión del usuario
  await BooklService().init(); // JSON asset — datos de negocio en memoria
  runApp(const BookLApp());
}
