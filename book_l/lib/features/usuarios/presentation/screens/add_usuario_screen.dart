import 'dart:convert'; // Para jsonEncode al reconstruir las preferencias
import 'dart:io'; // Necesario para usar File (imagen local del dispositivo)

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Plugin para cámara y galería
import '../../../../shared/widgets/nav_bar.dart';
import '../../domain/entities/usuarios.dart';
import '../../../../core/services/bookl_service.dart';

class AddUsuarioScreen extends StatefulWidget {
  const AddUsuarioScreen({super.key});

  @override
  State<AddUsuarioScreen> createState() => _AddUsuarioScreenState();
}

class _AddUsuarioScreenState extends State<AddUsuarioScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _usernameController;
  late TextEditingController _correoController;
  late TextEditingController _passwordController;
  late TextEditingController _celularController;
  // Preferencias: el admin escribe los intereses separados por comas.
  // Al guardar, se convierten a JSON: {"intereses": [...]}
  late TextEditingController _preferenciasController;

  DateTime? _selectedDate;
  String? _selectedPrograma;
  int? _selectedSemestre;
  String? _selectedRol = 'Estudiante';

  final List<String> _roles = ['Estudiante', 'Profesor'];

  late final List<String> _programas;

  // ─── Estado del avatar ──────────────────────────────────────────────────
  // _avatarImage: Archivo local seleccionado desde cámara/galería.
  // Null al inicio (usuario nuevo no tiene foto aún).
  File? _avatarImage;
  // Instancia del plugin image_picker — se crea una sola vez como campo de clase
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _programas = BooklService().programas;
    _nombreController = TextEditingController();
    _usernameController = TextEditingController();
    _correoController = TextEditingController();
    _passwordController = TextEditingController();
    _celularController = TextEditingController();
    // Campo vacío al iniciar — el admin escribe los intereses en texto plano
    _preferenciasController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _usernameController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _celularController.dispose();
    _preferenciasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF1B440), // Yellow color from palette
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Convierte el texto del campo de preferencias al formato JSON del sistema.
  ///
  /// El admin escribe: "matemáticas, programación"
  /// Se convierte a:  {"intereses": ["matemáticas", "programación"]}
  ///
  /// Para usuarios nuevos no hay tema_oscuro original, así que no se incluye.
  String _buildPreferenciasJson(String interesesTexto) {
    final intereses = interesesTexto
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return jsonEncode({'intereses': intereses});
  }

  /// ─── Selección de imagen con image_picker ──────────────────────────────
  /// Muestra un bottom sheet estilo móvil con opciones para elegir foto.
  ///
  /// Funcionamiento de image_picker:
  /// - Se llama a _picker.pickImage(source: ImageSource.camera/gallery)
  /// - Retorna un XFile? (ruta temporal en el sistema de archivos del dispositivo)
  /// - Se convierte a File de dart:io para mostrarlo con FileImage()
  /// - imageQuality: 85 comprime la imagen sin pérdida visual notable
  /// - maxWidth: 800 limita el ancho para no saturar memoria
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador visual de drag (patrón estándar de bottom sheet móvil)
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Añadir foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Opción 1: Cámara
                // ImageSource.camera abre la cámara nativa del dispositivo
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF44BD32)),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),

                // Opción 2: Galería
                // ImageSource.gallery abre el selector de fotos del dispositivo
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFFF1B440)),
                  title: const Text('Elegir de la galería'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),

                // Opción 3: Eliminar (solo si ya seleccionó una)
                if (_avatarImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Quitar foto'),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _avatarImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Método centralizado que ejecuta la selección de imagen.
  ///
  /// [source]: ImageSource.camera → abre cámara / ImageSource.gallery → abre galería
  ///
  /// Flujo completo:
  /// 1. _picker.pickImage() abre la interfaz nativa del dispositivo
  /// 2. El usuario captura o selecciona una imagen
  /// 3. XFile contiene la ruta temporal del archivo en el dispositivo
  /// 4. File(pickedFile.path) convierte esa ruta a un objeto File de Dart
  /// 5. FileImage(File) es el ImageProvider que Flutter usa para mostrarlo
  /// 6. setState() actualiza el CircleAvatar para mostrar la imagen elegida
  /// 7. Si el usuario cancela, pickedFile es null y no ocurre nada
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Comprime al 85% para reducir tamaño del archivo
        maxWidth: 800,    // Ancho máximo en píxeles para no sobrecargar memoria
      );

      if (pickedFile != null) {
        setState(() {
          // File() de dart:io convierte la ruta a un objeto File legible por Flutter
          _avatarImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Si hay error (ej: usuario denegó permisos), mostramos mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // ── HEADER ────────────────────────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/yellow_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: topPadding + 8,
                          left: 20,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                customBorder: const CircleBorder(),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          top: 80,
                          child: Center(
                            child: Text(
                              'Añadir Usuario',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontFamily: 'Baloo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── CONTENIDO ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Perfil: Avatar + Nombre
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // GestureDetector envuelve el avatar para capturar el tap
                          GestureDetector(
                            onTap: _showImagePickerSheet,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  // Si _avatarImage tiene valor, usamos FileImage (imagen local)
                                  // Si no, mostramos el ícono de persona como placeholder
                                  backgroundImage: _avatarImage != null
                                      ? FileImage(_avatarImage!) as ImageProvider
                                      : null,
                                  child: _avatarImage == null
                                      ? const Icon(Icons.person,
                                          size: 50, color: Colors.grey)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF44BD32),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      // Ícono dinámico: lápiz si tiene foto, '+' si no
                                      _avatarImage != null
                                          ? Icons.edit
                                          : Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              children: [
                                _buildTextField(
                                    'Nombre completo: *', _nombreController),
                                const SizedBox(height: 10),
                                _buildTextField(
                                    'Usuario:', _usernameController),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Fila 2: Fecha Nacimiento & Email
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _buildTextField(
                                  'Fecha de nacimiento:',
                                  TextEditingController(
                                      text: _selectedDate == null
                                          ? ''
                                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                                  suffixIcon: Icons.calendar_today,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                              child: _buildTextField(
                                  'Correo electrónico: *', _correoController)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Fila 3: Contraseña & Celular
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                    'Contraseña: *', _passwordController,
                                    obscureText: true),
                                const SizedBox(height: 5),
                                const Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 12, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'La contraseña debe contener mínimo 8 caracteres',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                              child: _buildTextField(
                                  'Celular: *', _celularController,
                                  keyboardType: TextInputType.phone)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Fila 4: Programa & Semestre
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                                'Programa: *', _programas, _selectedPrograma,
                                (val) {
                              setState(() => _selectedPrograma = val);
                            }),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildDropdownField(
                                'Semestre: *',
                                List.generate(10, (i) => (i + 1).toString()),
                                _selectedSemestre?.toString(), (val) {
                              setState(
                                  () => _selectedSemestre = int.tryParse(val!));
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Fila 5: Rol
                      _buildDropdownField('Rol: *', _roles, _selectedRol,
                          (val) {
                        setState(() => _selectedRol = val);
                      }),
                      const SizedBox(height: 20),

                      // Preferencias: el admin escribe los intereses separados por comas
                      // Ejemplo: "matemáticas, programación, diseño"
                      // Al guardar se convierte automáticamente a JSON: {"intereses": [...]}
                      _buildTextField('Preferencias (separar con comas)',
                          _preferenciasController,
                          maxLines: 4),

                      const SizedBox(height: 30),

                      Container(
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFDCD51),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.50),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final newUser = Usuario(
                                idUsuario:
                                    DateTime.now().millisecondsSinceEpoch,
                                nombreCompleto: _nombreController.text,
                                username: _usernameController.text,
                                correo: _correoController.text,
                                password: _passwordController.text,
                                celular: int.tryParse(_celularController.text),
                                nacimiento: _selectedDate,
                                programa: _selectedPrograma,
                                semestre: _selectedSemestre,
                                // Convertir el texto de intereses al formato JSON
                                preferencias: _preferenciasController.text.isNotEmpty
                                    ? _buildPreferenciasJson(_preferenciasController.text)
                                    : null,
                                activo: true,
                                rol: _selectedRol ?? 'Estudiante',
                                // Por ahora el avatarUrl no se guarda (requeriría subir el File a un servidor)
                                // En producción se haría upload del File y se guardaría la URL resultante
                                avatarUrl: null,
                              );
                              Navigator.pop(context, newUser);
                            },
                            borderRadius: BorderRadius.circular(24.50),
                            child: const SizedBox(
                              width: 156,
                              height: 49,
                              child: Center(
                                child: Text(
                                  'Guardar',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // Espacio para la navbar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── BOTTOM NAV BAR ─────────────────────────────────────────────
          const Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SharedBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false,
      IconData? suffixIcon,
      TextInputType? keyboardType,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey, size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              menuMaxHeight: 250, // Permite scrollear si la lista es grande
              hint:
                  const Text('Seleccionar...', style: TextStyle(fontSize: 14)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
