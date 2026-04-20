import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';

class SeccionData {
  final TextEditingController tituloCtrl;
  late final quill.QuillController cuerpoCtrl;
  bool tieneImagen;
  bool tieneVideo;
  String? imagenPath;
  String? videoPath;

  SeccionData({
    String titulo = '',
    String cuerpo = '',
    List<dynamic>? cuerpoDelta,
    this.tieneImagen = false,
    this.tieneVideo = false,
    this.imagenPath,
    this.videoPath,
  }) : tituloCtrl = TextEditingController(text: titulo) {
    quill.Document doc;
    try {
      if (cuerpoDelta != null && cuerpoDelta.isNotEmpty) {
        doc = quill.Document.fromJson(cuerpoDelta);
      } else if (cuerpo.isNotEmpty) {
        doc = quill.Document()..insert(0, '$cuerpo\n');
      } else {
        doc = quill.Document();
      }
    } catch (_) {
      doc = quill.Document();
    }
    cuerpoCtrl = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void dispose() {
    tituloCtrl.dispose();
    cuerpoCtrl.dispose();
  }

  factory SeccionData.fromJson(Map<String, dynamic> json) {
    return SeccionData(
      titulo: json['titulo'] as String? ?? '',
      cuerpoDelta: json['cuerpo_delta'] as List<dynamic>?,
      tieneImagen: json['tiene_imagen'] as bool? ?? false,
      tieneVideo: json['tiene_video'] as bool? ?? false,
      imagenPath: json['imagen_path'] as String?,
      videoPath: json['video_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': tituloCtrl.text,
      'cuerpo_delta': cuerpoCtrl.document.toDelta().toJson(),
      'tiene_imagen': tieneImagen,
      'tiene_video': tieneVideo,
      'imagen_path': imagenPath,
      'video_path': videoPath,
    };
  }
}

class SeccionEditorWidget extends StatefulWidget {
  final SeccionData data;
  final int index;
  final VoidCallback onEliminar;
  /// Cuando es true el título no es editable y no aparece el botón de eliminar.
  final bool tituloFijo;

  const SeccionEditorWidget({
    super.key,
    required this.data,
    required this.index,
    required this.onEliminar,
    this.tituloFijo = false,
  });

  @override
  State<SeccionEditorWidget> createState() => _SeccionEditorWidgetState();
}

class _SeccionEditorWidgetState extends State<SeccionEditorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(),
              _buildTituloField(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              _buildQuillEditor(),
              if (widget.data.tieneImagen || widget.data.tieneVideo)
                _buildMediaRow(),
              _buildMediaActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4DC130).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sección ${widget.index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3AA820),
              ),
            ),
          ),
          const Spacer(),
          // Ocultar botón eliminar si el título está fijo
          if (!widget.tituloFijo)
            GestureDetector(
              onTap: widget.onEliminar,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEB),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, color: Color(0xFFD63030), size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTituloField() {
    // Si el título está fijo, mostrar como etiqueta estática no editable
    if (widget.tituloFijo) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(
          widget.data.tituloCtrl.text.isEmpty
              ? 'Introducción'
              : widget.data.tituloCtrl.text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: widget.data.tituloCtrl,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          hintText: 'Título de la sección...',
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(0.25),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildQuillEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar: QuillSimpleToolbar con controller directo
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: quill.QuillSimpleToolbar(
            controller: widget.data.cuerpoCtrl,
            config: const quill.QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showListCheck: false,
              showAlignmentButtons: true,
              showSearchButton: false,
              showIndent: false,
              multiRowsDisplay: false,
            ),
          ),
        ),
        // Editor: QuillEditor.basic con controller directo
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: quill.QuillEditor.basic(
            controller: widget.data.cuerpoCtrl,
            config: quill.QuillEditorConfig(
              placeholder: 'Escribe el contenido de esta sección...',
              customStyles: quill.DefaultStyles(
                paragraph: quill.DefaultTextBlockStyle(
                  const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFF787878),
                    fontWeight: FontWeight.w400,
                  ),
                  const quill.HorizontalSpacing(0, 0),
                  const quill.VerticalSpacing(0, 0),
                  const quill.VerticalSpacing(0, 0),
                  null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          if (widget.data.tieneImagen) ...[
            _buildMediaPlaceholder(
              icon: Icons.image_outlined,
              label: 'Imagen',
              color: const Color(0xFF4DC130),
              path: widget.data.imagenPath,
              onRemove: () => setState(() {
                widget.data.tieneImagen = false;
                widget.data.imagenPath = null;
              }),
            ),
            const SizedBox(width: 12),
          ],
          if (widget.data.tieneVideo)
            _buildMediaPlaceholder(
              icon: Icons.play_circle_filled,
              label: 'Video',
              color: const Color(0xFFFF606F),
              path: widget.data.videoPath,
              onRemove: () => setState(() {
                widget.data.tieneVideo = false;
                widget.data.videoPath = null;
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPlaceholder({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onRemove,
    String? path,
  }) {
    return Expanded(
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: path != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: path.startsWith('http') || path.startsWith('assets/')
                        ? Image.network(
                            path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _buildIconContent(icon, label, color),
                          )
                        : kIsWeb
                            ? Image.network(
                                path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => _buildIconContent(icon, label, color),
                              )
                            : Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => _buildIconContent(icon, label, color),
                              ),
                  )
                : _buildIconContent(icon, label, color),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFD63030),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaActions() {
    final bool ambos = widget.data.tieneImagen && widget.data.tieneVideo;
    if (ambos) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: Row(
        children: [
          if (!widget.data.tieneImagen)
            _buildAddMediaBtn(
              icon: Icons.image_outlined,
              label: 'Imagen',
              color: const Color(0xFF4DC130),
              onTap: _agregarImagen,
            ),
          if (!widget.data.tieneImagen && !widget.data.tieneVideo)
            const SizedBox(width: 8),
          if (!widget.data.tieneVideo)
            _buildAddMediaBtn(
              icon: Icons.play_circle_outline,
              label: 'Video',
              color: const Color(0xFFFF606F),
              onTap: _agregarVideo,
            ),
        ],
      ),
    );
  }

  Widget _buildAddMediaBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // Contenido interno del icono (usado si no hay path o da error al cargar)
  Widget _buildIconContent(IconData icon, String label, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 32),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _agregarImagen() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        widget.data.tieneImagen = true;
        widget.data.imagenPath = img.path;
      });
      // Llama a onChanged si exisitera para auto-guardar
    } else {
      // Por si solo quería activar el placeholder y canceló (opcional, pero puedes dejarlo en true sin path)
      setState(() => widget.data.tieneImagen = true);
    }
  }

  Future<void> _agregarVideo() async {
    final picker = ImagePicker();
    final vid = await picker.pickVideo(source: ImageSource.gallery);
    if (vid != null) {
      setState(() {
        widget.data.tieneVideo = true;
        widget.data.videoPath = vid.path;
      });
    } else {
      setState(() => widget.data.tieneVideo = true);
    }
  }
}
