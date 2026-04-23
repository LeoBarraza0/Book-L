import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

/// Widget reutilizable para mostrar un PDF desde ruta local.
class PdfViewerWidget extends StatefulWidget {
  final String path;
  final String? nombre;

  const PdfViewerWidget({super.key, required this.path, this.nombre});

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  PDFViewController? _pdfController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4DC130), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header del visor
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(color: Color(0xFF363333)),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.nombre ?? 'Documento PDF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isReady)
                  Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          // Visor PDF
          SizedBox(
            height: 420,
            child: Stack(
              children: [
                PDFView(
                  filePath: widget.path.startsWith('file://') 
                      ? Uri.parse(widget.path).toFilePath() 
                      : widget.path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  fitPolicy: FitPolicy.WIDTH,
                  onRender: (pages) {
                    if (mounted) setState(() { _totalPages = pages ?? 0; _isReady = true; });
                  },
                  onViewCreated: (controller) => _pdfController = controller,
                  onPageChanged: (page, _) {
                    if (mounted) setState(() => _currentPage = page ?? 0);
                  },
                  onError: (_) {
                    if (mounted) setState(() => _isReady = false);
                  },
                ),
                if (!_isReady)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DC130)),
                    ),
                  ),
              ],
            ),
          ),
          // Controles de navegación
          if (_isReady && _totalPages > 1)
            Container(
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF4DC130)),
                    onPressed: _currentPage > 0
                        ? () => _pdfController?.setPage(_currentPage - 1)
                        : null,
                  ),
                  Text(
                    'Página ${_currentPage + 1} de $_totalPages',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF4DC130)),
                    onPressed: _currentPage < _totalPages - 1
                        ? () => _pdfController?.setPage(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
