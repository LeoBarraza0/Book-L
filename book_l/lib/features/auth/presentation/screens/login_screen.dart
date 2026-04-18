import 'package:flutter/material.dart';
import '../../../../shared/widgets/book_l_header.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

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
    // Te lleva directamente al HomeScreen por ahora
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header reutilizable con logo ───────────────────────────
            const BookLHeader(height: 400),

            // ── Formulario de login ────────────────────────────────────
            _buildForm(context),
          ],
        ),
      ),
    );
  }

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

          // Campo correo — usa widget compartido
          CustomTextField(
            controller: _emailController,
            label: 'Ingresa tu correo:',
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 22),

          // Campo contraseña — usa widget compartido
          CustomTextField(
            controller: _passwordController,
            label: 'Ingrese su contraseña:',
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

          // Botón Ingresar — usa widget compartido
          CustomButton(label: 'Ingresar', onPressed: _onLogin),
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
                onTap: () => Navigator.pushNamed(context, '/register'),
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
}
