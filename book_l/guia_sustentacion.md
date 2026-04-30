# 📚 Guía de Sustentación — Book-L

## Parte 1: El patrón base del evaluador

En clase aprendimos un patrón simple para consumir datos desde un JSON. Lo podemos ver en la carpeta `Ejemplo/Servicio/`:

```
JSON (archivo) → Service (clase con listas) → UI (pantalla que llama al Service)
```

Así funciona en el ejemplo de Twitter:

### 1. El JSON es la fuente de verdad
Se tiene un archivo `twitter_data.json` con toda la información (tweets, usuarios, etc.).

### 2. El Service es la "base de datos en memoria"
`TwitterService` es la clase que carga ese JSON y lo guarda en listas tipadas:

```dart
// services/twitter_service.dart
class TwitterService {
  List<Tweet> tweets = [];
  List<User> users = [];

  Future<void> init() async {
    final response = await rootBundle.loadString('assets/data/twitter_data.json');
    final data = json.decode(response);

    users = (data['usuarios'] as List)
        .map((u) => User(id: u['id'], username: u['username'], ...))
        .toList();
    tweets = (data['tweets'] as List)
        .map((t) => Tweet(id: t['id'], ...))
        .toList();
  }
}
```

### 3. La UI llama directamente al Service
La pantalla crea una instancia del servicio, carga los datos, y cuando hay una acción (like, crear, eliminar), llama al método del servicio y hace `setState` para redibujar:

```dart
// UI/pages/home_page.dart
class _HomePageState extends State<HomePage> {
  final service = TwitterService();

  void loadData() async {
    await service.init();
    setState(() {});  // ← Refresca la pantalla con los datos cargados
  }

  void like(int id) {
    service.likeTweet(id);     // ← Modifica la lista en memoria
    setState(() {});           // ← Refresca la UI
  }

  void delete(int id) {
    service.deleteTweet(id);   // ← Elimina de la lista
    setState(() {});           // ← Refresca
  }
}
```

**Este patrón cumple 3 reglas fundamentales:**
1. Todo dato viene del JSON, nunca se hardcodea en la pantalla
2. La UI nunca accede al JSON directamente — siempre pasa por el Service
3. Cada acción del usuario modifica las listas del Service y refresca la vista

---

## Parte 2: Cómo escalamos ese patrón en Book-L

Book-L tiene más de 15 features (lecciones, cursos, perfil, chatbot, ejercicios, etc.). Si todas las pantallas importaran `BooklService` directamente como hace el ejemplo con `TwitterService`, tendríamos un código difícil de mantener y escalar. Por eso adoptamos **Clean Architecture por features**: el flujo base es idéntico en esencia, solo se distribuye en capas.

### Correspondencia directa

| Ejemplo del profe | Book-L (Clean Architecture) |
|---|---|
| `models/tweet.dart` (clase Dart pura) | `domain/entities/leccion.dart` (clase Dart pura) |
| `TwitterService.init()` parsea JSON | `data/dto/leccion_dto.dart` (fromJson / toJson) |
| `TwitterService` (listas + CRUD) | `BooklService` (core/services/) + `data/repositories/` |
| La UI llama `service.addTweet()` | La UI llama `controller.agregarLeccion()` → controller llama al repositorio → el repositorio llama a `BooklService` |
| `setState(() {})` | `notifyListeners()` en el Controller + `ListenableBuilder` en la UI |

### Estructura de cada feature

```
feature_name/
├── domain/
│   ├── entities/       ← Clase Dart pura (como Tweet del ejemplo)
│   ├── repositories/   ← CONTRATO: dice "qué operaciones existen"
│   └── usecases/       ← Lógica de negocio unitaria
├── data/
│   ├── dto/            ← Traduce JSON ↔ Entity (el fromJson/toJson)
│   └── repositories/   ← IMPLEMENTACIÓN: ejecuta contra BooklService
└── presentation/
    ├── controller/     ← Orquesta los use cases y maneja el estado
    ├── screens/        ← Pantallas Flutter (solo dibujan)
    └── widgets/        ← Widgets propios de la feature
```

### ¿Cuál es el punto clave?

