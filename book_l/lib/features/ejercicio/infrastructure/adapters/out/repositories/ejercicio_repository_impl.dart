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
  Future<void> addEjercicio(
      Ejercicio ejercicio, List<Pregunta> preguntas, List<Opcion> opciones) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
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

        final insertedEj = EjercicioDto.fromJson(ejRes);
        _service.addEjercicio(insertedEj);

        // Agregar preguntas y opciones
        for (var p in preguntas) {
          final pRes = await SupabaseClientHelper.client
              .from('tbl_pregunta')
              .insert({
                'idejerciciofk': insertedEj.idEjercicio,
                'contenido': p.contenido,
                'explicacion': p.explicacion,
              })
              .select()
              .single();

          final localP = Pregunta(
            idPregunta: pRes['idpregunta'],
            idEjercicioFk: insertedEj.idEjercicio,
            contenido: p.contenido,
            explicacion: p.explicacion,
            opciones: p.opciones,
          );
          _service.addPregunta(localP);

          final ops = opciones.where((o) => o.idPreguntaFk == p.idPregunta);
          for (var o in ops) {
            final oRes = await SupabaseClientHelper.client
                .from('tbl_opcion')
                .insert({
                  'idpreguntafk': pRes['idpregunta'],
                  'contenido': o.contenido,
                  'correcta': o.correcta,
                })
                .select()
                .single();

            final localO = Opcion(
              idOpcion: oRes['idopcion'],
              idPreguntaFk: pRes['idpregunta'],
              contenido: o.contenido,
              correcta: o.correcta,
            );
            _service.addOpcion(localO);
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error insert Ejercicio Supabase: $e');
      }
    } else {
      // Persiste opciones
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
        if (kDebugMode) print('Error remove Ejercicio Supabase: $e');
      }
    }
    _service.removeEjercicio(idEjercicio);
  }
}
