import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../shared/widgets/custom_avatar.dart';
import '../../domain/entities/usuarios.dart';
import '../../../../core/services/bookl_service.dart';

class EditUsuarioScreen extends StatefulWidget {
  final Usuario usuario;

  const EditUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditUsuarioScreen> createState() => _EditUsuarioScreenState();
}

class _EditUsuarioScreenState extends State<EditUsuarioScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _usernameController;
  late TextEditingController _correoController;
  late TextEditingController _passwordController;
  late TextEditingController _celularController;
  late TextEditingController _preferenciasController;

  DateTime? _selectedDate;
  String? _selectedPrograma;
  int? _selectedSemestre;
  String? _selectedRol;
  late List<String> _roles;

  // ─── Estado del avatar ────────────────────────────────────────────────
  String? _avatarNetworkUrl; // URL remota o local seleccionada
  final ImagePicker _picker = ImagePicker();

  bool? _temaOscuroOriginal;
  late final List<String> _programas;
  late bool _activo;

  String? _usernameError;

  void _validateUsername() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      if (_usernameError != null) setState(() => _usernameError = null);
      return;
    }
    
    final exists = BooklService().usuarios.any(
      (u) => u.idUsuario != widget.usuario.idUsuario &&
             u.username?.toLowerCase() == username.toLowerCase()
    );

    setState(() {
      _usernameError = exists ? 'Este usuario ya está en uso' : null;
    });
  }

  @override
  void initState() {
    super.initState();
    _programas = BooklService().programas;
    _nombreController =
        TextEditingController(text: widget.usuario.nombreCompleto);
    _usernameController = TextEditingController(text: widget.usuario.username);
    _usernameController.addListener(_validateUsername);
    _correoController = TextEditingController(text: widget.usuario.correo);
    _passwordController = TextEditingController(text: widget.usuario.password);
    _celularController =
        TextEditingController(text: widget.usuario.celular?.toString() ?? '');
    _preferenciasController = TextEditingController(
      text: _extractIntereses(widget.usuario.preferencias),
    );
    _temaOscuroOriginal = _extractTemaOscuro(widget.usuario.preferencias);
    _avatarNetworkUrl = widget.usuario.avatarUrl;
    _selectedDate = widget.usuario.nacimiento;
    _activo = widget.usuario.activo;

    final programa = widget.usuario.programa;
    _selectedPrograma =
        (programa != null && _programas.contains(programa)) ? programa : null;
    _selectedSemestre = widget.usuario.semestre;

    final initialRol = widget.usuario.rol;
    _roles = ['Estudiante', 'Profesor'];
    if (initialRol != null && !_roles.contains(initialRol)) {
      _roles.add(initialRol);
    }
    _selectedRol = initialRol ?? 'Estudiante';
  }

  @override
  void dispose() {
    _usernameController.removeListener(_validateUsername);
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
              primary: Color(0xFFF1B440),
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

  String _extractIntereses(String? preferenciasJson) {
    if (preferenciasJson == null || preferenciasJson.isEmpty) return '';
    try {
      final map = jsonDecode(preferenciasJson);
      if (map is Map<String, dynamic> && map.containsKey('intereses')) {
        final intereses = List<String>.from(map['intereses'] ?? []);
        return intereses.join(', ');
      }
    } catch (_) {}
    return preferenciasJson;
  }

  bool? _extractTemaOscuro(String? preferenciasJson) {
    if (preferenciasJson == null || preferenciasJson.isEmpty) return null;
    try {
      final map = jsonDecode(preferenciasJson);
      if (map is Map<String, dynamic> && map.containsKey('tema_oscuro')) {
        return map['tema_oscuro'] as bool?;
      }
    } catch (_) {}
    return null;
  }

  String _rebuildPreferencias(String interesesTexto) {
    final intereses = interesesTexto
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final map = <String, dynamic>{
      'intereses': intereses,
    };
    if (_temaOscuroOriginal != null) {
      map['tema_oscuro'] = _temaOscuroOriginal;
    }
    return jsonEncode(map);
  }



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
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading:
                      const Icon(Icons.camera_alt, color: Color(0xFF44BD32)),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Color(0xFFF1B440)),
                  title: const Text('Elegir de la galería'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_avatarNetworkUrl != null)
                  ListTile(
                    leading:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Eliminar foto actual'),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _avatarNetworkUrl = null;
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarNetworkUrl = pickedFile.path;
        });
      }
    } catch (e) {
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
                              'Editar Usuario',
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _showImagePickerSheet,
                            child: Stack(
                              children: [
                                CustomAvatar(
                                  url: _avatarNetworkUrl,
                                  nombre: _nombreController.text.isNotEmpty ? _nombreController.text : 'Usuario',
                                  radius: 40,
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
                                      _avatarNetworkUrl != null
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
                                    'Usuario:', _usernameController, errorText: _usernameError),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                      _buildDropdownField('Rol: *', _roles, _selectedRol,
                          (val) {
                        setState(() => _selectedRol = val);
                      }),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            'Estado Activo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            _activo ? 'El usuario puede iniciar sesión' : 'El usuario no tiene acceso',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: _activo,
                          activeThumbColor: const Color(0xFF44BD32),
                          onChanged: (val) {
                            setState(() {
                              _activo = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('Preferencias', _preferenciasController,
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
                              if (_usernameError != null) return;
                              final updatedUser = Usuario(
                                idUsuario: widget.usuario.idUsuario,
                                nombreCompleto: _nombreController.text,
                                username: _usernameController.text,
                                correo: _correoController.text,
                                password: _passwordController.text,
                                celular: int.tryParse(_celularController.text),
                                nacimiento: _selectedDate,
                                programa: _selectedPrograma,
                                semestre: _selectedSemestre,
                                preferencias: _rebuildPreferencias(
                                    _preferenciasController.text),
                                activo: _activo,
                                rol: _selectedRol,
                                avatarUrl: _avatarNetworkUrl,
                              );
                              Navigator.pop(context, updatedUser);
                            },
                            borderRadius: BorderRadius.circular(24.50),
                            child: SizedBox(
                              width: 156,
                              height: 49,
                              child: const Center(
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
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      int maxLines = 1,
      String? errorText}) {
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
            errorText: errorText,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey, size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
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
              menuMaxHeight: 250,
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
