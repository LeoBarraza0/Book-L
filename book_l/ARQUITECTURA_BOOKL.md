# Arquitectura y Estructura de Carpetas — Book-L

> **Propósito de este documento:** Servir como referencia canónica para cualquier agente o desarrollador que trabaje sobre el proyecto Book-L. Define la arquitectura adoptada, justifica cada decisión estructural y establece la correspondencia entre las carpetas del proyecto Flutter y las tablas del modelo relacional MySQL. **No tomar decisiones de estructura sin consultar este documento.**

---

## 1. Arquitectura adoptada: Clean Architecture orientada a migración hexagonal

El proyecto implementa **Clean Architecture por features**, con nomenclatura y separación de responsabilidades deliberadamente alineadas con **Arquitectura Hexagonal**, de modo que una futura migración sea un proceso de renombrado y reorganización, no de reescritura.

### Principio fundamental de dependencias

```
presentation/  →  domain/  ←  data/
```

- `domain/` **nunca** importa nada de `data/` ni de `presentation/`.
- `data/` conoce `domain/` (implementa sus interfaces).
- `presentation/` conoce `domain/` (consume sus casos de uso).
- Si en un archivo dentro de `domain/` aparece un import de `dio`, `flutter`, `shared_preferences` o cualquier paquete externo, es un error arquitectural.

### Correspondencia con Arquitectura Hexagonal (migración futura)

| Clean Architecture (hoy) | Hexagonal (futuro) |
|---|---|
| `domain/repositories/` (interfaz) | Puerto de salida (Outbound Port) |
| `domain/usecases/` | Puerto de entrada (Inbound Port) |
| `data/repositories/` (impl) | Adaptador secundario |
| `presentation/controller/` | Adaptador primario |
| `data/dto/` | DTO del adaptador secundario |

Cuando se migre, el movimiento será: renombrar `repositories/` a `ports/outbound/`, mover `presentation/controller/` a `adapters/primary/`, y mover `data/` a `adapters/secondary/`.

---

## 2. Estructura completa de `lib/`

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── error/
│   │   ├── exception.dart
│   │   └── failure.dart
│   ├── network/
│   │   └── dio_client.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── storage/
│   │   └── local_storage.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── utils/
│       ├── date_formatter.dart
│       ├── extensions.dart
│       └── validators.dart
├── shared/
│   └── widgets/
│       ├── book_l_header.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── empty_state.dart
│       ├── loading_indicator.dart
│       └── nav_bar.dart
└── features/
    ├── auth/
    ├── busqueda/
    ├── calificacion/
    ├── chatbot/
    ├── configuracion/
    ├── curso/
    ├── discusion/
    ├── ejercicio/
    ├── guardado/
    ├── home/
    ├── leccion/
    ├── notificacion/
    ├── perfil/
    └── progreso/
```

---

## 3. Capa `core/` — Infraestructura transversal

Todo lo que no pertenece a ninguna feature de negocio pero que todas necesitan.

### `core/error/`
Manejo de errores en dos niveles:

- **`exception.dart`** — Excepciones técnicas que lanza la capa `data/`. Ejemplos: `ServerException`, `CacheException`, `AuthException`. Son capturadas dentro de los `repository_impl` y convertidas en `Failure`.
- **`failure.dart`** — Errores de negocio que el dominio expone hacia `presentation/`. Ejemplos: `ServerFailure`, `NetworkFailure`, `AuthFailure`, `NotFoundFailure`. Son el resultado del tipo `Either<Failure, T>` que devuelven los casos de uso.

> **Regla:** `data/` lanza `Exception`. `domain/` devuelve `Failure`. `presentation/` solo ve `Failure`.

### `core/usecase/`
- **`usecase.dart`** — Clase abstracta base `UseCase<Type, Params>` con método `call`. También define `NoParams` para casos de uso sin argumentos. Todos los archivos `*_usecase.dart` del proyecto heredan de esta clase.

### `core/network/`
- **`dio_client.dart`** — Instancia configurada de Dio con: URL base de la API, timeouts, interceptor que lee `AppSession().token` e inyecta el header `Authorization: Bearer <token>`, e interceptor de errores globales (401 redirige a login, 500 lanza `ServerException`).

### `core/storage/`
- **`local_storage.dart`** — Contiene el Singleton `AppSession` que gestiona SharedPreferences. Almacena en memoria y en disco: token JWT, id del usuario, nombre completo, rol y preferencias básicas (tema, idioma). Se inicializa en `main.dart` antes de `runApp()`.

> **Regla de SharedPreferences:** Solo se persisten datos pequeños necesarios antes de cualquier llamada a la API. No se guardan listas, colecciones ni datos de negocio. Ver sección 6 para detalle.

### `core/router/`
- **`app_router.dart`** — Configuración de GoRouter con todas las rutas de la aplicación. Incluye `redirect` global que verifica `AppSession().estaLogueado` para proteger rutas privadas.

### `core/theme/`
- **`app_colors.dart`** — Paleta de colores de Book-L (primario `#175e7a`, secundario, fondos, errores).
- **`app_theme.dart`** — `ThemeData` claro y oscuro que consume `AppColors`. El tema activo se lee desde `AppSession().temaOscuro`.

