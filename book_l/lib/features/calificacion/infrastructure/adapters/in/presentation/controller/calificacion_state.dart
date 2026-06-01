class CalificacionState {
  final bool isLoading;
  final String? error;
  final double? nuevoRating;
  final bool isUpdate;

  CalificacionState({
    this.isLoading = false,
    this.error,
    this.nuevoRating,
    this.isUpdate = false,
  });

  CalificacionState copyWith({
    bool? isLoading,
    String? error,
    double? nuevoRating,
    bool? isUpdate,
  }) {
    return CalificacionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      nuevoRating: nuevoRating ?? this.nuevoRating,
      isUpdate: isUpdate ?? this.isUpdate,
    );
  }
}
