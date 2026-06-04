import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_l/features/discusion/domain/models/discusion.dart';
import 'package:book_l/features/discusion/domain/models/comentario.dart';
import 'package:book_l/features/discusion/infrastructure/adapters/out/repositories/discusion_repository_impl.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/discusion/application/usecases/get_discusion_usecase.dart';
import 'package:book_l/features/discusion/application/usecases/agregar_comentario_usecase.dart';

class DiscusionState {
  final Discusion? discusion;
  final List<Comentario> comentariosRaiz;
  final Map<int, List<Comentario>> respuestasPorPadre;
  final bool isLoading;

  const DiscusionState({
    this.discusion,
    this.comentariosRaiz = const [],
    this.respuestasPorPadre = const {},
    this.isLoading = false,
  });

  DiscusionState copyWith({
    Discusion? discusion,
    List<Comentario>? comentariosRaiz,
    Map<int, List<Comentario>>? respuestasPorPadre,
    bool? isLoading,
  }) =>
      DiscusionState(
        discusion: discusion ?? this.discusion,
        comentariosRaiz: comentariosRaiz ?? this.comentariosRaiz,
        respuestasPorPadre: respuestasPorPadre ?? this.respuestasPorPadre,
        isLoading: isLoading ?? this.isLoading,
      );
}

class DiscusionController extends ChangeNotifier {
  static final DiscusionController _instance = DiscusionController._internal();
  factory DiscusionController() => _instance;

  final DiscusionRepositoryImpl _repo;
  final GetDiscusionUseCase _getDiscusionUseCase;
  final AgregarComentarioUseCase _agregarComentarioUseCase;

  DiscusionController._internal()
      : _repo = DiscusionRepositoryImpl(),
        _getDiscusionUseCase = GetDiscusionUseCase(DiscusionRepositoryImpl()),
        _agregarComentarioUseCase = AgregarComentarioUseCase(
          DiscusionRepositoryImpl(),
          GetDiscusionUseCase(DiscusionRepositoryImpl()),
        );

  DiscusionState _state = const DiscusionState();
  DiscusionState get state => _state;

  // ── Likes (complementario, sin tabla propia) ────────────────────────────
  /// IDs de comentarios que el usuario actual ya dio like
  final Set<int> _likedIds = {};

  /// Conteo de likes por comentario (id_comentario → count)
  final Map<int, int> _likeCounts = {};

  bool isLiked(int idComentario) => _likedIds.contains(idComentario);
  int likeCount(int idComentario) => _likeCounts[idComentario] ?? 0;

  Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = AppSession().usuarioId ?? 0;
    final key = 'liked_comments_user_$myId';
    final saved = prefs.getStringList(key) ?? [];
    _likedIds
      ..clear()
      ..addAll(saved.map(int.parse));
    // Inicializar conteos base desde comentarios mock
    for (final c in _repo.getAllComentarios()) {
      if (!_likeCounts.containsKey(c.idComentario)) {
        _likeCounts[c.idComentario] = 0;
      }
    }
    notifyListeners();
  }

  Future<void> _saveLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = AppSession().usuarioId ?? 0;
    await prefs.setStringList(
      'liked_comments_user_$myId',
      _likedIds.map((e) => e.toString()).toList(),
    );
  }

  void toggleLike(int idComentario) {
    if (_likedIds.contains(idComentario)) {
      _likedIds.remove(idComentario);
      _likeCounts[idComentario] = (_likeCounts[idComentario] ?? 1) - 1;
    } else {
      _likedIds.add(idComentario);
      _likeCounts[idComentario] = (_likeCounts[idComentario] ?? 0) + 1;
    }
    _saveLikes();
    notifyListeners();
  }

  // ID del comentario al que se está respondiendo (null = comentario raíz)
  int? replyToId;
  String? replyToName;

  bool _likesLoaded = false;

  Future<void> cargarDiscusion({int? idCurso, int? idLeccion}) async {
    // Si se cambia de lección/curso, limpiar estado anterior para no mostrar datos viejos
    final currentDisc = _state.discusion;
    final esMismDiscusion = (idCurso != null && currentDisc?.idCursoFk == idCurso) ||
        (idLeccion != null && currentDisc?.idLeccionFk == idLeccion);

    if (!esMismDiscusion) {
      _state = const DiscusionState(isLoading: true);
    } else {
      _state = _state.copyWith(isLoading: true);
    }
    notifyListeners();

    if (!_likesLoaded) {
      _likesLoaded = true;
      _loadLikes();
    }

    final discusion = await _getDiscusionUseCase(
      GetDiscusionParams(idCurso: idCurso, idLeccion: idLeccion),
    );

    final raiz = await _repo.getComentariosRaiz(discusion.idDiscusion);
    final respuestas = <int, List<Comentario>>{};

    for (final c in raiz) {
      respuestas[c.idComentario] = await _repo.getRespuestas(c.idComentario);
    }

    _state = DiscusionState(
      discusion: discusion,
      comentariosRaiz: raiz,
      respuestasPorPadre: respuestas,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<void> agregarComentario(String contenido) async {
    final idDiscusion = _state.discusion?.idDiscusion;
    final idUsuario = AppSession().usuarioId;
    if (idDiscusion == null || idUsuario == null || contenido.trim().isEmpty)
      return;

    final nuevoComentario = await _agregarComentarioUseCase(
      AgregarComentarioParams(
        idDiscusion: idDiscusion,
        idUsuario: idUsuario,
        contenido: contenido.trim(),
        idPadre: replyToId,
      ),
    );

    // ── Actualización optimista inmediata ──────────────────────────────────
    // Agregar el comentario al estado local SIN esperar otro roundtrip a Supabase
    if (replyToId == null) {
      // Es un comentario raíz
      final nuevaLista = [nuevoComentario, ..._state.comentariosRaiz];
      final nuevasRespuestas = Map<int, List<Comentario>>.from(_state.respuestasPorPadre);
      nuevasRespuestas[nuevoComentario.idComentario] = [];
      _state = _state.copyWith(
        comentariosRaiz: nuevaLista,
        respuestasPorPadre: nuevasRespuestas,
      );
    } else {
      // Es una respuesta a un comentario existente
      final nuevasRespuestas = Map<int, List<Comentario>>.from(_state.respuestasPorPadre);
      final existentes = nuevasRespuestas[replyToId] ?? [];
      nuevasRespuestas[replyToId!] = [...existentes, nuevoComentario];
      _state = _state.copyWith(respuestasPorPadre: nuevasRespuestas);
    }

    // Limpiar reply y notificar UI de inmediato
    replyToId = null;
    replyToName = null;
    notifyListeners();

    // ── Sincronización en background (actualiza IDs reales, timestamps, etc.) ─
    Future.microtask(() async {
      try {
        final raiz = await _repo.getComentariosRaiz(idDiscusion);
        final respuestas = <int, List<Comentario>>{};
        for (final c in raiz) {
          respuestas[c.idComentario] = await _repo.getRespuestas(c.idComentario);
        }
        _state = _state.copyWith(
          comentariosRaiz: raiz,
          respuestasPorPadre: respuestas,
        );
        notifyListeners();
      } catch (_) {
        // Si falla el refresh, el comentario optimista ya está visible
      }
    });
  }

  void setReplyTo(int idComentario, String nombreUsuario) {
    replyToId = idComentario;
    replyToName = nombreUsuario;
    notifyListeners();
  }

  void cancelReply() {
    replyToId = null;
    replyToName = null;
    notifyListeners();
  }

  /// Obtener usuario sincronamente
  dynamic getUserSync(int idUsuario) => _repo.getUserSync(idUsuario);
}
