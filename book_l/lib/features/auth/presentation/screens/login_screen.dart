import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/book_l_header.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ctrl = AuthController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //Función que se ejecuta cuando se presiona el botón de iniciar sesión
  Future<void> _onLogin() async {
    final correo = _emailController.text.trim();
    final pass = _passwordController.text;

    if (correo.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final ok = await _ctrl.iniciarSesion(correo, pass);
    //El mounted es para saber si el widget esta montado en el arbol de widgets
    if (!mounted) return;

    if (ok) {
      final role = BooklService().currentRole;
      Navigator.pushReplacementNamed(
          context, role == 'admin' ? '/admin_Home' : '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_ctrl.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: const Color(0xFFFF5252),
        ),
      );
      _ctrl.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BookLHeader(height: 400),
            _buildForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    var inputContrasena = CustomTextField(
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
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
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

          CustomTextField(
            controller: _emailController,
            label: 'Ingresa tu correo:',
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 22),

          inputContrasena,
          const SizedBox(height: 35),

          // ── Botón Ingresar con estado de carga ─────────────────────────
          ListenableBuilder(
            listenable: _ctrl,
            builder: (context, _) => CustomButton(
              label: _ctrl.isLoading ? 'Ingresando...' : 'Ingresar',
              onPressed: _ctrl.isLoading ? null : _onLogin,
            ),
          ),
          const SizedBox(height: 25),

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
            onTap: () async {
              final email = _emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  // Busca el usuario en la BD en memoria (BooklService) según arquitectura
                  final user = BooklService().usuarios.firstWhere((u) => u.correo == email);
                  
                  if (!mounted) return;
                  
                  final String phone = user.celular?.toString() ?? '';
                  _ctrl.setRecoveryData(email, phone);
                  Navigator.pushNamed(context, '/recuperar_correo');
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No existe una cuenta con este correo'),
                      backgroundColor: Color(0xFFFF5252),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa tu correo para recuperarlo'),
                    backgroundColor: Color(0xFFFF5252),
                  ),
                );
              }
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
