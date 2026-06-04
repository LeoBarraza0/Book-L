import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/features/ejercicio/domain/models/pregunta.dart';
import 'package:book_l/features/ejercicio/domain/models/opcion.dart';
import 'package:book_l/features/ejercicio/application/ports/out/ejercicio_repository.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/out/dtos/ejercicio_dto.dart';
import 'package:flutter/foundation.dart';

/// Implementación del repositorio de ejercicios.
class EjercicioRepositoryImpl implements EjercicioRepository {
  final BooklService _service = BooklService();

  @override
  Set<int> getCapituloIdsByLeccion(int idLeccion) {
    return _service.capitulos
        .where((c) => c.idLeccion == idLeccion)
        .map((c) => c.idCapitulo)
        .toSet();
  }

  @override
  List<Ejercicio> getEjerciciosByCapitulos(Set<int> idsCapitulos) {
    return _service.ejercicios
        .where((e) => idsCapitulos.contains(e.idCapitulo))
        .toList();
  }

  @override
  List<int> getExerciseIdsByCapitulo(int idCapitulo) {
    return _service.ejercicios
        .where((e) => e.idCapitulo == idCapitulo)
        .map((e) => e.idEjercicio)
        .toList();
  }

  @override
  int nextEjercicioId() => _service.nextEjercicioId();

  @override
  int nextPreguntaId() => _service.nextPreguntaId();

  @override
  int nextOpcionId() => _service.nextOpcionId();

  @override
  Future<void> addEjercicio(Ejercicio ejercicio, List<Pregunta> preguntas,
      List<Opcion> opciones) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        // 1. Insertar ejercicio en Supabase
        debugPrint('[EjercicioRepo] Insertando ejercicio: ${ejercicio.titulo}, '
            'tipo: ${ejercicio.tipo.name}, idCapitulo: ${ejercicio.idCapitulo}');

        final ejRes = await SupabaseClientHelper.client
            .from('tbl_ejercicio')
            .insert({
              'idcapitulo': ejercicio.idCapitulo,
              'tipo': ejercicio.tipo.name,
              'titulo': ejercicio.titulo,
              'descripcion': ejercicio.descripcion,
            })
            .select()
            .single();

        debugPrint('[EjercicioRepo] Ejercicio insertado en Supabase: $ejRes');

        final insertedEj = EjercicioDto.fromJson(ejRes);
        final int supabaseEjId = insertedEj.idEjercicio;

        // 2. Insertar preguntas y opciones secuencialmente
        final List<Pregunta> preguntasConIds = [];
        final List<Opcion> opcionesConIds = [];

        for (var p in preguntas) {
          debugPrint('[EjercicioRepo] Insertando pregunta: ${p.contenido}');

          final pRes = await SupabaseClientHelper.client
              .from('tbl_pregunta')
              .insert({
                'idejerciciofk': supabaseEjId,
                'contenido': p.contenido,
                'explicacion': p.explicacion,
              })
              .select()
              .single();

          debugPrint('[EjercicioRepo] Pregunta insertada: $pRes');

          final int supabasePregId = pRes['idpregunta'] as int;

          // Buscar opciones que corresponden a esta pregunta por el ID local
          final opsForPregunta =
              opciones.where((o) => o.idPreguntaFk == p.idPregunta).toList();
          debugPrint(
              '[EjercicioRepo] Opciones para pregunta ${p.idPregunta}: ${opsForPregunta.length}');

          final List<Opcion> opcionesDePregunta = [];
          for (var o in opsForPregunta) {
            final oRes = await SupabaseClientHelper.client
                .from('tbl_opcion')
                .insert({
                  'idpreguntafk': supabasePregId,
                  'contenido': o.contenido,
                  'correcta': o.correcta,
                })
                .select()
                .single();

            debugPrint('[EjercicioRepo] Opcion insertada: $oRes');

            final localO = Opcion(
              idOpcion: oRes['idopcion'] as int,
              idPreguntaFk: supabasePregId,
              contenido: o.contenido,
              correcta: (oRes['correcta'] is int)
                  ? oRes['correcta'] == 1
                  : oRes['correcta'] == true,
            );
            opcionesDePregunta.add(localO);
            opcionesConIds.add(localO);
          }

          final localP = Pregunta(
            idPregunta: supabasePregId,
            idEjercicioFk: supabaseEjId,
            contenido: p.contenido,
            explicacion: p.explicacion,
            opciones: opcionesDePregunta,
          );
          preguntasConIds.add(localP);
        }

        // 3. Crear ejercicio final con preguntas y opciones reales de Supabase
        final ejercicioFinal = Ejercicio(
          idEjercicio: supabaseEjId,
          idCapitulo: insertedEj.idCapitulo,
          tipo: insertedEj.tipo,
          titulo: insertedEj.titulo,
          descripcion: insertedEj.descripcion,
          preguntas: preguntasConIds,
        );

        // 4. Guardar en memoria local
        _service.ejercicios.add(ejercicioFinal);
        _service.preguntas.addAll(preguntasConIds);
        _service.opciones.addAll(opcionesConIds);

        // Actualizar capítulo si existe
        final capIdx = _service.capitulos
            .indexWhere((c) => c.idCapitulo == ejercicioFinal.idCapitulo);
        if (capIdx != -1) {
          final cap = _service.capitulos[capIdx];
          _service.capitulos[capIdx] = cap.copyWith(
            ejercicios: [...cap.ejercicios, ejercicioFinal],
          );
        }

        _service.save();
        _service.notifyListeners();

        debugPrint(
            '[EjercicioRepo] Ejercicio guardado localmente y notificado. '
            'Total ejercicios: ${_service.ejercicios.length}');
      } catch (e, stackTrace) {
        debugPrint(
            '[EjercicioRepo] ERROR insertando ejercicio en Supabase: $e');
        debugPrint('[EjercicioRepo] StackTrace: $stackTrace');
        // Fallback: guardar localmente sin Supabase
        _service.addEjercicio(ejercicio);
        for (final p in preguntas) {
          _service.addPregunta(p);
        }
        for (final o in opciones) {
          _service.addOpcion(o);
        }
      }
    } else {
      // Sin Supabase: persistir localmente
      for (final o in opciones) {
        _service.addOpcion(o);
      }
      // Persiste preguntas
      for (final p in preguntas) {
        _service.addPregunta(p);
      }
      // Persiste ejercicio
      _service.addEjercicio(ejercicio);
    }
  }

  @override
  Future<void> removeEjercicio(int idEjercicio) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_ejercicio')
            .delete()
            .eq('idejercicio', idEjercicio);
      } catch (e) {
        debugPrint('[EjercicioRepo] Error eliminando ejercicio: $e');
      }
    }
    _service.removeEjercicio(idEjercicio);
  }

  @override
  Future<void> guardarRespuesta(int idUsuario, int idPregunta, int? idOpcion, bool correcta) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client.from('tbl_respuesta_usuario').insert({
          'id_usuario': idUsuario,
          'id_pregunta': idPregunta,
          if (idOpcion != null) 'id_opcion': idOpcion,
          'correcta': correcta,
        });
      } catch (e) {
        if (kDebugMode) print('Error insertando respuesta de usuario en Supabase: $e');
      }
    }
  }
}
