import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback?
      onClear; // opcional, si quieres hacer algo extra al limpiar

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Campo de búsqueda
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: TextField(
                controller: controller,
                cursorColor: const Color(0xFF5AB639),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: '|',
                  hintStyle: const TextStyle(color: Color(0xFF888888)),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      controller.clear();
                      onClear?.call();
                    },
                    child: const Icon(Icons.close,
                        color: Color(0xFF888888), size: 18),
                  ),
                ),
                onChanged: (_) =>
                    onClear?.call(), // si quieres reaccionar al escribir
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón lupa
          GestureDetector(
            onTap: onSearch,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF5AB639),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5AB639), width: 2),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