**La pantalla (UI) NUNCA importa `BooklService` directamente.** Solo habla con su Controller. Esto es la diferencia arquitectural con el ejemplo:

```
Ejemplo del profe:    UI → Service → JSON
Book-L:               UI → Controller → UseCase → Repository (interfaz)
                                                       ↓
                                              RepositoryImpl → BooklService → JSON
```

El beneficio: si mañana cambiamos la fuente de datos (de JSON a una API REST), solo cambiamos el `RepositoryImpl`. Ni el Controller ni la UI se enteran del cambio.

---

## Parte 3: Flujo paso a paso por feature

Para cada feature asignada, elegimos un **botón representativo** y rastreamos exactamente por dónde pasa la información.

---

### 🟢 Leo — Feature: Lecciones

**Botón elegido: "Eliminar Lección" en `admin_leccion_screen.dart`**

Cuando el administrador toca "Eliminar" en una tarjeta de lección, esto es lo que pasa:

```
Paso 1 → UI (admin_leccion_screen.dart)
    El usuario presiona el botón rojo "Eliminar"
    Se abre un modal de confirmación
    Al aceptar, se ejecuta:
      await _leccionCtrl.eliminarLeccion(item.idLeccion);
    La UI NO conoce BooklService. Solo conoce su controller.

Paso 2 → Controller (leccion_controller.dart)
    El método eliminarLeccion() recibe el ID:
      Future<void> eliminarLeccion(int id) async {
        await _deleteLeccion(id);   // ← invoca el Use Case
        await cargarLecciones();    // ← recarga la lista
      }

Paso 3 → UseCase (leccion_usecases.dart)
    DeleteLeccionUseCase simplemente delega al contrato:
      Future<void> call(int id) => repository.deleteLeccion(id);
    Aquí "repository" es la INTERFAZ (domain/), no la implementación.

Paso 4 → RepositoryImpl (leccion_repository_impl.dart)
    La implementación concreta ejecuta la operación real:
      Future<void> deleteLeccion(int id) async {
        _service.removeLeccion(id);  // ← _service es BooklService
      }
    AQUÍ es el único lugar donde se toca BooklService.

Paso 5 → BooklService (core/services/bookl_service.dart)
    BooklService modifica la lista en memoria y persiste:
      void removeLeccion(int id) {
        lecciones.removeWhere((l) => l.idLeccion == id);
        _save();  // ← Serializa TODO a SharedPreferences como JSON
        notifyListeners();  // ← Avisa que hubo cambios
      }

Paso 6 → La UI se reconstruye automáticamente
    Como el Controller llamó cargarLecciones() y luego notifyListeners(),
    el ListenableBuilder en la pantalla detecta el cambio y redibuja la
    lista sin la lección eliminada.
```

**Equivalencia con el ejemplo del profe:**
```dart
// Ejemplo del profe:
void delete(int id) {
  service.deleteTweet(id);   // Toca el Service directo
  setState(() {});           // Refresca manual
}

// Book-L:
await _leccionCtrl.eliminarLeccion(id);  // Pasa por Controller → UseCase → Repo → Service
// La UI se reconstruye automáticamente con ListenableBuilder (sin setState manual)
```

---

### 🔵 Freddy — Feature: Perfil

**Botón elegido: "Seguir / Siguiendo" en `perfil_screen.dart`**

Cuando un usuario visita el perfil de otra persona y toca "Seguir", esto es lo que pasa:

```
Paso 1 → UI (perfil_screen.dart)
    El botón está envuelto en un ListenableBuilder que escucha al PerfilController:
      ListenableBuilder(
        listenable: PerfilController(),
        builder: (context, _) {
          final isFollowing = PerfilController().isFollowing(myId, userId);
          return ElevatedButton(
            onPressed: () {
              PerfilController().toggleSeguir(myId, userId);
            },
            child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
          );
        },
      )
    La UI NO importa BooklService. Solo interactúa con PerfilController.

Paso 2 → Controller (perfil_controller.dart)
    toggleSeguir() delega al repositorio y notifica:
      void toggleSeguir(int idSeguidor, int idSeguido) {
        _repo.toggleSeguir(idSeguidor, idSeguido);
        notifyListeners();  // ← La UI se reconstruye
      }

Paso 3 → RepositoryImpl (perfil_repository_impl.dart)
    La implementación ejecuta contra BooklService:
      void toggleSeguir(int idSeguidor, int idSeguido) {
        _service.toggleSeguir(idSeguidor, idSeguido);
      }

Paso 4 → BooklService
    BooklService busca en la tabla de seguidores (Tbl_seguidores),
    cambia el estado de 'activo' a 'inactivo' (o viceversa),
    y llama _save() para persistir en SharedPreferences como JSON.
    Luego llama notifyListeners().

Paso 5 → La UI se reconstruye
    El ListenableBuilder detecta el cambio, vuelve a llamar isFollowing(),
    y ahora el botón dice "Siguiendo" en vez de "Seguir" (o viceversa),
    todo automáticamente.
```

