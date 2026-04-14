import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  // Initial State
  String _nombre = 'Emanuel Barranco';
  String _usuario = '@Manu7u7';
  String _descripcion =
      '"Natty my love, Sharay my universe ✨"\npsdt. Freddy mala paga';
  String _programa = 'Ingeniería de Sistemas';
  String _semestre = '7';
  String _celular = '3214567890';

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  final List<String> _programas = [
    'Ingeniería de Sistemas',
    'Ingeniería Industrial',
    'Administración de Empresas',
    'Contaduría Pública',
    'Derecho',
    'Medicina',
  ];

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
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
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
            color: Colors.black.withOpacity(0.01),
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
            color: Colors.grey.withOpacity(0.3),
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

  void _editarCampoDropdown({
    required String title,
    required String subtitle,
    required String initialValue,
    required List<String> opciones,
    required ValueChanged<String> onSave,
  }) {
    String tempValue = initialValue;
    _mostrarModal(
      title: title,
      subtitle: subtitle,
      content: StatefulBuilder(
        builder: (context, setStateModal) {
          return DropdownButtonFormField<String>(
            initialValue: opciones.contains(tempValue) ? tempValue : opciones.first,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
            menuMaxHeight: 250,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF4F5F7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: opciones
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) setStateModal(() => tempValue = val);
            },
          );
        },
      ),
      onSave: () => onSave(tempValue),
    );
  }

  void _editarNombre() => _editarCampoTexto(
    title: 'Nombre',
    subtitle: 'Por favor, indique como desea ser\nllamado en Book-L',
    hint: 'Mi nombre es...',
    initialValue: _nombre,
    onSave: (val) => setState(() => _nombre = val),
  );

  void _editarUsuario() => _editarCampoTexto(
    title: 'Usuario',
    subtitle: 'Por favor, indique como desea ser\nllamado en Book-L',
    hint: 'Mi @User es...',
    initialValue: _usuario,
    onSave: (val) => setState(() => _usuario = val),
  );

  void _editarDescripcion() => _editarCampoTexto(
    title: 'Descripción',
    subtitle: 'Por favor, indique como desea tener\nsu descripción',
    hint: 'Mi descripción...',
    initialValue: _descripcion,
    maxLines: 3,
    onSave: (val) => setState(() => _descripcion = val),
  );

  void _editarPrograma() => _editarCampoDropdown(
    title: 'Programa',
    subtitle:
        'Por favor, indique en qué programa académico\nse encuentra en su universidad',
    initialValue: _programa,
    opciones: _programas,
    onSave: (val) => setState(() => _programa = val),
  );

  void _editarSemestre() => _editarCampoDropdown(
    title: 'Semestre',
    subtitle: 'Por favor, indique en qué semestre se\nencuentra',
    initialValue: _semestre,
    opciones: _semestres,
    onSave: (val) => setState(() => _semestre = val),
  );

  void _editarCelular() => _editarCampoTexto(
    title: 'Celular',
    subtitle: 'Por favor, indique su número de celular',
    hint: 'Mi número es...',
    initialValue: _celular,
    keyboardType: TextInputType.phone,
    onSave: (val) => setState(() => _celular = val),
  );

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
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        // Logic to Deactivate Account
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Desactivar',
                        style: TextStyle(
                          color: Color(0xFFB3261E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
}
