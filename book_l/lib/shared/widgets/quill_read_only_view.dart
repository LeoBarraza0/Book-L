import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Un widget ligero que renderiza contenido en formato Delta de Quill
/// en modo de solo lectura, preservando el formato original.
class QuillReadOnlyView extends StatefulWidget {
  final List<dynamic>? delta;
  final double fontSize;
  final Color? color;

  const QuillReadOnlyView({
    super.key,
    required this.delta,
    this.fontSize = 16,
    this.color = const Color(0xFF787878),
  });

  @override
  State<QuillReadOnlyView> createState() => _QuillReadOnlyViewState();
}

class _QuillReadOnlyViewState extends State<QuillReadOnlyView> {
  quill.QuillController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(QuillReadOnlyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delta != widget.delta) {
      _initController();
    }
  }

  void _initController() {
    if (widget.delta != null && widget.delta!.isNotEmpty) {
      try {
        final doc = quill.Document.fromJson(widget.delta!);
        _controller = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } catch (e) {
        _controller = null;
      }
    } else {
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return quill.QuillEditor.basic(
      controller: _controller!,
      config: quill.QuillEditorConfig(
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        showCursor: false,
        scrollable: false, // El scroll lo maneja el padre (CustomScrollView)
        enableInteractiveSelection: true,
        customStyles: quill.DefaultStyles(
          paragraph: quill.DefaultTextBlockStyle(
            TextStyle(
              fontFamily: 'Inter',
              fontSize: widget.fontSize,
              color: widget.color,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            const quill.HorizontalSpacing(0, 0),
            const quill.VerticalSpacing(0, 0),
            const quill.VerticalSpacing(0, 0),
            null,
          ),
        ),
      ),
    );
  }
}
