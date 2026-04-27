// Modelo de tendencias (#hashtags)
class Trend {
  int id;
  String hashtag;
  int cantidad; // Número de menciones

  Trend({
    required this.id,
    required this.hashtag,
    required this.cantidad,
  });
}
