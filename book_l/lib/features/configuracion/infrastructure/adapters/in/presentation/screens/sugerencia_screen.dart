import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controller/configuracion_controller.dart';

class SugerenciaScreen extends StatefulWidget {
  const SugerenciaScreen({super.key});

  @override
  State<SugerenciaScreen> createState() => _SugerenciaScreenState();
}

class _SugerenciaScreenState extends State<SugerenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _problemaController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _asuntoController.dispose();
    _problemaController.dispose();
    super.dispose();
  }

  Future<void> _enviarSugerencia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Delega el flujo de datos al controller, manteniendo la vista limpia
      await context.read<ConfiguracionController>().enviarSugerencia(
        _asuntoController.text,
        _problemaController.text,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Sugerencia enviada con éxito',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: const Color(0xFF44C040),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final inputFillColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF44C040),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Logo
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 40,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Main Form Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Sugerencias',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        Text(
                          'Asunto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _asuntoController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Escriba el asunto',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Color(0xFF44C040), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El asunto es obligatorio';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Describa el problema:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _problemaController,
                          maxLines: 5,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Describa detalladamente...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Color(0xFF44C040), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Debe describir el problema';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Adjuntar evidencias:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Decorative upload box simulating dashed border and icon
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: inputFillColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade400,
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          // Note: A true dashed border requires a custom painter or package (dotted_border),
                          // but a solid thin border is natively robust if package isn't added.
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_rounded,
                                  color: Colors.grey.shade500, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                'Cargar archivo',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Solo recibe formato pdf, jpg, doc, svg',
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _enviarSugerencia,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF44C040),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30), // Stadium shape
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Enviar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
