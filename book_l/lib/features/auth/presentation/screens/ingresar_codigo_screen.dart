import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../widgets/auth_recovery_header.dart';
import '../widgets/auth_pro_tip.dart';

class IngresarCodigoScreen extends StatefulWidget {
  const IngresarCodigoScreen({super.key});

  @override
  State<IngresarCodigoScreen> createState() => _IngresarCodigoScreenState();
}

class _IngresarCodigoScreenState extends State<IngresarCodigoScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _start = 900;

  @override
  void initState() {
    super.initState();
    _startTimer();

    for (var node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getCodigo() {
    return _controllers.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthRecoveryHeader(
              title: 'Recuperar contraseña',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Introduce el código que te enviamos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revisa tu bandeja de entrada o spam.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        List.generate(6, (index) => _buildOTPField(index)),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DC130).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF616161),
                          ),
                          children: [
                            const TextSpan(text: 'El código expirará en '),
                            TextSpan(
                              text: _formatTime(_start),
                              style: const TextStyle(
                                color: Color(0xFF4DC130),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '¿No llegó el código?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF757575),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _start = 900;
                            });
                            _startTimer();
                          },
                          child: const Text(
                            'Volver a enviar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4DC130),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final codigo = getCodigo();

                          if (codigo.length == 6) {
                            Navigator.pushNamed(context, '/cambiar_password');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Completa el código'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DC130),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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

  Widget _buildOTPField(int index) {
    bool isFocused = _focusNodes[index].hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? const Color(0xFF4DC130) : const Color(0xFFE0E0E0),
          width: isFocused ? 2.5 : 1.5,
        ),
      ),
      child: SizedBox.expand(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center, // 🔥 FIX CURSOR
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2E2E2E),
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
              }
            } else {
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
                _controllers[index - 1].clear();
              }
            }
          },
        ),
      ),
    );
  }
}
