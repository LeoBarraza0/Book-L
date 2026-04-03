import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    // TODO: implementar lógica de autenticación
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    debugPrint('Email: $email | Password: $password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Sección superior: imagen de fondo con logo ──────────────
            _buildHeader(),

            // ── Sección inferior: formulario ────────────────────────────
            _buildForm(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header con imagen de fondo y logo
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 420,
      child: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.network(
              'http://localhost:3845/assets/4f249115e7c6cfc36e828c251b7c4ce632f1f4c2.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(color: Colors.white),
            ),
          ),

          // Contenido centrado (centrado vertical y horizontal perfecto)
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Para que el align funcione mejor
              children: [
                const Text(
                  'Aprende con',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Logo BOOK-L (Aumentado)
                Image.network(
                  'http://localhost:3845/assets/e537c25c6a77635361d3fb2f09f3fe514f61e72a.png',
                  width: 320,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'BOOK-L',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4DC130),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: const TextSpan(
                    text: 'El poder del ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                    children: [
                      TextSpan(
                        text: 'Conocimiento',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4DC130),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Formulario de login
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildForm(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título
          const Text(
            'Iniciar Sesión',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF48C634),
              letterSpacing: 0.8,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 35),

          // Label correo
          _buildLabel('Ingresa tu correo:'),
          const SizedBox(height: 8),

          // Campo de correo
          _buildTextField(
            controller: _emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 22),

          // Label contraseña
          _buildLabel('Ingrese su contraseña:'),
          const SizedBox(height: 8),

          // Campo de contraseña
          _buildTextField(
            controller: _passwordController,
            hint: 'Password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF828282),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 35),

          // Botón Ingresar
          SizedBox(
            width: double.infinity, // Opcional: puedes dejar un width fijo grande como 250 si prefieres
            height: 52,
            child: ElevatedButton(
              onPressed: _onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DC130),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF4DC130).withOpacity(0.5),
              ),
              child: const Text(
                'Ingresar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // ¿Olvidaste la contraseña?
          const Text(
            '¿Olvidaste la contraseña?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF555555),
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          GestureDetector(
            onTap: () {
              // TODO: navegar a recuperar contraseña
            },
            child: const Text(
              'Recuperar contraseña',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4DC130),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4DC130),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),

          // ¿Aún no tienes cuenta? Regístrate
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Aún no tienes cuenta? ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF555555),
                  letterSpacing: 0.1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  'Regístrate',
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Widgets utilitarios
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF289217),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          letterSpacing: 0.2,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB0B0B0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
            borderSide: const BorderSide(
              color: Color(0xFF4DC130),
              width: 2.0,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
      ),
    );
  }
}