### `core/utils/`
- **`validators.dart`** — Funciones de validación puras: correo, contraseña, celular.
- **`extensions.dart`** — Extensiones de Dart: `String`, `DateTime`, `List`.
- **`date_formatter.dart`** — Formateo de fechas legible en español.

---

## 4. Capa `shared/` — Widgets reutilizables entre features

> **Importante:** `shared/` no tiene relación con SharedPreferences. El nombre refiere a "compartido entre features".

Widgets Flutter que se usan en más de una feature. No contienen lógica de negocio.

| Archivo | Descripción | Lo usan |
|---|---|---|
| `custom_button.dart` | Botón principal con estilo Book-L y estado de carga | auth, ejercicio, configuracion, perfil |
| `custom_text_field.dart` | Input con validación visual e ícono | auth, perfil, discusion, busqueda |
| `loading_indicator.dart` | Spinner/shimmer de carga | todas las features con llamadas a API |
| `empty_state.dart` | Pantalla vacía con ícono y mensaje configurable | guardado, notificacion, discusion, busqueda |
| `book_l_header.dart` | Header superior con logo/título de la app | home, leccion, curso |
| `nav_bar.dart` | Barra de navegación inferior | home, leccion, curso, perfil, guardado |

---

## 5. Capa `features/` — Módulos de negocio

Cada feature encapsula un dominio de negocio completo. La estructura interna es idéntica en todas:

```
feature_name/
├── domain/
│   ├── entities/       ← Objetos de negocio puros (sin JSON, sin Flutter)
│   ├── repositories/   ← Interfaces abstractas (contratos / futuros puertos outbound)
│   └── usecases/       ← Lógica de negocio (futuros puertos inbound)
├── data/
│   ├── dto/            ← Traductores JSON ↔ Entity
│   └── repositories/   ← Implementaciones concretas (futuros adaptadores secundarios)
└── presentation/
    ├── controller/     ← Estado y orquestación (futuros adaptadores primarios)
    ├── screens/        ← Pantallas Flutter (solo dibujan)
    └── widgets/        ← Widgets propios de la feature
```

---

## 6. Correspondencia features ↔ tablas del modelo relacional

### `features/auth/`
**Tablas:** `Tbl_usuario`

| Capa | Archivo | Responsabilidad |
|---|---|---|
| `domain/entities/` | `usuario.dart` | Entidad con: id, nombreCompleto, correo, rol, programa, semestre, activo |
| `domain/repositories/` | `auth_repository.dart` | Contrato: login, register, logout |
| `domain/usecases/` | `login_usecase.dart` | Valida credenciales y persiste sesión via AppSession |
| `domain/usecases/` | `register_usecase.dart` | Crea nuevo usuario |
| `domain/usecases/` | `logout_usecase.dart` | Limpia AppSession y redirige |
| `data/dto/` | `usuario_dto.dart` | Mapea JSON de la API al entity `Usuario` |
| `data/repositories/` | `auth_repository_impl.dart` | Llama al endpoint de auth y guarda sesión |
| `presentation/controller/` | `auth_controller.dart` / `auth_state.dart` | Estados: Initial, Loading, Authenticated, Error |
| `presentation/screens/` | `login_screen.dart` | Pantalla de inicio de sesión |
| `presentation/screens/` | `register_screen.dart` | Pantalla de registro |

