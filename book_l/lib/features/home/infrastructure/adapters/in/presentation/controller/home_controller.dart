import 'package:flutter/material.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/home/infrastructure/adapters/out/repositories/home_repository_impl.dart';

class HomeController extends ChangeNotifier {
  static final HomeController _instance = HomeController._internal();
  factory HomeController() => _instance;
  HomeController._internal() {
    BooklService().addListener(notifyListeners);
  }

  final _repo = HomeRepositoryImpl();

  /// Obtiene los elementos mezclados (Cursos y Lecciones) para la vista principal
  List<dynamic> getForYouPageItems() {
    final lecciones = _repo.getLeccionesActivas();
    final cursos = _repo.getCursosPublicados();

    final mixedList = <dynamic>[];
    final maxLen =
        lecciones.length > cursos.length ? lecciones.length : cursos.length;

    // Mezclamos en una sola lista (intercalados para FYP)
    for (int i = 0; i < maxLen; i++) {
      if (i < cursos.length) {
        mixedList.add(cursos[i]);
      }
      if (i < lecciones.length) {
        mixedList.add(lecciones[i]);
      }
    }

    return mixedList;
  }

  /// Obtiene la racha de actividad del usuario
  Map<String, dynamic>? getRacha(int userId) {
    return _repo.getRacha(userId);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
