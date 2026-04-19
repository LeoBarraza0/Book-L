// Estados posibles para cualquier operación con listas de datos.
// Compartido entre CursoController y LeccionController.

enum DataStatus { initial, loading, loaded, error }

class DataState<T> {
  final DataStatus status;
  final List<T> items;
  final T? selected;       // ítem actualmente seleccionado (detalle)
  final String? errorMessage;

  const DataState({
    this.status = DataStatus.initial,
    this.items = const [],
    this.selected,
    this.errorMessage,
  });

  DataState<T> copyWith({
    DataStatus? status,
    List<T>? items,
    T? selected,
    String? errorMessage,
  }) {
    return DataState<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      selected: selected ?? this.selected,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == DataStatus.loading;
  bool get isLoaded => status == DataStatus.loaded;
  bool get hasError => status == DataStatus.error;
}
