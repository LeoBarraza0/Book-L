import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/auth_recovery_header.dart';
import '../widgets/auth_pro_tip.dart';
import '../controller/auth_controller.dart';
import 'mensaje_recuperacion_screen.dart';

class RecuperarCorreoScreen extends StatelessWidget {
  const RecuperarCorreoScreen({super.key});

  String _maskEmail(String? email) {
    if (email == null || !email.contains('@')) return 'No registrado';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name***@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = AuthController();
    final maskedEmail = _maskEmail(authCtrl.recoveryEmail);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthRecoveryHeader(
              title: 'Recuperar contraseña',
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),
                  const Text(
                    'Confirmación de correo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E2E2E),
                      fontFamily: 'Inter',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'El correo vinculado a tu cuenta es:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF94D684).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mail_outline, color: const Color(0xFF94D684)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            maskedEmail,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E2E2E),
                              fontFamily: 'Inter',
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          authCtrl.saveRecoveryAttempt('Correo');
                          try {
                            await authCtrl.generateRecoveryCode('Correo');
                            if (!context.mounted) return;
                            MensajeRecuperacionDialog.show(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    e.toString().replaceAll('Exception: ', '')),
                                backgroundColor: const Color(0xFFFF5252),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DC130),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF4DC130).withOpacity(0.5),
                        ),
                        child: const Text(
                          'Enviar código',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '¿No es correcto el correo?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF828282),
                            fontFamily: 'Inter',
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/recuperar_numero'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            'Usar número de teléfono',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4DC130),
                              fontFamily: 'Inter',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 45),
                  const AuthProTip(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