**Equivalencia con el ejemplo del profe:**
```dart
// Ejemplo del profe:
void like(int id) {
  service.likeTweet(id);
  setState(() {});
}

// Book-L (Perfil):
PerfilController().toggleSeguir(myId, userId);
// El ListenableBuilder se encarga del "setState" automáticamente
```

---

### 🟡 Emanuel — Feature: Chatbot

**Botón elegido: Botón "Enviar mensaje" (ícono de enviar) en `chatbot_screen.dart`**

El chatbot tiene una particularidad: sus datos (intenciones y respuestas predefinidas) son estáticos de configuración, no transaccionales. Por eso el repositorio lee el JSON directamente en lugar de pasar por BooklService (que está reservado para datos que se modifican como lecciones, usuarios, etc.).

```
Paso 1 → UI (chatbot_screen.dart)
    El usuario escribe un mensaje y presiona enviar:
      void _sendMessage() {
        final text = _messageController.text.trim();
        _messageController.clear();
        _chatbotController.enviarMensaje(text);
      }
    La pantalla instancia todo con inyección manual en initState:
      final repository = ChatbotRepositoryImpl();
      final useCase = GetRespuestaChatbotUseCase(repository);
      _chatbotController = ChatbotController(getRespuesta: useCase);

Paso 2 → Controller (chatbot_controller.dart)
    enviarMensaje() agrega el mensaje del usuario a la lista interna,
    luego invoca el Use Case para buscar la respuesta:
      Future<void> enviarMensaje(String texto) async {
        _mensajes.add(ChatMessage(texto: texto, esUsuario: true));
        _setState(ChatbotPensando(mensajes: List.from(_mensajes)));

        final respuesta = await getRespuesta(texto);  // ← Use Case
        await Future.delayed(Duration(milliseconds: 800));  // Delay natural

        _mensajes.add(ChatMessage(texto: respuesta.respuestas[...], esUsuario: false));
        _setState(ChatbotConversando(mensajes: List.from(_mensajes)));
      }

Paso 3 → UseCase (get_respuesta_chatbot_usecase.dart)
    Delega al repositorio:
      Future<ChatbotRespuesta> call(String params) {
        return repository.buscarRespuesta(params);
      }

Paso 4 → RepositoryImpl (chatbot_repository_impl.dart)
    Carga las respuestas del JSON (con cache), normaliza el mensaje,
    y aplica un algoritmo de matching por palabras clave:
      Future<ChatbotRespuesta> buscarRespuesta(String mensaje) async {
        final respuestas = await obtenerRespuestas();  // Lee del JSON (cacheado)
        // Recorre cada intención, cuenta coincidencias de palabras clave
        // Devuelve la mejor coincidencia o la respuesta por defecto
      }

Paso 5 → DTO (chatbot_respuesta_dto.dart)
    El DTO traduce el JSON crudo a la entidad de dominio:
      factory ChatbotRespuestaDto.fromJson(Map<String, dynamic> json)
      ChatbotRespuesta toEntity()  // ← Convierte DTO a entidad pura

Paso 6 → La respuesta sube por la cadena
    UseCase retorna ChatbotRespuesta → Controller agrega el mensaje del bot
    → notifyListeners() → la UI se reconstruye mostrando la burbuja de respuesta.
```

