# Arquitectura y Flujo de Datos — Book-L

> **Propósito de este documento:** Servir como referencia canónica para cualquier agente o desarrollador que trabaje sobre el proyecto Book-L. Define la arquitectura adoptada, el flujo de datos que la UI debe seguir para consumir y persistir información, y las reglas de uso de SharedPreferences y Singletons. **No tomar decisiones de estructura sin consultar este documento.**

---

## 1. Arquitectura adoptada: Clean Architecture por features

El proyecto implementa **Clean Architecture por features**. La separación de responsabilidades se organiza en tres capas con una dirección de dependencia estricta:

```
presentation/  →  domain/  ←  data/
```

- `domain/` **nunca** importa nada de `data/` ni de `presentation/`.
- `data/` conoce `domain/` (implementa sus interfaces).
- `presentation/` conoce `domain/` (consume sus casos de uso).
- Si en un archivo dentro de `domain/` aparece un import de `dio`, `flutter`, `shared_preferences` o cualquier paquete externo, es un error arquitectural.

> **Nota sobre migración futura:** Esta estructura está deliberadamente alineada para que, si en un futuro se decide migrar a Arquitectura Hexagonal, el proceso sea de renombrado y reorganización de carpetas, no de reescritura. Sin embargo, esa migración **no es prioridad actual** y no debe influir en decisiones del día a día.

---

## 2. Flujo de datos canónico — Del patrón base a Clean Architecture

### 2.1 Patrón base de persistencia y estado (ejemplo de Servicio)

Se ha establecido un patrón base sencillo pero sólido para el flujo de datos:

```
┌──────────────────────────────────────────────────────┐
│                    Patrón Base Simple                 │
│                                                       │
│   JSON (asset)                                        │
│     ↓  rootBundle.loadString()                        │
│   Service (clase con listas en memoria)               │
│     ↓  métodos CRUD (getTweets, addTweet, etc.)       │
│   UI (StatefulWidget que llama al Service)             │
│     ↓  setState() para refrescar                      │
│   Widgets (reciben datos y callbacks)                  │
└──────────────────────────────────────────────────────┘
```

**Principios clave extraídos:**

1. **El JSON es la fuente de verdad.** Los datos se cargan desde un archivo JSON al iniciar y se persisten de vuelta tras cada escritura.
2. **El Servicio es la "base de datos en memoria".** Contiene listas tipadas (`List<Tweet>`, `List<User>`, etc.) que se llenan al parsear el JSON. Toda operación CRUD se ejecuta sobre estas listas y luego se persisten.
3. **La UI nunca accede al JSON directamente.** Siempre pasa por el Servicio para leer y escribir datos.
4. **No existen datos estáticos/hardcodeados.** Todo dato de negocio que se muestra en pantalla proviene del JSON vía el Servicio.
5. **Cada escritura persiste.** Tras `add`, `update` o `delete`, el Servicio guarda el estado completo de vuelta al almacenamiento.

### 2.2 Cómo se escala este patrón en Clean Architecture

El flujo base se **preserva intacto** en su esencia; solo se distribuye en capas adicionales para modularidad. La correspondencia directa es:

```
Patrón Base Simple            →    Clean Architecture de Book-L
─────────────────────────          ────────────────────────────────
models/tweet.dart             →    domain/entities/leccion.dart
  (clase Dart pura)                  (clase Dart pura, sin JSON)

Service.init() parsea JSON    →    data/dto/leccion_dto.dart
  (new Tweet(id: t['id']...))        (fromJson / toJson)

Service (listas + CRUD)       →    BooklService (core/services/)
                                     + data/repositories/ (repository_impl)

UI llama service.addTweet()   →    Controller llama useCase(entity)
                                     → useCase llama repository (interfaz)
                                     → repository_impl llama BooklService

setState(() {})               →    notifyListeners() en Controller
                                     + ListenableBuilder en la UI
```

### 2.3 Flujo de lectura (READ) — paso a paso

```
1. UI (Screen)
   └─ En initState() o al navegar: controller.cargarLecciones()

2. Controller (presentation/controller/)
   └─ Invoca el UseCase: _getLecciones()

3. UseCase (domain/usecases/)
   └─ Delega al contrato: repository.getLecciones()

4. RepositoryImpl (data/repositories/)
   └─ Lee de BooklService().lecciones  ← listas en memoria (del JSON)

5. Retorno: List<Leccion> sube por la cadena hasta el Controller

6. Controller actualiza su DataState y llama notifyListeners()

7. UI se reconstruye con ListenableBuilder
```