---

### `features/leccion/`
**Tablas:** `Tbl_leccion`, `Tbl_capitulo`, `Tbl_material`

Estas tres tablas se agrupan en una sola feature porque en la UI siempre aparecen juntas: una lección contiene capítulos, y cada capítulo tiene materiales.

| Capa | Archivo | Tabla origen |
|---|---|---|
| `domain/entities/` | `leccion.dart` | `Tbl_leccion` |
| `domain/entities/` | `capitulo.dart` | `Tbl_capitulo` |
| `domain/entities/` | `material_educativo.dart` | `Tbl_material` |
| `data/dto/` | `leccion_dto.dart` | `Tbl_leccion` |
| `data/dto/` | `capitulo_dto.dart` | `Tbl_capitulo` |
| `data/dto/` | `material_dto.dart` | `Tbl_material` (incluye campo `Tipo`: video/pdf/enlace/SCORM) |
| `presentation/screens/` | `leccion_list_screen.dart` | Lista de lecciones |
| `presentation/screens/` | `leccion_detail_screen.dart` | Detalle con capítulos |
| `presentation/screens/` | `capitulo_screen.dart` | Vista de capítulo con materiales |
| `presentation/widgets/` | `material_viewer.dart` | Renderiza según `Tipo` del material |
| `presentation/widgets/` | `progreso_bar.dart` | Muestra `Porcentaje_capitulo` de `Tbl_progreso_usuario` |

**Nota sobre `Estado` en lecciones:** `Tbl_leccion` tiene `Estado ENUM('activa','inactiva','en_revision','suspendida')`. La pantalla `leccion_list_screen` solo muestra lecciones con `estado == 'activa'`. El cambio de estado es responsabilidad del backend cuando se acumulan reportes (ver `features/reporte`).

---

### `features/curso/`
**Tablas:** `Tbl_curso`, `Tbl_lecciones_cursos`

`Tbl_lecciones_cursos` es la tabla pivote M:N. No tiene entidad propia; el repositorio la maneja internamente al construir la entidad `Curso` con su lista de lecciones.

| Archivo | Responsabilidad |
|---|---|
| `curso.dart` | Entidad con lista de `Leccion` incluida |
| `curso_dto.dart` | Mapea curso + lecciones anidadas desde la API |
| `curso_list_screen.dart` | Catálogo de cursos disponibles |
| `curso_detail_screen.dart` | Detalle con lecciones del curso |
| `curso_card.dart` | Tarjeta visual de un curso en la lista |

---

### `features/ejercicio/`
**Tablas:** `Tbl_ejercicio`, `Tbl_pregunta`, `Tbl_opcion`, `Tbl_respuesta_usuario`

Cadena de dependencia directa: ejercicio → preguntas → opciones → respuesta del usuario.

| Archivo | Tabla origen |
|---|---|
| `ejercicio.dart` | `Tbl_ejercicio` (con `Tipo ENUM`) |
| `pregunta.dart` | `Tbl_pregunta` |
| `opcion.dart` | `Tbl_opcion` (con campo `Correcta`) |
| `respuesta_usuario.dart` | `Tbl_respuesta_usuario` |
| `ejercicio_dto.dart` | `Tbl_ejercicio` + `Tbl_pregunta` + `Tbl_opcion` anidados |
| `respuesta_dto.dart` | `Tbl_respuesta_usuario` |
| `pregunta_widget.dart` | Renderiza según `Tipo`: multiple_choice, true_false, ordenar, rellenar, respuesta_corta |
| `opcion_tile.dart` | Una opción seleccionable |
| `resultado_widget.dart` | Muestra resultado tras completar ejercicio |

