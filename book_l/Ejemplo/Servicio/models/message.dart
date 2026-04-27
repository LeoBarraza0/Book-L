// Modelo de mensajes privados
class Message {
  int id;
  int de; // Usuario que envía
  int para; // Usuario que recibe
  String contenido;
  bool leido; // Estado del mensaje

  Message({
    required this.id,
    required this.de,
    required this.para,
    required this.contenido,
    required this.leido,
  });
}
