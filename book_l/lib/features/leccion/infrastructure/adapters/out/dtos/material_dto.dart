import 'package:book_l/features/leccion/domain/models/material_educativo.dart';

class MaterialDto {
  static MaterialEducativo fromJson(Map<String, dynamic> json) {
    return MaterialEducativo(
      idMaterial: (json['idmaterial'] ?? json['id_material']) as int,
      idLeccionFk: (json['idleccionfk'] ?? json['id_leccion_fk']) as int,
      nombre: json['nombre'] as String,
      url: json['url'] as String?,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String,
      tamanoBytes: json['tamano_bytes'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toJson(MaterialEducativo m) {
    return {
      'idmaterial': m.idMaterial,
      'idleccionfk': m.idLeccionFk,
      'nombre': m.nombre,
      'url': m.url,
      'descripcion': m.descripcion,
      'tipo': m.tipo,
      'tamano_bytes': m.tamanoBytes,
    };
  }
}
