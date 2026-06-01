import 'package:flutter/material.dart';

class SearchFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final String query;
  final Function(String) onQueryChanged;
  final VoidCallback onClear;
  final List<String> filtros;
  final int filtroSeleccionado;
  final Function(int) onFiltroChanged;
  final Color activeColor;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    required this.filtros,
    required this.filtroSeleccionado,
    required this.onFiltroChanged,
    this.activeColor = const Color(0xFF5AB639),
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    cursorColor: widget.activeColor,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: 'Buscar',
                      hintStyle: const TextStyle(color: Color(0xFF888888)),
                      suffixIcon: GestureDetector(
                        onTap: widget.onClear,
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF888888),
                          size: 18,
                        ),
                      ),
                    ),
                    onChanged: widget.onQueryChanged,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.activeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.activeColor, width: 2),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
        // Filtros scrollables horizontalmente
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: widget.filtros.length,
            itemBuilder: (context, index) {
              final label = widget.filtros[index];
              final isSelected = index == widget.filtroSeleccionado;
              return GestureDetector(
                onTap: () => widget.onFiltroChanged(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.activeColor
                        : const Color(0xFFECEBEB),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF555555),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
