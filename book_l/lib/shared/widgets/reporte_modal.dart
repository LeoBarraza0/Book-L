import 'package:flutter/material.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/services/bookl_service.dart';

/// Modal de reporte reutilizable para lecciones y cursos.
/// Se muestra como un bottom sheet con estilo Book-L.
///
/// [entidadTipo]: 'Lección' o 'Curso'
/// [entidadId]: ID de la lección o curso
/// [entidadNombre]: Nombre de la entidad para mostrar en el diálogo
class ReporteModal {
  static Future<bool?> show(
    BuildContext context, {
    required String entidadTipo,
    required int entidadId,
    required String entidadNombre,
  }) async {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReporteModalContent(
        entidadTipo: entidadTipo,
        entidadId: entidadId,
        entidadNombre: entidadNombre,
      ),
    );
  }
}

class _ReporteModalContent extends StatefulWidget {
  final String entidadTipo;
  final int entidadId;
  final String entidadNombre;

  const _ReporteModalContent({
    required this.entidadTipo,
    required this.entidadId,
    required this.entidadNombre,
  });

  @override
  State<_ReporteModalContent> createState() => _ReporteModalContentState();
}

class _ReporteModalContentState extends State<_ReporteModalContent> {
  final TextEditingController _motivoController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedMotivo;

  final List<String> _motivosPredefinidos = [
    'Contenido inapropiado',
    'Información incorrecta',
    'Material ofensivo',
    'Spam o publicidad',
    'Otro',
  ];

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _enviarReporte() async {
    final motivo = _selectedMotivo == 'Otro'
        ? _motivoController.text.trim()
        : _selectedMotivo ?? '';

    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Por favor indica el motivo del reporte.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFEB95C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final userId = AppSession().usuarioId;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para reportar.')),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    // Construir el motivo final (prefijo + comentario si es "Otro")
    final motivoFinal = _selectedMotivo == 'Otro'
        ? _motivoController.text.trim()
        : '$_selectedMotivo. ${_motivoController.text.trim()}'.trim();

    // Usar BooklService directamente a través del repository pattern
    BooklService().addReporte(
      idUsuarioFk: userId,
      entidadTipo: widget.entidadTipo,
      entidadId: widget.entidadId,
      motivo: motivoFinal.isNotEmpty ? motivoFinal : motivo,
    );

    // Pequeño delay para feedback visual
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9E1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle ──
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // ── Icono + Título ──
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF606F).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFFF606F),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reportar contenido',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.entidadNombre,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Motivos predefinidos ──
              const Text(
                '¿Por qué reportas este contenido?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _motivosPredefinidos.map((motivo) {
                  final isSelected = _selectedMotivo == motivo;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedMotivo = motivo;
                      if (motivo != 'Otro') {
                        _motivoController.clear();
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF606F)
                            : const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF606F).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        motivo,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── Campo de texto para comentario adicional ──
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMotivo == 'Otro'
                          ? 'Describe el motivo del reporte *'
                          : 'Comentario adicional (opcional)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _motivoController,
                        maxLines: 3,
                        maxLength: 300,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: _selectedMotivo == 'Otro'
                              ? 'Escribe aquí el motivo del reporte...'
                              : 'Agrega detalles adicionales...',
                          hintStyle: const TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          counterStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Botón Enviar ──
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _selectedMotivo == null)
                      ? null
                      : _enviarReporte,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF606F),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD9D9D9),
                    disabledForegroundColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFFFF606F).withOpacity(0.4),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Enviar Reporte',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Botón Cancelar ──
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
