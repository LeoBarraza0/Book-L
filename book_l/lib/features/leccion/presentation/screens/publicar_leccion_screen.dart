import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/storage/local_storage.dart';
import '../controller/leccion_controller.dart';
import '../widgets/agregar_seccion_button.dart';
import '../../../../shared/widgets/seccion_editor_widget.dart';
import '../widgets/material_editor_tile.dart';
import '../../domain/entities/capitulo.dart';
import '../../domain/entities/material_educativo.dart';

class PublicarLeccionScreen extends StatefulWidget {
  const PublicarLeccionScreen({super.key});

  @override
  State<PublicarLeccionScreen> createState() => _PublicarLeccionScreenState();
}

class _PublicarLeccionScreenState extends State<PublicarLeccionScreen>
    with TickerProviderStateMixin {
  final _nombreCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<SeccionData> _secciones = [];
  final List<Capitulo> _capitulosEnMemoria = [];
  final List<MaterialEducativo> _materialesEnMemoria = [];
  final _leccionCtrl = LeccionController();
  bool _guardando = false;
  String? _imagenPath; // imagen de portada seleccionada

  // Animaciones
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;
  late AnimationController _guardarAnimCtrl;
  late Animation<double> _guardarScaleAnim;

  @override
  void initState() {
    super.initState();

    // Sección inicial por defecto
    _secciones.add(SeccionData(titulo: 'Introducción'));

    // Header: fade + slide desde arriba
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut));

    _guardarAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _guardarScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _guardarAnimCtrl, curve: Curves.easeOutBack),
    );

    _headerAnimCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _guardarAnimCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _scrollCtrl.dispose();
    _headerAnimCtrl.dispose();
    _guardarAnimCtrl.dispose();
    for (final s in _secciones) {
      s.dispose();
    }
    super.dispose();
  }

  void _agregarSeccion() {
    setState(() => _secciones.add(SeccionData()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _eliminarSeccion(int index) {
    setState(() {
      _secciones[index].dispose();
      _secciones.removeAt(index);
    });
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null && mounted) {
      setState(() => _imagenPath = img.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFadeAnim,
                  child: SlideTransition(
                    position: _headerSlideAnim,
                    child: _buildHeader(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNombreEditable(),
                      const SizedBox(height: 28),
                      _buildSeccionLabel('Material de apoyo'),
                      const SizedBox(height: 12),
                      // Sección 0 (Introducción) con título fijo
                      ...List.generate(_secciones.length, (i) {
                        return SeccionEditorWidget(
                          key: ValueKey(_secciones[i].hashCode),
                          data: _secciones[i],
                          index: i,
                          onEliminar: () => _eliminarSeccion(i),
                          tituloFijo: i == 0,
                        );
                      }),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AgregarSeccionButton(onTap: _agregarSeccion),
                      ),
                      const SizedBox(height: 28),
                      _buildSeccionLabel('Capítulos'),
                      const SizedBox(height: 12),
                      ..._capitulosEnMemoria.asMap().entries.map(
                            (e) => _buildCapituloChip(e.key, e.value),
                          ),
                      const SizedBox(height: 8),
                      Center(
                        child: AgregarSeccionButton(
                          titulo: 'Añadir Capítulo',
                          onTap: _irACrearCapitulo,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildSeccionLabel('Material Relacionado'),
                      const SizedBox(height: 12),
                      ..._materialesEnMemoria.asMap().entries.map(
                            (e) => MaterialEditorTile(
                              material: e.value,
                              onEditar: () => _editarMaterial(e.key),
                              onEliminar: () => setState(() => _materialesEnMemoria.removeAt(e.key)),
                            ),
                          ),
                      const SizedBox(height: 8),
                      Center(
                        child: AgregarSeccionButton(
                          titulo: 'Añadir Material',
                          onTap: _mostrarModalAgregarMaterial,
                        ),
                      ),
                      const SizedBox(height: 36),
                      _buildGuardarButton(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        children: [
          // Imagen de portada o fondo por defecto (escalado para ocultar borde blanco)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: _imagenPath != null
                  ? (kIsWeb
                      ? Image.network(
                          _imagenPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF4DC130)),
                        )
                      : Image.file(
                          File(_imagenPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF4DC130)),
                        ))
                  : Transform.scale(
                      scale: 1.15,
                      child: Image.asset(
                        'assets/images/green_bg.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF4DC130)),
                      ),
                    ),
            ),
          ),

          // Overlay degradado
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Badge «Nueva Lección»
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 16, color: Color(0xFF4DC130)),
                    SizedBox(width: 6),
                    Text(
                      'Nueva Lección',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3AA820),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botones superiores (back + seleccionar imagen)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularIconButton(
                    Icons.arrow_back_rounded,
                    () => Navigator.pop(context),
                  ),
                  _buildCircularIconButton(
                    _imagenPath != null
                        ? Icons.image_rounded
                        : Icons.add_photo_alternate_outlined,
                    _seleccionarImagen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF6BCA54).withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // ─── Nombre editable ───────────────────────────────────────────────────────
  Widget _buildNombreEditable() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nombreCtrl,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF363333),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Nombre de la lección...',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const Icon(Icons.edit, size: 16, color: Color(0xFFAAAAAA)),
        ],
      ),
    );
  }

  Widget _buildSeccionLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF363333),
      ),
    );
  }

  // ─── Componente de capítulo estandarizado ──────────────────────────────────
  Widget _buildCapituloChip(int index, Capitulo capitulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFBDBDBD),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitulo.nombre.isEmpty ? 'Capítulo ${index + 1}' : capitulo.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDuracion(capitulo.tiempoTotal),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF676767),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _capitulosEnMemoria.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  size: 20, color: Color(0xFFD63030)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuracion(int segundos) {
    if (segundos < 60) return '$segundos seg';
    final mins = segundos ~/ 60;
    if (mins < 60) return '$mins min';
    final horas = mins ~/ 60;
    final resto = mins % 60;
    return resto == 0 ? '${horas}h' : '${horas}h ${resto}min';
  }

  Future<void> _irACrearCapitulo() async {
    final resultado = await Navigator.pushNamed(context, '/crear_capitulo');
    if (resultado != null && resultado is Capitulo) {
      setState(() => _capitulosEnMemoria.add(resultado));
    }
  }

  // ─── Material Relacionado ─────────────────────────────────────────────────

  void _mostrarModalAgregarMaterial() {
    _showMaterialDialog(null, null);
  }

  void _editarMaterial(int index) {
    _showMaterialDialog(_materialesEnMemoria[index], index);
  }

  void _showMaterialDialog(MaterialEducativo? existing, int? index) {
    final nombreCtrl = TextEditingController(text: existing?.nombre ?? '');
    final descCtrl = TextEditingController(text: existing?.descripcion ?? '');
    final urlCtrl = TextEditingController(text: existing?.url ?? '');
    String tipoSeleccionado = existing?.tipo ?? 'pdf';
    String? filePath = existing?.url;
    int tamano = existing?.tamanoBytes ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      existing != null ? 'Editar Material' : 'Nuevo Material',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF363333),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tipo selector
                    Row(
                      children: [
                        _buildTipoChip('PDF', 'pdf', tipoSeleccionado, const Color(0xFF4DC130), (t) => setModalState(() => tipoSeleccionado = t)),
                        const SizedBox(width: 8),
                        _buildTipoChip('Video', 'video', tipoSeleccionado, const Color(0xFFFF606F), (t) => setModalState(() => tipoSeleccionado = t)),
                        const SizedBox(width: 8),
                        _buildTipoChip('Enlace', 'enlace', tipoSeleccionado, const Color(0xFF4A90D9), (t) => setModalState(() => tipoSeleccionado = t)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    TextField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del material',
                        labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Descripción
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: 'Descripción (opcional)',
                        labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (tipoSeleccionado == 'enlace' || tipoSeleccionado == 'video') ...[
                      TextField(
                        controller: urlCtrl,
                        decoration: InputDecoration(
                          labelText: tipoSeleccionado == 'video' ? 'URL del video (ej. YouTube, o ignora para subir archivo)' : 'URL del enlace',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          prefixIcon: const Icon(Icons.link),
                        ),
                        onChanged: (val) {
                          if (val.trim().isNotEmpty && filePath != null) {
                            setModalState(() => filePath = null);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (tipoSeleccionado != 'enlace') ...[
                      if (tipoSeleccionado == 'video') ...[
                        const Text('O selecciona un archivo local:', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 8),
                      ],
                      GestureDetector(
                        onTap: () async {
                          if (tipoSeleccionado == 'pdf') {
                            try {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );
                              if (result != null && result.files.single.path != null) {
                                setModalState(() {
                                  filePath = result.files.single.path;
                                  tamano = result.files.single.size;
                                  if (nombreCtrl.text.isEmpty) {
                                    nombreCtrl.text = result.files.single.name;
                                  }
                                });
                              }
                            } catch (_) {}
                          } else {
                            final picker = ImagePicker();
                            final vid = await picker.pickVideo(source: ImageSource.gallery);
                            if (vid != null) {
                              final file = File(vid.path);
                              setModalState(() {
                                filePath = vid.path;
                                tamano = file.lengthSync();
                                if (nombreCtrl.text.isEmpty) {
                                  nombreCtrl.text = vid.name;
                                }
                              });
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDDDDDD)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                filePath != null ? Icons.check_circle : Icons.upload_file,
                                color: filePath != null ? const Color(0xFF4DC130) : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  filePath != null
                                      ? filePath!.split('/').last
                                      : 'Seleccionar archivo ${tipoSeleccionado.toUpperCase()}...',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: filePath != null ? Colors.black87 : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nombreCtrl.text.trim().isEmpty) return;
                          final mat = MaterialEducativo(
                            idMaterial: existing?.idMaterial ?? 0,
                            idLeccionFk: 0,
                            nombre: nombreCtrl.text.trim(),
                            tipo: tipoSeleccionado,
                            url: (tipoSeleccionado == 'enlace' || urlCtrl.text.trim().isNotEmpty) ? urlCtrl.text.trim() : filePath,
                            descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                            tamanoBytes: tamano,
                          );
                          setState(() {
                            if (index != null) {
                              _materialesEnMemoria[index] = mat;
                            } else {
                              _materialesEnMemoria.add(mat);
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DC130),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          existing != null ? 'Guardar cambios' : 'Agregar material',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTipoChip(String label, String tipo, String selected, Color color, ValueChanged<String> onTap) {
    final isSelected = tipo == selected;
    return GestureDetector(
      onTap: () => onTap(tipo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(isSelected ? 1.0 : 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // ─── Botón Guardar ─────────────────────────────────────────────────────────
  Widget _buildGuardarButton() {
    return ScaleTransition(
      scale: _guardarScaleAnim,
      child: Center(
        child: SizedBox(
          width: 220,
          child: _GuardarButton(
            label: _guardando ? 'Guardando...' : 'Guardar lección',
            onTap: _guardando ? null : _guardarLeccion,
          ),
        ),
      ),
    );
  }

  Future<void> _guardarLeccion() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de la lección es obligatorio'),
          backgroundColor: Color(0xFFFF606F),
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final idUsuario = AppSession().usuarioId ?? 1;
      final contenido = _secciones.map((s) => s.toJson()).toList();

      final newIdLeccion = await _leccionCtrl.agregarLeccion(
        idUsuario: idUsuario,
        nombre: nombre,
        contenido: contenido,
        imagenUrl: _imagenPath,
      );

      // Agregar los capítulos vinculados a la verdadera nueva ID de lección
      for (final cap in _capitulosEnMemoria) {
        await _leccionCtrl.agregarCapitulo(
          idLeccion: newIdLeccion,
          nombre: cap.nombre,
          contenido: cap.contenido,
          tiempoTotal: cap.tiempoTotal,
        );
      }

      // Agregar materiales relacionados
      for (final mat in _materialesEnMemoria) {
        _leccionCtrl.agregarMaterial(
          idLeccion: newIdLeccion,
          nombre: mat.nombre,
          tipo: mat.tipo,
          url: mat.url,
          descripcion: mat.descripcion,
          tamanoBytes: mat.tamanoBytes,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Lección guardada exitosamente',
                style:
                    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
            ]),
            backgroundColor: const Color(0xFF4DC130),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: const Color(0xFFFF606F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}

// ─── Botón animado reutilizable ───────────────────────────────────────────────
class _GuardarButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  const _GuardarButton({required this.label, this.onTap});

  @override
  State<_GuardarButton> createState() => _GuardarButtonState();
}

class _GuardarButtonState extends State<_GuardarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF48C634), Color(0xFF3AAA26)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4DC130).withOpacity(0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
