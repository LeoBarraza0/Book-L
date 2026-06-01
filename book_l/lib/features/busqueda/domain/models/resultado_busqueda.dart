import 'package:flutter/material.dart';

// Entidad pura de dominio (ResultadoBusqueda)
class ResultadoBusqueda {
  final int id;
  final String tipo;
  final String titulo;
  final String? subtitulo;
  final String? imagenUrl;
  final String? username; // para Autores: su @username
  final String? avatarUrl; // para Autores: URL del avatar
  final String calificacion;
  final int inscripciones;
  final double progreso;
  final Color colorTarjeta;

  const ResultadoBusqueda({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.subtitulo,
    this.imagenUrl,
    this.username,
    this.avatarUrl,
    this.calificacion = '0.0',
    this.inscripciones = 0,
    this.progreso = 0.0,
    required this.colorTarjeta,
  });
}
