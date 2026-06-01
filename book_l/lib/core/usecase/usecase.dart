abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {
  const NoParams();
}

/// Representa una relación <<include>> de UML en el código.
/// Indica que este caso de uso incorpora de forma obligatoria la ejecución
/// de otro caso de uso de soporte.
abstract class UMLInclude<IncludedUseCase> {
  IncludedUseCase get includedUseCase;
}

/// Representa una relación <<extend>> de UML en el código.
/// Indica que este caso de uso extiende el comportamiento
/// de otro caso de uso base bajo ciertas condiciones.
abstract class UMLExtend<BaseUseCase> {
  BaseUseCase get baseUseCase;
  bool shouldExtend(dynamic context);
}