---

### `features/discusion/`
**Tablas:** `Tbl_discusion`, `Tbl_comentario`

`Tbl_comentario` tiene auto-referencia (`Id_padre`) para comentarios anidados (respuestas a comentarios). El widget `comentario_tile.dart` debe manejar recursividad o dos niveles de profundidad.

---

### `features/perfil/`
**Tablas:** `Tbl_usuario` (perfil público), `Tbl_seguidores`

Distinto de `auth/`: mientras `auth` gestiona sesión, `perfil` gestiona la vista pública del usuario y la red social (seguir/dejar de seguir).

| Archivo | Responsabilidad |
|---|---|
| `perfil.dart` | Subconjunto público de `Tbl_usuario` |
| `seguidor.dart` | Relación de `Tbl_seguidores` con `Estado ENUM('activo','pendiente','bloqueado')` |
| `seguidores_screen.dart` | Lista de seguidores y seguidos |
| `editar_perfil.dart` | Modificar datos de `Tbl_usuario` |

---

### `features/progreso/`
**Tablas:** `Tbl_progreso_usuario`, `Tbl_racha`, `Tbl_evento_aprendizaje`

Estas tres tablas forman el sistema de learning analytics descrito en el planteamiento del proyecto.

| Archivo | Tabla origen |
|---|---|
| `progreso.dart` | `Tbl_progreso_usuario` (con `Estado ENUM` y `Porcentaje_capitulo`) |
| `racha.dart` | `Tbl_racha` (con `Current_streak`, `Max_streak`, `Last_activity_date`) |
| `evento_aprendizaje.dart` | `Tbl_evento_aprendizaje` (con `Tipo_evento ENUM` y `Extra_data JSON`) |
| `racha_widget.dart` | Muestra racha activa del usuario |
| `progreso_chart.dart` | Visualización del progreso global |

**Nota:** `Tbl_evento_aprendizaje` se alimenta automáticamente desde múltiples features. Los eventos `inicio_leccion`, `fin_leccion`, `respuesta`, `guardar` se registran sin acción explícita del usuario, llamando a `RegistrarEventoUseCase` en los controllers correspondientes.

---

### `features/notificacion/`
**Tabla:** `Tbl_notificacion`

`Tbl_notificacion` tiene FKs opcionales a `Tbl_curso`, `Tbl_leccion` y `Tbl_comentario`. El `notificacion_dto.dart` maneja estos campos como nullable y construye el deep link correspondiente en `Link_contenido`.

---

### `features/guardado/`
**Tabla:** `Tbl_guardado`

Relación M:N entre `Tbl_usuario` y `Tbl_leccion` con restricción `UNIQUE(IdUsuario, IdLeccion)`. El usecase `toggle_guardado_usecase.dart` verifica si ya existe el registro antes de insertar o eliminar.

---

### `features/calificacion/`
**Tablas:** `Tbl_calificacion_leccion`, `Tbl_calificacion_curso`

Dos tablas M:N separadas (una por tipo de contenido). Ambas tienen `UNIQUE(IdUsuarioFk, IdLeccionFk/IdCursoFk)` para evitar calificaciones duplicadas. El `calificacion_dto.dart` sirve para ambas tablas.

---

### `features/configuracion/`
**Tabla:** `Tbl_configuracion`

Relación 1:1 con `Tbl_usuario` (`UNIQUE KEY` en `IdUsuario`). Los campos de esta tabla se sincronizan con `AppSession` via `guardarPreferencias()`. La pantalla lee el estado local primero (AppSession) y persiste en la API en background.

---

### `features/busqueda/`
**Sin tabla propia**

Feature de búsqueda cross-feature. Consume endpoints de búsqueda que internamente consultan `Tbl_leccion` y `Tbl_curso` con filtros de `Estado = 'activa'/'activo'`. No tiene entidades propias; reutiliza `Leccion` y `Curso`.

---