**Equivalencia con el ejemplo del profe:**
```dart
// Ejemplo del profe:
void loadData() async {
  await service.init();          // Carga JSON
  setState(() {});               // Refresca
}

// Book-L (Chatbot):
_chatbotController.enviarMensaje(text);  // Controller → UseCase → Repo lee JSON
// El controller hace notifyListeners() y la UI se reconstruye sola
```

---

## Parte 4: SharedPreferences (AppSession)

Además del JSON para datos de negocio, usamos **SharedPreferences** para datos de sesión y preferencias. Esto lo aprendimos en el ejemplo de `PreferencesService`:

```dart
// Ejemplo del profe:
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  Future saveName(String name) async {
    await _prefs?.setString("name", name);
  }
  String getName() => _prefs?.getString("name") ?? "";
}
```

En Book-L, el equivalente es `AppSession` (`core/storage/local_storage.dart`):

```dart
class AppSession {
  static final AppSession _instance = AppSession._internal();
  factory AppSession() => _instance;
  // ...
}
```

**¿Qué se guarda en SharedPreferences?** Solo datos pequeños de sesión:
- `usuario_id`, `nombre_completo`, `rol` → Para saber quién está logueado sin consultar el JSON
- `tema_oscuro`, `idioma`, `tamano_fuente` → Preferencias visuales
- `completed_capitulos` → IDs de capítulos completados (progreso local)
- `saved_lecciones`, `saved_cursos` → IDs de contenido guardado como favorito

**¿Qué NO se guarda?** Listas completas de entidades. Esos datos viven en `BooklService` (la "BD en memoria") que se carga del JSON.

---

## Parte 5: Resumen visual del flujo completo

```
                    ┌─────────────────────────────┐
                    │        JSON (Asset)          │
                    │     bookl_data.json          │
                    └──────────┬──────────────────┘
                               │ rootBundle.loadString()
                               ▼
                    ┌──────────────────────────────┐
                    │       BooklService            │
                    │   (Singleton, BD en memoria)  │
                    │   Listas: lecciones, cursos,  │
                    │   usuarios, seguidores...     │
                    │   Métodos CRUD + _save()      │
                    └──────────┬──────────────────┘
                               │  Solo accedido desde
                               │  data/repositories/
                               ▼
            ┌─────────────────────────────────────────┐
            │        RepositoryImpl (data/)            │
            │  Ejecuta contra BooklService con tipado  │
            │  Ej: LeccionRepositoryImpl               │
            │      PerfilRepositoryImpl                │
            │      ChatbotRepositoryImpl               │
            └──────────┬──────────────────────────────┘
                       │  Implementa la interfaz de
                       │  domain/repositories/
                       ▼
            ┌──────────────────────────────────────────┐
            │      Repository (domain/) - INTERFAZ     │
            │  Contrato abstracto: define QUÉ se puede │
            │  hacer, no CÓMO se hace                   │
            └──────────┬───────────────────────────────┘
                       │  Usado por UseCases
                       ▼
            ┌──────────────────────────────────────────┐
            │          UseCase (domain/usecases/)       │
            │  Operación de negocio unitaria            │
            │  Ej: GetLeccionesUseCase.call()           │
            │      DeleteLeccionUseCase.call(id)        │
            │      GetRespuestaChatbotUseCase.call(msg) │
            └──────────┬───────────────────────────────┘
                       │  Invocado por el Controller
                       ▼
            ┌──────────────────────────────────────────┐
            │      Controller (presentation/)           │
            │  Singleton + ChangeNotifier                │
            │  Orquesta UseCases, mantiene DataState     │
            │  Llama notifyListeners() tras cada cambio  │
            └──────────┬───────────────────────────────┘
                       │  Escuchado por ListenableBuilder
                       ▼
            ┌──────────────────────────────────────────┐
            │        Screen / Widget (presentation/)    │
            │  Solo dibuja. Nunca modifica datos.        │
            │  Escucha al Controller con                 │
            │  ListenableBuilder y se reconstruye        │
            │  automáticamente.                          │
            └──────────────────────────────────────────┘
```

> **Regla de oro para la sustentación:** Si el evaluador pregunta "¿de dónde salen esos datos?", la respuesta siempre es: **del JSON**, a través de `BooklService` (la BD en memoria), accedido exclusivamente desde el `RepositoryImpl` de cada feature, nunca directamente desde la pantalla.
