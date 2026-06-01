// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_material del modelo relacional.
class MaterialEducativo {
  final int idMaterial;
  final int idLeccionFk;
  final String nombre;
  final String? url;
  final String? descripcion;
  final String tipo; // 'video' | 'pdf' | 'enlace' | 'SCORM'
  final int tamanoBytes;

  const MaterialEducativo({
    required this.idMaterial,
    required this.idLeccionFk,
    required this.nombre,
    this.url,
    this.descripcion,
    required this.tipo,
    required this.tamanoBytes,
  });

  MaterialEducativo copyWith({
    int? idMaterial,
    int? idLeccionFk,
    String? nombre,
    String? url,
    String? descripcion,
    String? tipo,
    int? tamanoBytes,
  }) {
    return MaterialEducativo(
      idMaterial: idMaterial ?? this.idMaterial,
      idLeccionFk: idLeccionFk ?? this.idLeccionFk,
      nombre: nombre ?? this.nombre,
      url: url ?? this.url,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
    );
  }
}