### `features/chatbot/`
**Sin tabla propia en el modelo relacional actual**

Feature de chatbot integrado. Su repositorio apunta a un endpoint externo o de IA. No interactúa directamente con el modelo relacional de Book-L.

---

### `features/home/`
**Sin tabla propia**

Pantalla principal de la app. Agrega datos de múltiples features (lecciones recientes, progreso, racha) sin lógica de negocio propia. Solo tiene `presentation/screens/home_screen.dart`.

---

## 7. Gestión de estado con AppSession (SharedPreferences)

### Qué se persiste en SharedPreferences

| Campo | Tipo | Origen |
|---|---|---|
| `token` | String | Respuesta de login |
| `usuario_id` | int | `Tbl_usuario.IdUsuario` |
| `nombre_completo` | String | `Tbl_usuario.NombreCompleto` |
| `rol` | String | `Tbl_usuario.Rol` |
| `programa` | String | `Tbl_usuario.Programa` |
| `tema_oscuro` | bool | `Tbl_configuracion.Tema` |
| `idioma` | String | `Tbl_configuracion.Idioma` |

### Qué NO se persiste en SharedPreferences

Listas, colecciones, datos de lecciones, cursos, comentarios, notificaciones, progreso detallado. Todo eso viene de la API en cada sesión.

### Flujo de inicialización

```
main() → AppSession().init() → runApp() → GoRouter redirect verifica estaLogueado
```

### Archivos que interactúan con AppSession

| Archivo | Operación |
|---|---|
| `main.dart` | `AppSession().init()` |
| `core/network/dio_client.dart` | Lee `token` para header HTTP |
| `core/router/app_router.dart` | Lee `estaLogueado` para redirect |
| `features/auth/data/repositories/auth_repository_impl.dart` | `guardarSesion()` y `cerrarSesion()` |
| `features/configuracion/data/repositories/configuracion_repository_impl.dart` | `guardarPreferencias()` |
| Cualquier widget que muestre nombre o rol | Lee campos en memoria |

---

## 8. Reglas para agentes que trabajen sobre este proyecto

1. **No crear archivos fuera de la estructura definida** sin justificación documentada.
2. **No agregar imports de `package:dio` o `package:flutter` en archivos dentro de `domain/`.**
3. **No saltarse capas:** `presentation/` nunca llama directamente a `data/`.
4. **Nuevas tablas del modelo relacional** → nueva feature o nueva entidad dentro de una feature existente siguiendo el criterio de cohesión de UI.
5. **Nuevos endpoints de API** → nuevo método en la interfaz de `domain/repositories/` + implementación en `data/repositories/` + nuevo usecase si implica nueva lógica de negocio.
6. **Widgets nuevos usados en más de una feature** → van en `shared/widgets/`, no se duplican.
7. **Los DTOs** (`data/dto/`) son los únicos archivos que pueden usar `fromJson`/`toJson`. Las entidades de `domain/entities/` son Dart puro.
8. **El campo `Estado`** en `Tbl_leccion` y `Tbl_curso` es responsabilidad del backend. El frontend solo filtra por `estado == 'activa'/'activo'` para mostrar contenido.
9. **`Tbl_evento_aprendizaje`** debe alimentarse desde los controllers de `leccion`, `ejercicio` y `guardado` sin que el usuario lo perciba.
10. **La migración a hexagonal** se ejecuta renombrando carpetas, no reescribiendo lógica. Preservar la separación de capas actual es la garantía de eso.

---

## 9. Estado actual del proyecto

> Actualizar esta sección conforme avance el desarrollo.

- [x] Estructura de carpetas creada
- [ ] Maquetación frontend (en progreso)
- [ ] Implementación de `core/` (pendiente)
- [ ] Implementación de `features/auth/` (pendiente)
- [ ] Conexión con API backend (pendiente)
- [ ] Backend (pendiente — iniciar cuando la maquetación esté completa)

---

*Documento generado para el proyecto Book-L — Plataforma Móvil Colaborativa para el Refuerzo Académico — Universidad Libre seccional Barranquilla.*
