import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/discusion.dart';
import '../../domain/entities/comentario.dart';
import '../../data/repositories/discusion_repository_impl.dart';
import '../../../../core/storage/local_storage.dart';

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
  DiscusionController._internal();

  final _repo = DiscusionRepositoryImpl();
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

  void cargarDiscusion({int? idCurso, int? idLeccion}) {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    if (!_likesLoaded) {
      _likesLoaded = true;
      _loadLikes();
    }

    final discusion = _repo.obtenerOCrearDiscusion(
      idCurso: idCurso,
      idLeccion: idLeccion,
    );

    final raiz = _repo.getComentariosRaiz(discusion.idDiscusion);
    final respuestas = <int, List<Comentario>>{};

    for (final c in raiz) {
      respuestas[c.idComentario] = _repo.getRespuestas(c.idComentario);
    }

    _state = DiscusionState(
      discusion: discusion,
      comentariosRaiz: raiz,
      respuestasPorPadre: respuestas,
      isLoading: false,
    );
    notifyListeners();
  }

  void agregarComentario(String contenido) {
    final idDiscusion = _state.discusion?.idDiscusion;
    final idUsuario = AppSession().usuarioId;
    if (idDiscusion == null || idUsuario == null || contenido.trim().isEmpty) return;

    _repo.agregarComentario(
      idDiscusion: idDiscusion,
      idUsuario: idUsuario,
      contenido: contenido.trim(),
      idPadre: replyToId,
    );

    // Limpiar reply
    replyToId = null;
    replyToName = null;

    // Recargar
    cargarDiscusion(
      idCurso: _state.discusion?.idCursoFk,
      idLeccion: _state.discusion?.idLeccionFk,
    );
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
}
