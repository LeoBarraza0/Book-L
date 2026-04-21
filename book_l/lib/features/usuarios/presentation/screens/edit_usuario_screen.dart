import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
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

  late final List<String> _programas;

  @override
  void initState() {
    super.initState();
    _programas = BooklService().programas;
    _nombreController =
        TextEditingController(text: widget.usuario.nombreCompleto);
    _usernameController = TextEditingController(text: widget.usuario.username);
    _correoController = TextEditingController(text: widget.usuario.correo);
    _passwordController = TextEditingController(text: widget.usuario.password);
    _celularController =
        TextEditingController(text: widget.usuario.celular?.toString() ?? '');
    _preferenciasController =
        TextEditingController(text: widget.usuario.preferencias ?? '');
    _selectedDate = widget.usuario.nacimiento;
    // Solo asigna el programa si existe en la lista; si no, deja null (sin selección).
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

                // ── CONTENIDO ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Perfil: Avatar + Nombre
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person,
                                    size: 50, color: Colors.grey),
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
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
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

                      // Preferencias
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
                              color: Color(
                                  0x3F000000), // 0x3F = ~0.247 de opacidad
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
                                preferencias: _preferenciasController.text,
                                activo: widget.usuario.activo,
                                rol: _selectedRol,
                                avatarUrl: widget.usuario.avatarUrl,
                              );
                              Navigator.pop(context, updatedUser);
                            },
                            borderRadius: BorderRadius.circular(24.50),
                            child: Container(
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