### 2.4 Flujo de escritura (CREATE / UPDATE / DELETE) — paso a paso

```
1. UI (Screen)
   └─ Usuario interactúa (botón guardar, eliminar, etc.)
   └─ Llama: controller.agregarLeccion(...) / editarLeccion(...) / eliminarLeccion(...)

2. Controller (presentation/controller/)
   └─ Construye la entidad y la pasa al UseCase

3. UseCase (domain/usecases/)
   └─ Delega al contrato: repository.addLeccion(leccion)

4. RepositoryImpl (data/repositories/)
   └─ Ejecuta en BooklService:
      a) Modifica la lista en memoria (add / update index / removeWhere)
      b) Llama _save() → serializa TODAS las listas a JSON
         → SharedPreferences.setString('bookl_full_data', jsonCompleto)

5. Controller recarga los datos (cargarLecciones()) y llama notifyListeners()

6. UI se reconstruye automáticamente
```

### 2.5 Regla fundamental: cero datos estáticos

> **Todo dato de negocio que se muestre en la UI debe provenir del JSON** a través de BooklService. No se permite:
> - Listas hardcodeadas en widgets o controllers
> - Constantes con datos de negocio (usuarios, lecciones, cursos, etc.)
> - Datos "de ejemplo" que no vengan del archivo `bookl_data.json`
>
> Si un caso de uso necesita datos, debe hacer el CRUD contra BooklService (que es el JSON en memoria). Las únicas excepciones son los datos de sesión y preferencias almacenados en SharedPreferences (ver sección 7).

---

## 3. Estructura completa de `lib/`

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
│   ├── services/
│   │   └── bookl_service.dart        ← "BD en memoria" (Singleton)
│   ├── state/
│   │   └── data_state.dart
│   ├── storage/
│   │   └── local_storage.dart        ← AppSession (Singleton + SharedPreferences)
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
    ├── onboarding/
    ├── perfil/
    ├── progreso/
    ├── reportes/
    └── usuarios/
```

---

## 4. Capa `core/` — Infraestructura transversal

### `core/services/bookl_service.dart` — El corazón del flujo de datos

Este archivo es el equivalente directo del servicio de datos base, escalado para todas las entidades del proyecto. Es un **Singleton** que:

1. **Al inicializar (`init()`):** Lee el JSON desde SharedPreferences (datos persistidos) o desde el asset original (`bookl_data.json`), parsea cada sección usando DTOs y llena las listas en memoria.
2. **En lectura:** Expone las listas directamente (`lecciones`, `cursos`, `usuarios`, etc.).
3. **En escritura:** Modifica la lista en memoria y llama `_save()` que serializa todo de vuelta a SharedPreferences como un string JSON completo.
4. **Notifica cambios:** Extiende `ChangeNotifier` y llama `notifyListeners()` tras cada escritura.

> **Regla de acceso:** Solo los `repository_impl` de la capa `data/` pueden importar `BooklService`. Nunca importarlo directamente desde `presentation/` ni desde `domain/`.

### `core/storage/local_storage.dart` — AppSession

Singleton que gestiona SharedPreferences para datos de **sesión y preferencias de usuario** exclusivamente. Ver sección 7 para detalle.

### `core/state/data_state.dart`

Clase genérica `DataState<T>` con `DataStatus` (initial, loading, loaded, error) compartida entre todos los controllers.

### `core/error/`

- **`exception.dart`** — Excepciones técnicas de la capa `data/`.
- **`failure.dart`** — Errores de negocio que `domain/` expone hacia `presentation/`.

### `core/network/`

- **`dio_client.dart`** — Instancia de Dio con URL base, timeouts, interceptor que lee `AppSession().token` para el header `Authorization`.

### `core/router/`

- **`app_router.dart`** — Rutas de la aplicación. Verifica `AppSession().estaLogueado` para proteger rutas privadas.

### `core/theme/`

- **`app_colors.dart`** — Paleta de colores.
- **`app_theme.dart`** — `ThemeData` claro/oscuro. El tema activo se lee desde `AppSession().temaOscuro`.

### `core/utils/`

- **`validators.dart`** — Funciones de validación puras.
- **`extensions.dart`** — Extensiones de Dart.
- **`date_formatter.dart`** — Formateo de fechas en español.

---

## 5. Capa `shared/` — Widgets reutilizables entre features

> **Importante:** `shared/` no tiene relación con SharedPreferences. El nombre refiere a "compartido entre features".

Widgets Flutter que se usan en más de una feature. No contienen lógica de negocio.

| Archivo | Descripción |
|---|---|
| `custom_button.dart` | Botón principal con estilo Book-L y estado de carga |
| `custom_text_field.dart` | Input con validación visual e ícono |
| `loading_indicator.dart` | Spinner/shimmer de carga |
| `empty_state.dart` | Pantalla vacía con ícono y mensaje configurable |
| `book_l_header.dart` | Header superior con logo/título de la app |
| `nav_bar.dart` | Barra de navegación inferior |

---

## 6. Capa `features/` — Módulos de negocio

Cada feature encapsula un dominio de negocio completo. La estructura interna es idéntica en todas:

```
feature_name/
├── domain/
│   ├── entities/       ← Objetos de negocio puros (sin JSON, sin Flutter)
│   ├── repositories/   ← Interfaces abstractas (contratos)
│   └── usecases/       ← Lógica de negocio
├── data/
│   ├── dto/            ← Traductores JSON ↔ Entity (fromJson/toJson)
│   └── repositories/   ← Implementaciones concretas (consumen BooklService)
└── presentation/
    ├── controller/     ← Estado y orquestación (Singleton + ChangeNotifier)
    ├── screens/        ← Pantallas Flutter (solo dibujan)
    └── widgets/        ← Widgets propios de la feature
