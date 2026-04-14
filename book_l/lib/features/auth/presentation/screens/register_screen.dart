import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final _nombreController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _fechaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _celularController = TextEditingController();
  final _preferenciasController = TextEditingController();

  bool _obscurePassword = true;

  // Dropdowns
  String? _programaSeleccionado;
  String? _semestreSeleccionado;

  final List<String> _programas = [
    'Ingeniería de Sistemas',
    'Ingeniería Industrial',
    'Administración de Empresas',
    'Contaduría Pública',
    'Derecho',
    'Medicina',
  ];

  final List<String> _semestres = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _usuarioController.dispose();
    _emailController.dispose();
    _fechaController.dispose();
    _passwordController.dispose();
    _celularController.dispose();
    _preferenciasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header blanco con logo ─────────────────────────────────
              _buildHeader(context),

              // ── Formulario ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto de perfil + campos Nombre/Usuario
                    _buildProfileSection(),
                    const SizedBox(height: 20),

                    // Fila: Fecha nacimiento | Correo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDateField(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _emailController,
                            label: 'Correo electrónico:',
                            hint: 'nombre@ejemplo.com',
                            keyboardType: TextInputType.emailAddress,
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fila: Contraseña | Celular
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña:',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            isRequired: true,
                            helperText: 'Mínimo 8 caracteres',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF828282),
                                size: 18,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _celularController,
                            label: 'Celular:',
                            hint: '3214567890',
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fila: Programa | Semestre
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Programa:',
                            isRequired: true,
                            value: _programaSeleccionado,
                            items: _programas,
                            onChanged: (v) =>
                                setState(() => _programaSeleccionado = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Semestre:',
                            isRequired: true,
                            value: _semestreSeleccionado,
                            items: _semestres,
                            onChanged: (v) =>
                                setState(() => _semestreSeleccionado = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Preferencias (textarea)
                    _buildPreferenciasField(),
                    const SizedBox(height: 30),

                    // Botón Registrarse
                    CustomButton(
                      label: 'Registrarse',
                      onPressed: () {
                        // TODO: implementar lógica de registro
                      },
                    ),
                    const SizedBox(height: 20),

                    // ¿Ya tienes cuenta? Inicia Sesión
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF555555),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Inicia Sesión',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4DC130),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF4DC130),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header blanco con logo Book-L alineado a la derecha (como en Figma)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo en fila superior (top-right como en Figma)
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),

          // Título centrado
          const Text(
            'Registro Usuario',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF48C634),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sección de foto de perfil + nombre + usuario
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar con botón de añadir foto
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4DC130), width: 2.5),
                color: const Color(0xFFEEEEEE),
              ),
              child: ClipOval(
                child: Image.network(
                  'http://localhost:3845/assets/c270ee2cfdb6c5fb68db02bf4810d35ed9ae8468.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.person,
                    size: 48,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF9800),
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Campos Nombre completo + Usuario
        Expanded(
          child: Column(
            children: [
              CustomTextField(
                controller: _nombreController,
                label: 'Nombre completo:',
                hint: 'Tu nombre',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _usuarioController,
                label: 'Usuario:',
                hint: '@usuario',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Campo de fecha con ícono de calendario
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Fecha de nacimiento:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF858484),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _fechaController,
            readOnly: true,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'DD/MM/AAAA',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B0B0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4DC130), width: 2.0),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today,
                    color: Color(0xFF4DC130), size: 20),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF4DC130),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    _fechaController.text =
                        '${picked.day.toString().padLeft(2, '0')}/'
                        '${picked.month.toString().padLeft(2, '0')}/'
                        '${picked.year}';
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dropdown genérico
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF858484),
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFB1111),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text(
                'Seleccionar',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB0B0B0),
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF4DC130)),
              isExpanded: true,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Área de texto para preferencias
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPreferenciasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferencias:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF858484),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x25000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white),
          ),
          child: TextField(
            controller: _preferenciasController,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Describe tus intereses y preferencias de aprendizaje...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B0B0),
              ),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
