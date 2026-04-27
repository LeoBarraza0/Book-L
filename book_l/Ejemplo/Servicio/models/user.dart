// Modelo que representa un Usuario
class User {
  int id; // ID del usuario
  String username; // Nombre de usuario
  String nombre; // Nombre completo
  String avatar; // URL de la imagen

  User({
    required this.id,
    required this.username,
    required this.nombre,
    required this.avatar,
  });
}
