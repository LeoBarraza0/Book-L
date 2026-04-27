// Modelo que representa un Tweet
class Tweet {
  int id; // Identificador único del tweet
  int userId; // Usuario que creó el tweet
  String contenido; // Texto del tweet
  List<int> likes; // Lista de IDs de usuarios que dieron like

  Tweet({
    required this.id,
    required this.userId,
    required this.contenido,
    required this.likes,
  });
}
