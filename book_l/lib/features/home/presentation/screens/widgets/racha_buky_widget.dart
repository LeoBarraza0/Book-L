import 'package:flutter/material.dart';
import '../../../../../core/services/bookl_service.dart';
import '../../../../../core/storage/local_storage.dart';

/// Widget funcional de "Racha Buky".
///
/// Muestra los 7 días de la semana actual y marca en verde aquellos
/// en los que el usuario realizó alguna actividad (completar o crear
/// lecciones/cursos). Se actualiza reactivamente vía [BooklService].
class RachaBukyWidget extends StatelessWidget {
  const RachaBukyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BooklService(),
      builder: (context, _) {
        final userId = AppSession().usuarioId ?? 0;
        final rachaData = BooklService().getRacha(userId);
        final diasActividad = rachaData != null
            ? List<String>.from(rachaData['dias_actividad'] ?? [])
            : <String>[];
        final rachaActual = rachaData?['racha_actual'] ?? 0;

        // Calcular los 7 días de la semana actual (Lunes → Domingo)
        final ahora = DateTime.now();
        // weekday: 1 = Lunes, 7 = Domingo
        final lunes = ahora.subtract(Duration(days: ahora.weekday - 1));

        final diasSemana = List.generate(7, (i) {
          final dia = lunes.add(Duration(days: i));
          return dia;
        });

        // Letras para mostrar (D=Domingo al inicio como layout original)
        // Layout original: D, L, M, M, J, V, S
        // Reordenamos: ponemos domingo primero
        final diasOrdenados = [
          diasSemana[6], // Domingo
          diasSemana[0], // Lunes
          diasSemana[1], // Martes
          diasSemana[2], // Miércoles
          diasSemana[3], // Jueves
          diasSemana[4], // Viernes
          diasSemana[5], // Sábado
        ];
        final letras = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

        // Verificar cuáles días tienen actividad
        final logrados = diasOrdenados.map((dia) {
          final diaStr =
              '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
          return diasActividad.contains(diaStr);
        }).toList();

        // Verificar si la racha está viva (actividad hoy o ayer)
        final hoyStr =
            '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
        final ayer = ahora.subtract(const Duration(days: 1));
        final ayerStr =
            '${ayer.year}-${ayer.month.toString().padLeft(2, '0')}-${ayer.day.toString().padLeft(2, '0')}';
        final rachaViva =
            diasActividad.contains(hoyStr) || diasActividad.contains(ayerStr);

        final rachaParaMostrar = rachaViva ? rachaActual : 0;

        // Texto motivacional dinámico
        String textoMotivacional;
        if (rachaParaMostrar == 0) {
          textoMotivacional =
              '¡Completa una lección o crea contenido hoy para iniciar tu racha!';
        } else if (rachaParaMostrar < 3) {
          textoMotivacional =
              '¡Llevas $rachaParaMostrar día${rachaParaMostrar > 1 ? 's' : ''} de racha! ¡Sigue así!';
        } else if (rachaParaMostrar < 7) {
          textoMotivacional =
              '¡Increíble! $rachaParaMostrar días seguidos aprendiendo. ¡No pares!';
        } else {
          textoMotivacional =
              '🔥 ¡$rachaParaMostrar días de racha! ¡Tu Buky está feliz!';
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Avatar Buky (Búho verde)
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF96D786),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/racha.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.pets,
                          color: Colors.green,
                          size: 40),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Textos y Racha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rachaParaMostrar > 0
                          ? '¡Racha de $rachaParaMostrar día${rachaParaMostrar > 1 ? 's' : ''}! 🔥'
                          : '¡Saluda a tu Racha Buky!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      textoMotivacional,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Círculos de días
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final esHoy = _esHoy(diasOrdenados[index], ahora);
                        return Column(
                          children: [
                            Text(
                              letras[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: esHoy
                                    ? const Color(0xFF4DC130)
                                    : const Color(0xFF5A5757),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: logrados[index]
                                    ? const Color(0xFF96D786)
                                    : const Color(0xFFB0B0B0),
                                border: esHoy
                                    ? Border.all(
                                        color: const Color(0xFF4DC130),
                                        width: 2)
                                    : null,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _esHoy(DateTime dia, DateTime ahora) {
    return dia.year == ahora.year &&
        dia.month == ahora.month &&
        dia.day == ahora.day;
  }
}
