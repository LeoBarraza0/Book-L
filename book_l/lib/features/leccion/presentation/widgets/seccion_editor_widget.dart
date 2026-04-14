import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelo de datos de una sección (presentación solamente, sin lógica de dominio)
// ─────────────────────────────────────────────────────────────────────────────
class SeccionData {
  final TextEditingController tituloCtrl;
  final TextEditingController cuerpoCtrl;
  bool tieneImagen;
  bool tieneVideo;

  SeccionData({
    String titulo = '',
    String cuerpo = '',
    this.tieneImagen = false,
    this.tieneVideo = false,
  })  : tituloCtrl = TextEditingController(text: titulo),
        cuerpoCtrl = TextEditingController(text: cuerpo);

  void dispose() {
    tituloCtrl.dispose();
    cuerpoCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget principal: SeccionEditorWidget
// ─────────────────────────────────────────────────────────────────────────────
class SeccionEditorWidget extends StatefulWidget {
  final SeccionData data;
  final int index;
  final VoidCallback onEliminar;

  const SeccionEditorWidget({
    super.key,
    required this.data,
    required this.index,
    required this.onEliminar,
  });

  @override
  State<SeccionEditorWidget> createState() => _SeccionEditorWidgetState();
}

class _SeccionEditorWidgetState extends State<SeccionEditorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // Estado del toolbar
  bool _negrita = false;
  bool _cursiva = false;
  bool _subrayado = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
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
              // ── Cabecera de la sección ──────────────────────────────────
              _buildSectionHeader(),
              // ── Toolbar de Formato ─────────────────────────────────────
              _buildFormatToolbar(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              // ── Campos editables ───────────────────────────────────────
              _buildTituloField(),
              _buildCuerpoField(),
              // ── Medios (imagen / video) ───────────────────────────────
              if (widget.data.tieneImagen || widget.data.tieneVideo)
                _buildMediaRow(),
              // ── Botones de agregar medios ─────────────────────────────
              _buildMediaActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cabecera con número de sección y botón eliminar ──────────────────────
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
          GestureDetector(
            onTap: widget.onEliminar,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Color(0xFFD63030), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Toolbar de formato de texto ───────────────────────────────────────────
  Widget _buildFormatToolbar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toolbarToggle(
              label: 'B',
              bold: true,
              active: _negrita,
              onTap: () => setState(() => _negrita = !_negrita),
            ),
            _toolbarToggle(
              label: 'I',
              italic: true,
              active: _cursiva,
              onTap: () => setState(() => _cursiva = !_cursiva),
            ),
            _toolbarToggle(
              label: 'U',
              underline: true,
              active: _subrayado,
              onTap: () => setState(() => _subrayado = !_subrayado),
            ),
            _toolbarDivider(),
            _toolbarIcon(Icons.format_list_bulleted, onTap: () {}),
            _toolbarIcon(Icons.format_align_left, onTap: () {}),
            _toolbarIcon(Icons.format_align_center, onTap: () {}),
            _toolbarDivider(),
            _toolbarIcon(Icons.image_outlined, onTap: _agregarImagen, color: const Color(0xFF4DC130)),
            _toolbarIcon(Icons.play_circle_outline, onTap: _agregarVideo, color: const Color(0xFFFF606F)),
            _toolbarIcon(Icons.functions, onTap: () {}, color: const Color(0xFF5B8DEF)),
            _toolbarIcon(Icons.link, onTap: () {}, color: const Color(0xFF9B59B6)),
          ],
        ),
      ),
    );
  }

  Widget _toolbarToggle({
    required String label,
    bool bold = false,
    bool italic = false,
    bool underline = false,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4DC130) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            decoration: underline ? TextDecoration.underline : TextDecoration.none,
            decorationColor: active ? Colors.white : Colors.black87,
            color: active ? Colors.white : const Color(0xFF444444),
          ),
        ),
      ),
    );
  }

  Widget _toolbarIcon(IconData icon,
      {required VoidCallback onTap, Color color = const Color(0xFF555555)}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _toolbarDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: const Color(0xFFDDDDDD),
    );
  }

  // ── Campo de Título ────────────────────────────────────────────────────────
  Widget _buildTituloField() {
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

  // ── Campo de Cuerpo ───────────────────────────────────────────────────────
  Widget _buildCuerpoField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: widget.data.cuerpoCtrl,
        maxLines: null,
        minLines: 3,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: const Color(0xFF787878),
          fontStyle: _cursiva ? FontStyle.italic : FontStyle.normal,
          fontWeight: _negrita ? FontWeight.w700 : FontWeight.w400,
          decoration: _subrayado ? TextDecoration.underline : TextDecoration.none,
        ),
        decoration: InputDecoration(
          hintText: 'Escribe el contenido de esta sección...',
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.black.withOpacity(0.22),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // ── Fila de medios (imagen + video si están habilitados) ──────────────────
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
              onRemove: () => setState(() => widget.data.tieneImagen = false),
            ),
            const SizedBox(width: 12),
          ],
          if (widget.data.tieneVideo)
            _buildMediaPlaceholder(
              icon: Icons.play_circle_filled,
              label: 'Video',
              color: const Color(0xFFFF606F),
              onRemove: () => setState(() => widget.data.tieneVideo = false),
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
            child: Center(
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
            ),
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

  // ── Botones inferiores para añadir imagen / video ─────────────────────────
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _agregarImagen() => setState(() => widget.data.tieneImagen = true);
  void _agregarVideo() => setState(() => widget.data.tieneVideo = true);
}
