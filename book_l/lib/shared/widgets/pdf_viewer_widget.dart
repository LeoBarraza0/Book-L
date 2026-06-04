import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Widget reutilizable para mostrar un PDF desde ruta local o URL remota.
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

  bool _isLoading = false;
  String? _localPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    final path = widget.path;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _isReady = false;
      });
      try {
        final response = await http.get(Uri.parse(path));
        if (response.statusCode == 200) {
          final tempDir = Directory.systemTemp;
          final file = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
          await file.writeAsBytes(response.bodyBytes);
          if (mounted) {
            setState(() {
              _localPath = file.path;
              _isLoading = false;
            });
          }
        } else {
          throw Exception('Código de estado: ${response.statusCode}');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error al descargar el PDF: $e';
          });
        }
      }
    } else {
      setState(() {
        _localPath = path.startsWith('file://')
            ? Uri.parse(path).toFilePath()
            : path;
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant PdfViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _preparePdf();
    }
  }

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
                if (_localPath != null && _errorMessage == null)
                  PDFView(
                    filePath: _localPath!,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageFling: true,
                    pageSnap: true,
                    fitPolicy: FitPolicy.WIDTH,
                    onRender: (pages) {
                      if (mounted) {
                        setState(() {
                          _totalPages = pages ?? 0;
                          _isReady = true;
                        });
                      }
                    },
                    onViewCreated: (controller) => _pdfController = controller,
                    onPageChanged: (page, _) {
                      if (mounted) setState(() => _currentPage = page ?? 0);
                    },
                    onError: (err) {
                      if (mounted) {
                        setState(() {
                          _isReady = false;
                          _errorMessage = 'Error al renderizar PDF: $err';
                        });
                      }
                    },
                  ),
                if (_isLoading || (_localPath != null && !_isReady && _errorMessage == null))
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF4DC130)),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Descargando PDF...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (_errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: Color(0xFF4DC130)),
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
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF4DC130)),
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
