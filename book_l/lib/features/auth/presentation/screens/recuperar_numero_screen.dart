import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/auth_recovery_header.dart';
import '../widgets/auth_pro_tip.dart';
import '../controller/auth_controller.dart';
import 'mensaje_recuperacion_screen.dart';

class RecuperarNumeroScreen extends StatelessWidget {
  const RecuperarNumeroScreen({super.key});

  String _maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'No registrado';
    if (phone.length < 7) return phone;
    final visible = phone.substring(phone.length - 2);
    final prefix = phone.substring(0, 7);
    return '$prefix******$visible';
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = AuthController();
    final maskedPhone = _maskPhone(authCtrl.recoveryPhone);

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
                    'Confirmación de número',
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
                    'El número vinculado a tu cuenta es:',
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
                          child: Icon(Icons.phone_android, color: const Color(0xFF94D684)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            maskedPhone,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E2E2E),
                              fontFamily: 'Inter',
                              letterSpacing: 2.0,
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
                          authCtrl.saveRecoveryAttempt('Numero');
                          try {
                            await authCtrl.generateRecoveryCode('Numero');
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
                          '¿No es correcto el número?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF828282),
                            fontFamily: 'Inter',
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/recuperar_correo'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            'Usar correo electrónico',
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
