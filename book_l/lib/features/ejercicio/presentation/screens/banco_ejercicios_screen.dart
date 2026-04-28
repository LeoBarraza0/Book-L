import 'package:flutter/material.dart';
import '../../../../shared/widgets/search_filter_bar.dart';
import '../controller/ejercicios_controller.dart';
import '../../domain/entities/ejercicio.dart';
import 'teorico_screen.dart';
import 'package:book_l/core/storage/local_storage.dart';

class BancoEjerciciosScreen extends StatefulWidget {
  final int idLeccion;
  final String title;
  final String? categoriaFiltro;

  const BancoEjerciciosScreen({super.key, required this.idLeccion, required this.title, this.categoriaFiltro});

  @override
  State<BancoEjerciciosScreen> createState() => _BancoEjerciciosScreenState();
}

class _BancoEjerciciosScreenState extends State<BancoEjerciciosScreen> {
  final EjerciciosController _ctrl = EjerciciosController();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadEjercicios(widget.idLeccion);
      // Pre-filtrar por tipo si viene especificado
      if (widget.categoriaFiltro != null) {
        _ctrl.setCategoriaFiltro(widget.categoriaFiltro);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _getColorForTipo(TipoEjercicio tipo) {
    switch (tipo) {
      case TipoEjercicio.multipleChoice:
        return const Color(0xFF4DC130);
      case TipoEjercicio.trueFalse:
        return const Color(0xFFF6B55C);
      case TipoEjercicio.ordenar:
        return const Color(0xFF4DB0FF);
      case TipoEjercicio.rellenar:
        return const Color(0xFFFF606F);
      case TipoEjercicio.respuestaCorta:
        return const Color(0xFF9B51E0);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6BCA54).withValues(alpha: 0.41),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) {
          final ejercicios = _ctrl.filteredEjercicios;

          return Column(
            children: [
              // Search and Filters
              SearchFilterBar(
                searchController: _searchCtrl,
                query: _ctrl.searchQuery,
                onQueryChanged: _ctrl.updateQuery,
                onClear: () {
                  _searchCtrl.clear();
                  _ctrl.clearSearch();
                },
                filtros: _ctrl.filtrosActivos,
                filtroSeleccionado: _ctrl.selectedFilterIndex,
                onFiltroChanged: _ctrl.setFilter,
              ),
              const SizedBox(height: 16),
              
              // Exercise List
              Expanded(
                child: ejercicios.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron ejercicios.',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 40),
                        shrinkWrap: true,
                        itemCount: ejercicios.length,
                        itemBuilder: (context, index) {
                          final e = ejercicios[index];
                          final colorBase = _getColorForTipo(e.tipo);
                          
                          return ListenableBuilder(
                            listenable: AppSession().completedEjercicios,
                            builder: (context, _) {
                              final isCompleted = AppSession().completedEjercicios.value.contains(e.idEjercicio);
                              final progressValue = isCompleted ? 1.0 : 0.0;
                              final progressText = isCompleted ? '100%' : '0%';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Left Column (Texts)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorBase,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          e.tipo.displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        e.titulo,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${e.preguntas.length} preguntas',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        e.descripcion,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Right Column (Progress + Play button)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                     Stack(
                                       alignment: Alignment.center,
                                       children: [
                                         SizedBox(
                                           width: 44,
                                           height: 44,
                                           child: CircularProgressIndicator(
                                             value: progressValue,
                                             backgroundColor: colorBase.withValues(alpha: 0.2),
                                             color: colorBase,
                                             strokeWidth: 4,
                                           ),
                                         ),
                                         Text(
                                          progressText,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                       ],
                                     ),
                                     const SizedBox(height: 16),
                                     GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => TeoricoScreen(ejercicio: e)),
                                          );
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: colorBase,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorBase.withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
              ),
            ],
          );
        },
      ),
    );
  }
}
