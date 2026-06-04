import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/perfil_controller.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/controller/auth_controller.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  // Initial State
  late String _nombre;
  late String _usuario;
  late String _descripcion;
  late String _programa;
  late String _semestre;
  late String _celular;

  File? _selectedImage;
  String? _avatarNetworkUrl;
  late int _userId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _programas = BooklService().programas;
    _loadUserData();
  }

  void _loadUserData() {
    _userId = AppSession().usuarioId ?? 0;
    try {
      final user = PerfilController().getUsuarioById(_userId)!;
      _nombre = user.nombreCompleto;
      _usuario = user.username ?? '';
      _descripcion = user.descripcion ?? '';
      _programa = user.programa ?? '';
      _semestre = user.semestre?.toString() ?? '';
      _celular = user.celular?.toString() ?? '';
      _avatarNetworkUrl = user.avatarUrl;
      if (_avatarNetworkUrl != null &&
          _avatarNetworkUrl!.isNotEmpty &&
          !_avatarNetworkUrl!.startsWith('http')) {
        if (!kIsWeb) {
          _selectedImage = File(_avatarNetworkUrl!);
        }
      }
    } catch (e) {
      _nombre = 'Usuario';
      _usuario = '';
      _descripcion = '';
      _programa = '';
      _semestre = '';
      _celular = '';
    }
  }

  void _saveUserData() {
    try {
      final user = PerfilController().getUsuarioById(_userId)!;
      final updatedUser = user.copyWith(
        nombreCompleto: _nombre,
        username: _usuario,
        descripcion: _descripcion,
        programa: _programa,
        semestre: int.tryParse(_semestre),
        celular: int.tryParse(_celular),
        avatarUrl:
            _avatarNetworkUrl, // This could be updated if an image is uploaded
      );
      PerfilController().updateUsuario(updatedUser);
    } catch (e) {
      // Ignorar si el usuario no se encuentra
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
          _avatarNetworkUrl = image.path;
        });
        _saveUserData();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  late final List<String> _programas;

  final List<String> _semestres = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB), // Light gray/blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF88D288), // Light green in the back button
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Circular Avatar icon with Camera "Change Photo"
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DC130), // Main Green
                      shape: BoxShape.circle,
                      image: (!kIsWeb && _selectedImage != null)
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : (_avatarNetworkUrl != null &&
                                  _avatarNetworkUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image:
                                      (_avatarNetworkUrl!.startsWith('http') ||
                                              kIsWeb)
                                          ? NetworkImage(_avatarNetworkUrl!)
                                              as ImageProvider
                                          : FileImage(File(_avatarNetworkUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_selectedImage == null &&
                            (_avatarNetworkUrl == null ||
                                _avatarNetworkUrl!.isEmpty))
                        ? const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors
                            .grey[200], // Background gray for Change Photo
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Cambiar Foto',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // Public Information
            _buildSectionTitle('Información pública'),
            _buildCard([
              _buildListItem('Nombre', _nombre, _editarNombre),
              _buildListItem('Usuario', _usuario, _editarUsuario),
              _buildListItem(
                'Descripción',
                _descripcion,
                _editarDescripcion,
                isLast: true,
              ),
            ]),

            const SizedBox(height: 25),

            // Personal Information
            _buildSectionTitle('Información personal'),
            _buildCard([
              _buildListItem('Programa', _programa, _editarPrograma),
              _buildListItem('Semestre', _semestre, _editarSemestre),
              _buildListItem('Celular', _celular, _editarCelular, isLast: true),
            ]),

            const SizedBox(height: 30),

            // Deactivate Account
            _buildCard([
              InkWell(
                onTap: _desactivarCuentaModal,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5656), // Circle background rojo
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Desactivar Cuenta',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI Builders ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),
    );
  }

  // Card container of white items with borders
  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Each row of the table
  Widget _buildListItem(
    String label,
    String value,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : (label == 'Nombre' || label == 'Programa')
              ? const BorderRadius.vertical(top: Radius.circular(16))
              : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 22, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // --- Modals y Alerts ---

  Future<void> _mostrarModal({
    required String title,
    String? subtitle,
    required Widget content,
    required VoidCallback onSave,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF49454F),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 19),
                content,
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFFFF5656),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        onSave();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(
                          color: Color(0xFF4DC130),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 6), // Sombra inferior
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF4F5F7), // Light gray background
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Actions

  void _editarCampoTexto({
    required String title,
    required String subtitle,
    required String hint,
    required String initialValue,
    required ValueChanged<String> onSave,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    TextEditingController controller = TextEditingController(
      text: initialValue,
    );
    _mostrarModal(
      title: title,
      subtitle: subtitle,
      content: _buildTextField(
        controller,
        hint,
        maxLines: maxLines,
        keyboardType: keyboardType,
      ),
      onSave: () => onSave(controller.text),
    );
  }

  void _editarNombre() {
    _editarCampoTexto(
      title: 'Editar Nombre',
      subtitle: 'Añade tu nombre completo a tu cuenta.',
      hint: 'Añade tu nombre',
      initialValue: _nombre,
      onSave: (val) {
        setState(() => _nombre = val);
        _saveUserData();
      },
    );
  }

  void _editarUsuario() {
    _editarCampoTexto(
      title: 'Editar Usuario',
      subtitle: 'Añade un nombre de usuario a tu cuenta.',
      hint: 'Añade un usuario',
      initialValue: _usuario,
      onSave: (val) {
        setState(() => _usuario = val);
        _saveUserData();
      },
    );
  }

  void _editarDescripcion() {
    _editarCampoTexto(
      title: 'Editar Descripción',
      subtitle: 'Escribe una breve descripción sobre ti.',
      hint: 'Añade una descripción',
      initialValue: _descripcion,
      maxLines: 4,
      onSave: (val) {
        setState(() => _descripcion = val);
        _saveUserData();
      },
    );
  }

  void _editarPrograma() {
    _mostrarModal(
      title: 'Editar Programa',
      content: DropdownButtonFormField<String>(
        initialValue:
            _programas.contains(_programa) ? _programa : _programas.first,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF4F5F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        items: _programas.map((p) {
          return DropdownMenuItem(value: p, child: Text(p));
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() => _programa = val);
            _saveUserData();
            Navigator.pop(context); // Auto-close on selection
          }
        },
      ),
      onSave: () {}, // Already saved on changed
    );
  }

  void _editarSemestre() {
    _mostrarModal(
      title: 'Editar Semestre',
      content: DropdownButtonFormField<String>(
        initialValue:
            _semestres.contains(_semestre) ? _semestre : _semestres.first,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF4F5F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        items: _semestres.map((s) {
          return DropdownMenuItem(value: s, child: Text(s));
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() => _semestre = val);
            _saveUserData();
            Navigator.pop(context);
          }
        },
      ),
      onSave: () {},
    );
  }

  void _editarCelular() {
    _editarCampoTexto(
      title: 'Editar Celular',
      subtitle: 'Actualiza tu número de contacto celular.',
      hint: 'Ej: 3001234567',
      initialValue: _celular,
      keyboardType: TextInputType.phone,
      onSave: (val) {
        setState(() => _celular = val);
        _saveUserData();
      },
    );
  }

  void _desactivarCuentaModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Desactivar Cuenta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFB3261E),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9DEDC),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/images/Chatbot_Icon.png', // Book-L Logo
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aún estas a tiempo, ¿En verdad deseas\ndesactivar tu cuenta Book-L?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF49454F),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF49454F),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatefulBuilder(
                      builder: (ctx, setInnerState) {
                        bool _loading = false;
                        return TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: _loading
                              ? null
                              : () async {
                                  setInnerState(() => _loading = true);
                                  // 1. Marcar cuenta inactiva en memoria + Supabase
                                  await PerfilController()
                                      .desactivarCuenta(_userId);
                                  // 2. Cerrar sesión
                                  await AuthController().cerrarSesion();
                                  // 3. Navegar al login
                                  if (context.mounted) {
                                    Navigator.of(context)
                                      ..pop() // Cierra el diálogo
                                      ..pop() // Cierra EditarPerfil
                                      ..pop(); // Cierra PerfilScreen
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                          child: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFB3261E),
                                  ),
                                )
                              : const Text(
                                  'Desactivar',
                                  style: TextStyle(
                                    color: Color(0xFFB3261E),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