```

**Cómo cada capa implementa el flujo de datos base:**

| Capa | Rol en el flujo | Equivalente en el patrón simple |
|---|---|---|
| `domain/entities/` | Modelo Dart puro | Clases puras de modelo |
| `data/dto/` | Parseo JSON ↔ Entity | El `json.decode` dentro del Service |
| `data/repositories/` | Delegación al BooklService con tipado | Los métodos CRUD del Service central |
| `domain/repositories/` | Contrato abstracto (interfaz) | *(no existe en el patrón simple)* |
| `domain/usecases/` | Operación de negocio unitaria | *(no existe en el patrón simple)* |
| `presentation/controller/` | Orquesta usecases, maneja estado, notifica UI | El `setState(() {})` y manejo de estado |
| `presentation/screens/` | Dibuja la UI, escucha al controller | El método `build()` de la vista principal |

### Features y sus tablas del modelo relacional

#### `features/auth/`
**Tablas:** `Tbl_usuario`

| Capa | Archivo | Responsabilidad |
|---|---|---|
| `domain/entities/` | `usuario.dart` | Entidad con: id, nombreCompleto, correo, rol, programa, semestre, activo |
| `domain/repositories/` | `auth_repository.dart` | Contrato: login, register, logout |
| `domain/usecases/` | `login_usecase.dart` | Valida credenciales y persiste sesión via AppSession |
| `domain/usecases/` | `register_usecase.dart` | Crea nuevo usuario |
| `domain/usecases/` | `logout_usecase.dart` | Limpia AppSession y redirige |
| `data/dto/` | `usuario_dto.dart` | Mapea JSON ↔ entity `Usuario` |
| `data/repositories/` | `auth_repository_impl.dart` | CRUD sobre BooklService.usuarios + guarda sesión en AppSession |
| `presentation/controller/` | `auth_controller.dart` | Estados: Initial, Loading, Authenticated, Error |
| `presentation/screens/` | `login_screen.dart`, `register_screen.dart` | Pantallas de autenticación |

---

#### `features/leccion/`
**Tablas:** `Tbl_leccion`, `Tbl_capitulo`, `Tbl_material`

Estas tres tablas se agrupan en una sola feature porque en la UI siempre aparecen juntas.

| Capa | Archivo | Tabla origen |
|---|---|---|
| `domain/entities/` | `leccion.dart`, `capitulo.dart`, `material_educativo.dart` | Sus respectivas tablas |
| `data/dto/` | `leccion_dto.dart`, `capitulo_dto.dart`, `material_dto.dart` | Parseo JSON ↔ Entity |
| `data/repositories/` | `leccion_repository_impl.dart`, `capitulo_repository_impl.dart` | CRUD sobre BooklService |
| `presentation/controller/` | `leccion_controller.dart` | Orquesta lección + capítulos + materiales |
| `presentation/screens/` | `leccion_list_screen`, `leccion_detail_screen`, `capitulo_screen` | Pantallas |

---

#### `features/curso/`
**Tablas:** `Tbl_curso`, `Tbl_lecciones_cursos`

`Tbl_lecciones_cursos` es la tabla pivote M:N. No tiene entidad propia; el repositorio la maneja internamente.

---

#### `features/ejercicio/`
**Tablas:** `Tbl_ejercicio`, `Tbl_pregunta`, `Tbl_opcion`, `Tbl_respuesta_usuario`

Cadena de dependencia directa: ejercicio → preguntas → opciones → respuesta del usuario.

---

#### `features/discusion/`
**Tablas:** `Tbl_discusion`, `Tbl_comentario`

`Tbl_comentario` tiene auto-referencia (`Id_padre`) para comentarios anidados.

---

#### `features/perfil/`
**Tablas:** `Tbl_usuario` (perfil público), `Tbl_seguidores`

Distinto de `auth/`: mientras `auth` gestiona sesión, `perfil` gestiona la vista pública y la red social.

---

#### `features/progreso/`
**Tablas:** `Tbl_progreso_usuario`, `Tbl_racha`, `Tbl_evento_aprendizaje`

Sistema de learning analytics.

---

#### `features/calificacion/`
**Tablas:** `Tbl_calificacion_leccion`, `Tbl_calificacion_curso`

Tablas M:N con restricción UNIQUE para evitar calificaciones duplicadas.

---

#### `features/configuracion/`
**Tabla:** `Tbl_configuracion`

Relación 1:1 con `Tbl_usuario`. Se sincroniza con `AppSession` vía `guardarPreferencias()`.

---

#### `features/notificacion/`
**Tabla:** `Tbl_notificacion`

---

#### `features/guardado/`
**Tabla:** `Tbl_guardado`

---

#### `features/busqueda/`, `features/chatbot/`, `features/home/`
Sin tabla propia. Son features de presentación que consumen datos de otras features.

---

## 7. Gestión de SharedPreferences — Cuándo sí y cuándo no

### Principio de aislamiento

En la implementación base de SharedPreferences, se sigue un patrón claro:
- **Singleton** (ej. `PreferencesService`) que encapsula SharedPreferences.
- Se inicializa **una sola vez** en `main()` antes de `runApp()`.
- Persiste solo **valores escalares pequeños** (nombre, género, color de tema).
- Las pantallas lo leen directamente para datos que se necesitan antes de cualquier carga de BD.

### Aplicación en Book-L: `AppSession`

`AppSession` es el equivalente del `PreferencesService` del patrón base. Es un Singleton que se inicializa en `main.dart` y persiste **exclusivamente** datos de sesión y preferencias que se necesitan inmediatamente al abrir la app.

#### Qué SÍ se persiste en SharedPreferences (vía AppSession)

| Campo | Tipo | Para qué sirve |
|---|---|---|
| `token` | String | Autenticación — evita re-login al abrir la app |
| `usuario_id` | int | Identificar al usuario sin consultar la BD |
| `nombre_completo` | String | Mostrar nombre en UI antes de cargar datos completos |
| `rol` | String | Determinar permisos/vistas (admin vs usuario) sin consulta |
| `programa` | String | Contexto académico del usuario |
| `tema_oscuro` | bool | Aplicar tema antes de que la app cargue los datos |
| `idioma` | String | Configurar localización antes de renderizar |
| `tamano_fuente` | String | Escala de texto ('pequeno', 'normal', 'grande') |
| `onboarding_completed` | bool | Saltar onboarding si ya se completó |
| `saved_cursos` | List\<int\> | IDs de cursos guardados como favoritos |
| `saved_lecciones` | List\<int\> | IDs de lecciones guardadas como favoritas |
| `completed_capitulos` | List\<int\> | IDs de capítulos completados (progreso local) |

#### Qué NO se persiste en SharedPreferences

- Listas de entidades (lecciones, cursos, usuarios, comentarios, etc.)
- Datos de negocio complejos
- Cualquier cosa que pueda obtenerse del JSON/API

> **Criterio:** SharedPreferences se usa para evitar consultas recurrentes a la BD en datos que se necesitan **frecuentemente y de forma inmediata** (sesión, tema, progreso local). No es un caché general de datos.

#### Justificación de `saved_cursos`, `saved_lecciones` y `completed_capitulos`

Estos tres campos son listas de IDs (no entidades completas) que representan **estado del usuario que se consulta en múltiples pantallas** sin necesidad de recalcular. Se persisten en SharedPreferences porque:
- Son consultas frecuentes (cada card de curso/lección verifica si está guardada).
- Son datos pequeños (solo IDs enteros).
- Evitan filtrar las listas completas del JSON en cada rebuild de la UI.

### Flujo de inicialización

```
main()
  → AppSession().init()       // SharedPreferences — sesión y preferencias
  → BooklService().init()     // JSON asset — datos de negocio en memoria
  → runApp()
  → Router verifica AppSession().estaLogueado para decidir pantalla inicial
