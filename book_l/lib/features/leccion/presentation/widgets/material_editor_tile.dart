import 'package:flutter/material.dart';
import '../../domain/entities/material_educativo.dart';

/// Tile reutilizable para mostrar un material educativo en modo edición.
/// Sigue la estética visual de los placeholders del leccion_detail_screen.
class MaterialEditorTile extends StatelessWidget {
  final MaterialEducativo material;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const MaterialEditorTile({
    super.key,
    required this.material,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForTipo(material.tipo);
    final icon = _iconForTipo(material.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Ícono circular con el color del tipo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          // Info del material
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        material.tipo.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatSize(material.tamanoBytes),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF676767),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón editar
          if (onEditar != null)
            GestureDetector(
              onTap: onEditar,
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 18, color: Color(0xFF676767)),
              ),
            ),
          // Botón eliminar
          if (onEliminar != null)
            GestureDetector(
              onTap: onEliminar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    size: 18, color: Color(0xFFD63030)),
              ),
            ),
        ],
      ),
    );
  }

  Color _colorForTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return const Color(0xFFFF606F);
      case 'pdf':
      case 'documento':
        return const Color(0xFF4DC130);
      case 'enlace':
        return const Color(0xFF4A90D9);
      default:
        return const Color(0xFF888888);
    }
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return Icons.play_circle_filled;
      case 'pdf':
      case 'documento':
        return Icons.picture_as_pdf;
      case 'enlace':
        return Icons.link_rounded;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return 'Enlace';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }
}
