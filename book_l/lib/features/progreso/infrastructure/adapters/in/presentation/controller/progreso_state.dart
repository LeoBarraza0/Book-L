class ProgresoState {
  final int racha;
  final int capitulosCompletados;
  final int ejerciciosCompletados;
  final List<String> diasActividad;

  ProgresoState({
    this.racha = 0,
    this.capitulosCompletados = 0,
    this.ejerciciosCompletados = 0,
    this.diasActividad = const [],
  });
}
