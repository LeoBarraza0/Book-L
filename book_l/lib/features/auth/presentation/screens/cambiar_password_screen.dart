import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/auth_recovery_header.dart';
import '../widgets/auth_pro_tip.dart';

class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _hasEightChars = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  void _validatePassword(String value) {
    setState(() {
      _hasEightChars = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _passwordsMatch =
          value == _confirmPassController.text && value.isNotEmpty;
    });
  }

  void _validateConfirm(String value) {
    setState(() {
      _passwordsMatch = value == _newPassController.text && value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthRecoveryHeader(
              title: 'Nueva contraseña',
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Establece tu nueva contraseña:',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E2E2E),
                      fontFamily: 'Inter',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Nueva contraseña:'),
                  _buildPasswordField(
                    controller: _newPassController,
                    obscure: _obscureNew,
                    onChanged: _validatePassword,
                    toggleObscure: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 15),
                  _buildStrengthIndicator(),
                  
                  const SizedBox(height: 25),
                  _buildLabel('Requisitos mínimos:'),
                  _buildCheckItem('Mínimo 8 caracteres', _hasEightChars),
                  _buildCheckItem('Al menos una mayúscula', _hasUppercase),
                  _buildCheckItem(
                      'Un carácter especial (!@#)', _hasSpecialChar),
                      
                  const SizedBox(height: 30),
                  _buildLabel('Confirmar contraseña:'),
                  _buildPasswordField(
                    controller: _confirmPassController,
                    obscure: _obscureConfirm,
                    onChanged: _validateConfirm,
                    toggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 10),
                  _buildCheckItem('Las contraseñas coinciden', _passwordsMatch),
                  
                  const SizedBox(height: 45),
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_hasEightChars &&
                                _hasUppercase &&
                                _hasSpecialChar &&
                                _passwordsMatch)
                            ? () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DC130),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          disabledBackgroundColor: Colors.grey[300],
                          shadowColor: const Color(0xFF4DC130).withOpacity(0.5),
                        ),
                        child: const Text(
                          'Cambiar contraseña',
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF616161),
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required Function(String) onChanged,
    required VoidCallback toggleObscure,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14.0),
            child: SvgPicture.asset(
              'assets/images/padlock_icon.svg',
              colorFilter: const ColorFilter.mode(
                Color(0xFF4DC130),
                BlendMode.srcIn,
              ),
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFFBDBDBD), size: 22),
            onPressed: toggleObscure,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color:
                  isChecked ? const Color(0xFF4DC130) : const Color(0xFFE5E5E5),
              shape: BoxShape.circle,
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
              color:
                  isChecked ? const Color(0xFF2E2E2E) : const Color(0xFF828282),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    int points = 0;
    if (_hasEightChars) points++;
    if (_hasUppercase) points++;
    if (_hasSpecialChar) points++;

    Color color;
    String label;
    double width;

    if (_newPassController.text.isEmpty) {
      color = const Color(0xFFE0E0E0);
      label = 'Esperando...';
      width = 0.1;
    } else if (points == 0) {
      color = const Color(0xFFFF5252); // Rojo
      label = 'Insegura';
      width = 0.2;
    } else if (points == 1) {
      color = const Color(0xFFFF9800); // Naranja
      label = 'Débil';
      width = 0.4;
    } else if (points == 2) {
      color = const Color(0xFFFDCD51); // Amarillo
      label = 'Media';
      width = 0.7;
    } else {
      color = const Color(0xFF4DC130); // Verde
      label = 'Fuerte';
      width = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Seguridad: ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
                fontFamily: 'Inter',
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: width,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