```

---

## 8. Política de Singletons

### Principio base de instancia única

En el patrón de ejemplo se observa el uso de instancias únicas para servicios core:
- `PreferencesService`: Singleton para SharedPreferences.
- Servicio de datos: Instanciado de manera global o única para mantener la fuente de verdad.

En Book-L formalizamos cuándo un Singleton es apropiado:

### Singletons válidos en el proyecto

| Clase | Justificación |
|---|---|
| `BooklService` | Es la "BD en memoria". Debe existir **una sola instancia** para que todas las features compartan el mismo estado de datos. Equivale al Service central del patrón base. |
| `AppSession` | Encapsula SharedPreferences. Debe ser único para evitar inconsistencias en la sesión. Equivale al `PreferencesService` del patrón base. |
| Controllers (`LeccionController`, `CursoController`, etc.) | Son Singletons porque su estado persiste durante toda la vida de la app. Evita el error "used after being disposed" cuando se navega entre pantallas. Su `dispose()` es no-operativo intencionalmente. |

### Patrón Singleton estándar del proyecto

```dart
class MiServicio {
  // Instancia privada única
  static final MiServicio _instance = MiServicio._internal();

  // Factory que siempre retorna la misma instancia
  factory MiServicio() => _instance;

  // Constructor privado
  MiServicio._internal();
}
```

### Qué NO debe ser Singleton

- **Entidades** (`Leccion`, `Curso`, `Usuario`, etc.) — Son objetos de datos, no servicios.
- **DTOs** — Son traductores sin estado.
- **Widgets** — Flutter gestiona su ciclo de vida.
- **UseCases** — Son objetos ligeros que se instancian dentro del Controller.

---

## 9. Reglas para agentes y desarrolladores

1. **No crear archivos fuera de la estructura definida** sin justificación documentada.
2. **No agregar imports de `package:dio` o `package:flutter` en archivos dentro de `domain/`.**
3. **No saltarse capas:** `presentation/` nunca llama directamente a `data/`. `presentation/` nunca importa `BooklService` directamente (excepto para operaciones de conveniencia en controllers Singleton que ya lo encapsulan internamente).
4. **Cero datos estáticos:** Todo dato de negocio proviene del JSON vía BooklService. No hardcodear listas, usuarios, lecciones ni datos de ejemplo en la UI.
5. **Toda escritura persiste:** Cada operación de CREATE/UPDATE/DELETE debe terminar con `_save()` en BooklService para que los datos se persistan al JSON.
6. **Nuevas tablas del modelo relacional** → nueva feature o nueva entidad dentro de una feature existente.
7. **Nuevos endpoints de API** → nuevo método en `domain/repositories/` (interfaz) + implementación en `data/repositories/` + nuevo usecase si implica nueva lógica.
8. **Widgets nuevos usados en más de una feature** → van en `shared/widgets/`, no se duplican.
9. **Los DTOs** (`data/dto/`) son los únicos archivos que pueden usar `fromJson`/`toJson`. Las entidades de `domain/entities/` son Dart puro.
10. **SharedPreferences solo para sesión y preferencias.** No persistir datos de negocio (listas de entidades) en SharedPreferences. Esos datos viven en BooklService.
11. **El campo `Estado`** en `Tbl_leccion` y `Tbl_curso` es responsabilidad del backend. El frontend solo filtra por `estado == 'activa'/'activo'`.

---

## 10. Estado actual del proyecto

> Actualizar esta sección conforme avance el desarrollo.

- [x] Estructura de carpetas creada
- [x] BooklService (core/services/) implementado con CRUD completo
- [x] AppSession (core/storage/) implementado con persistencia de sesión
- [x] Controllers Singleton implementados (Leccion, Curso, etc.)
- [x] Maquetación frontend (en progreso avanzado)
- [ ] Implementación de `core/error/` (pendiente)
- [ ] Conexión con API backend (pendiente — iniciar cuando la maquetación esté completa)
- [ ] Backend (pendiente)

---

*Documento generado para el proyecto Book-L — Plataforma Móvil Colaborativa para el Refuerzo Académico — Universidad Libre seccional Barranquilla.*
