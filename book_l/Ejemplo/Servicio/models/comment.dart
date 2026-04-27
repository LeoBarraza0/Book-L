// Modelo de comentarios (aunque aún no lo mostramos en UI)
class Comment {
  int id;
  int tweetId; // A qué tweet pertenece
  int userId; // Quién comenta
  String contenido;

  Comment({
    required this.id,
    required this.tweetId,
    required this.userId,
    required this.contenido,
  });
}
