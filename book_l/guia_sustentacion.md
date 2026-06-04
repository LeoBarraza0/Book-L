# 🎬 Guión de Video Secuencial: Flujo de Datos por Features — Book-L

Este guión está redactado en formato narrativo secuencial para video. Explica paso a paso cómo viaja la información en cada funcionalidad principal (Feature), relacionando en cada paso los archivos del código, los diagramas UML (`casosdeuso.json` y `diagramaclases.json`), la base de datos de Supabase (`book-l_supabase.sql`), el manejo de estado con Provider y la persistencia local.

---

## ⏱️ 0:00 - 1:15 | Introducción y Estructura Arquitectónica General

**[Visual: El editor VS Code con el directorio del proyecto abierto. Se muestra la raíz de `lib/features/` y se expanden varias carpetas de features. Luego se muestra la pantalla de inicio de la aplicación en el emulador]**

**[Audio / Narración]:**
> "Hola a todos. En este video realizaremos un recorrido técnico y funcional por **Book-L**, una plataforma móvil de microlearning colaborativo construida sobre Flutter y Supabase. 
> 
> A diferencia de los patrones monolíticos tradicionales, Book-L implementa **Arquitectura Hexagonal dividida por Features**. Como se observa en la estructura de directorios en pantalla, cada módulo funcional está completamente aislado en su propio paquete bajo `lib/features/`. 
> 
> En cada feature encontramos tres capas desacopladas: **Dominio** (que define las entidades puras y las interfaces o puertos de salida), **Aplicación** (que contiene las intenciones del usuario en forma de casos de uso), e **Infraestructura** (que implementa los adaptadores que conectan la UI con Flutter, el cliente de Supabase y el caché local).
> 
> Para ver cómo funciona esta arquitectura en la práctica, analizaremos el flujo detallado de datos, paso a paso, en cuatro de nuestras principales características."

---

## ⏱️ 1:15 - 3:30 | Feature 1: Lecciones (Eliminación de Contenido)

**[Visual: Mostrar en la pantalla del emulador cómo un usuario Administrador accede al panel, visualiza las lecciones y presiona el botón "Eliminar" en una de ellas. Inmediatamente después, cambiar a VS Code para mostrar el código de `admin_leccion_screen.dart`, `leccion_controller.dart`, `leccion_repository_impl.dart` y la estructura de tablas de Supabase]**

**[Audio / Narración]:**
> "Comencemos con el flujo de **Eliminación de Lecciones**. Esta acción inicia en el actor **Administrador** ejecutando el caso de uso `UC_LeccDel` de nuestro Diagrama de Casos de Uso.
> 
> **Paso 1: La Interfaz de Usuario (UI)**. En el archivo [admin_leccion_screen.dart](file:///c:/Users/leoba/Downloads/Book-L/book_l/lib/features/leccion/infrastructure/adapters/in/presentation/screens/admin_leccion_screen.dart), cuando el administrador confirma la eliminación, la UI invoca al adaptador conductor `LeccionController`:
> ```dart
> await _leccionCtrl.eliminarLeccion(item.idLeccion);
> ```
> 
> **Paso 2: Presentación y Estado (Provider)**. En [leccion_controller.dart](file:///c:/Users/leoba/Downloads/Book-L/book_l/lib/features/leccion/infrastructure/adapters/in/presentation/controller/leccion_controller.dart), el método `eliminarLeccion` llama al caso de uso inyectado `_deleteLeccion` y luego refresca la lista local en memoria:
> ```dart
> await _deleteLeccion(id);
> await cargarLecciones();
> ```
> 
> **Paso 3: Caso de Uso y Puertos**. El caso de uso `DeleteLeccionUseCase` en `leccion_usecases.dart` invoca la interfaz del repositorio `LeccionRepository` (nuestro puerto de salida en la capa de aplicación), desacoplando la lógica de negocio de la base de datos externa.
> 
> **Paso 4: El Adaptador Outbound (Infraestructura)**. La implementación concreta [LeccionRepositoryImpl](file:///c:/Users/leoba/Downloads/Book-L/book_l/lib/features/leccion/infrastructure/adapters/out/repositories/leccion_repository_impl.dart) realiza dos operaciones críticas:
> - Primero, ejecuta la consulta de borrado física contra la tabla `tbl_leccion` en Supabase:
>   ```dart
>   await SupabaseClientHelper.client.from('tbl_leccion').delete().eq('idleccion', id);
>   ```
> - Segundo, actualiza el estado local delegando al servicio centralizado `_service.removeLeccion(id)`.
> 
> **Paso 5: Mapeo y Base de Datos Relacional**. Si miramos nuestro Diagrama de Clases UML, la entidad `Leccion` contiene una relación de **Composición** hacia sus `Capitulos`. En la base de datos de Supabase (`book-l_supabase.sql`), esto se modela en la tabla `tbl_capitulo` mediante una clave foránea obligatoria `idleccion integer REFERENCES tbl_leccion(idleccion) ON DELETE CASCADE`. Al ejecutar el borrado del registro en `tbl_leccion`, el motor relacional de Supabase elimina automáticamente en cascada todos los capítulos asociados a esa lección, manteniendo la consistencia total de la base de datos.
> 
> **Paso 6: Reactividad en la UI**. El servicio central en [bookl_service.dart](file:///c:/Users/leoba/Downloads/Book-L/book_l/lib/core/infrastructure/services/bookl_service.dart) remueve la lección de la lista en memoria, ejecuta `_save()` para persistir el cambio en local a SharedPreferences como JSON, y llama a `notifyListeners()`. Esto provoca que el controlador reciba la actualización de la caché y que el widget `ListenableBuilder` de la pantalla se redibuje automáticamente sin la lección eliminada."

---

## ⏱️ 3:30 - 5:45 | Feature 2: Perfil y Comunidad (Seguir Usuarios)

**[Visual: Mostrar en el emulador la navegación al perfil de otro usuario y la acción de presionar el botón "Seguir" que cambia a "Siguiendo". En VS Code, mostrar `perfil_screen.dart`, `perfil_controller.dart`, `perfil_repository_impl.dart` y el fragmento SQL de `tbl_seguidores`]**

**[Audio / Narración]:**
> "Pasemos a la feature de **Perfil y Comunidad**, específicamente a la acción de **Seguir a un Usuario**. Esto representa el caso de uso `UC_ProfFol` (que extiende a `UC_ProfView`) en nuestro diagrama de casos de uso.
> 
> **Paso 1: UI y Lectura de Estado**. El botón "Seguir" en `perfil_screen.dart` está envuelto en un `ListenableBuilder` que escucha a `PerfilController`. Al presionarlo, invoca:
> ```dart
> PerfilController().toggleSeguir(myId, userId);
> ```
> 
> **Paso 2: Orquestación en el Controlador**. El controlador de presentación en `perfil_controller.dart` delega la acción al repositorio concreto y notifica inmediatamente del cambio a la interfaz:
> ```dart
> _repo.toggleSeguir(idSeguidor, idSeguido);
> notifyListeners();
> ```
> 
> **Paso 3: Relaciones UML y Supabase**. En nuestro Diagrama de Clases UML, modelamos el seguimiento social como una **Auto-asociación N:M** de la clase `Usuario` consigo misma (la relación `sigue_a`). En la base de datos relacional de Supabase, esto se mapea mediante una tabla intermedia de rompimiento llamada `tbl_seguidores`, con una clave primaria compuesta por las foráneas `idseguidor` e `idseguido`.
> 
> **Paso 4: Persistencia en Supabase**. El adaptador outbound `PerfilRepositoryImpl` ejecuta el comando contra Supabase insertando o modificando el estado de la fila en `tbl_seguidores` mediante un método de actualización.
> 
> **Paso 5: Caché Híbrida en SharedPreferences**. Al mismo tiempo, en [BooklService](file:///c:/Users/leoba/Downloads/Book-L/book_l/lib/core/infrastructure/services/bookl_service.dart), actualizamos la lista intermedia de seguidores en memoria y llamamos a `_save()`. SharedPreferences guarda este listado serializado en JSON bajo la clave `bookl_full_data`, asegurando que la racha de seguidores se cargue al instante y de manera offline en los inicios posteriores. Finalmente, el controlador notifica a la UI, redibujando el botón para reflejar el estado 'Siguiendo'."

---

## ⏱️ 5:45 - 7:45 | Feature 3: Chatbot Académico (Consultas por Palabras Clave)

**[Visual: Mostrar en el emulador el foro de chat con el Bot, enviando la pregunta '¿Qué es arquitectura hexagonal?' y recibiendo una respuesta con un retardo natural. En VS Code, abrir `chatbot_screen.dart`, `chatbot_controller.dart`, `chatbot_repository_impl.dart` y `chatbot_respuesta_dto.dart`]**

**[Audio / Narración]:**
> "Veamos ahora la feature del **Chatbot Académico**, que ilustra los casos de uso `UC_BotAsk` e `UC_BotGen`. Este módulo tiene una particularidad: al ser una base de conocimiento estática, sus respuestas se leen directamente desde un archivo JSON cacheado por seguridad y rendimiento.
> 
> **Paso 1: Interacción en la UI**. El usuario escribe su consulta en `chatbot_screen.dart` y presiona el ícono de enviar, lo que llama al controlador:
> ```dart
> _chatbotController.enviarMensaje(texto);
> ```
> 
> **Paso 2: Manejo de Estados de UI**. El `ChatbotController` en `chatbot_controller.dart` añade el mensaje de usuario a la lista en memoria y cambia el estado de la UI a `ChatbotPensando`. Esto activa una animación de puntos en la pantalla de Flutter que simula el retardo del bot.
> 
> **Paso 3: Caso de Uso y Detección de Respuestas**. El controlador invoca al caso de uso `GetRespuestaChatbotUseCase` el cual interactúa con el puerto `ChatbotRepository`. La implementación concreta en `ChatbotRepositoryImpl` carga el JSON de intenciones y respuestas de la base de conocimiento y ejecuta un algoritmo de coincidencia de palabras clave.
> 
> **Paso 4: Mapeo y DTOs**. En nuestro Diagrama de Clases UML, existe una relación de **Dependencia** temporal entre `Usuario` y `ChatbotRespuesta`. Para mapear el JSON estático a nuestro modelo limpio, implementamos `ChatbotRespuestaDto.fromJson` y su método `toEntity()`. El DTO traduce las palabras clave e intenciones crudas del JSON hacia el objeto de dominio `ChatbotRespuesta`.
> 
> **Paso 5: Respuesta Final**. Una vez seleccionada la respuesta que mejor se adapta a la consulta del estudiante, el controlador la añade a la lista de mensajes en memoria, conmuta el estado de la UI a `ChatbotConversando` y llama a `notifyListeners()`, redibujando la vista para añadir la burbuja del bot."

---

## ⏱️ 7:45 - 9:40 | Feature 4: Calificaciones Reactivas (Supabase Realtime)

**[Visual: Mostrar en el emulador dos teléfonos simulados. En el Teléfono A se califica una lección con 4 estrellas. Ver cómo en el Teléfono B, el rating promedio de esa lección se actualiza en tiempo real de forma inmediata. Cambiar a VS Code y mostrar el método `_initRealtimeSubscriptions()` y la lógica de `_limpiarCalificacionesDuplicadas()` en `bookl_service.dart`]**

**[Audio / Narración]:**
> "Para finalizar, expliquemos la feature de **Calificaciones**, que destaca por implementar **sincronización multiusuario en tiempo real a través de Supabase**. Esta feature corresponde a `UC_CapCal` en nuestro Diagrama de Casos de Uso.
> 
> **Paso 1: Mapeo Polimórfico en el Dominio**. En el Diagrama de Clases UML, la entidad `Calificacion` califica de manera genérica tanto a Lecciones como a Cursos. Dado que las bases de datos relacionales no manejan polimorfismo de forma nativa, en la base de datos relacional de Supabase creamos dos tablas separadas: `tbl_calificacion_leccion` y `tbl_calificacion_curso`. Sin embargo, en el código, el DTO unifica ambas tablas en una sola clase de dominio `Calificacion` diferenciándolas por el campo `tipoObjeto`.
> 
> **Paso 2: Inserción y Sincronización**. Cuando el usuario califica, el controlador llama al repositorio y este delega en `BooklService.agregarOActualizarCalificacion`. El servicio actualiza la lista local en memoria y dispara un `upsert` a Supabase que resuelve conflictos en base de datos si el usuario ya había votado antes.
> 
> **Paso 3: Reactividad Realtime con Canales de Supabase**. Para sincronizar esto a otros usuarios al mismo tiempo, el método `_initRealtimeSubscriptions()` en [bookl_service.dart](file:///c:/Users/leoba/Downloads/Book-L/book_l/lib/core/infrastructure/services/bookl_service.dart#L1542-L1609) mantiene una conexión persistente por websockets hacia Supabase:
> ```dart
> client.channel('public:tbl_calificacion_leccion').onPostgresChanges(
>   event: PostgresChangeEvent.all,
>   schema: 'public',
>   table: 'tbl_calificacion_leccion',
>   callback: (payload) { ... }
> ).subscribe();
> ```
> 
> **Paso 4: Algoritmo de Limpieza de Duplicados en Clientes**. Al recibir el evento en el Teléfono B, el callback extrae la calificación. Para evitar inconsistencias de red, llamamos a `_limpiarCalificacionesDuplicadas()`. Este método analiza la memoria y remueve duplicados de un mismo usuario sobre un mismo contenido, priorizando los registros con IDs definitivos de Supabase por encima de IDs temporales.
> 
> **Paso 5: Cálculo del Promedio y Redibujado**. Los métodos `obtenerRatingLeccion` y `obtenerRatingCurso` recalculan el promedio de calificaciones usando únicamente los votos deduplicados. Esto actualiza el rating de la lección en la caché local del Teléfono B y llama a `notifyListeners()`, redibujando la pantalla reactivamente en tiempo real para todos los usuarios."

---

## ⏱️ 9:40 - 10:00 | Cierre y Conclusiones

**[Visual: El emulador de la aplicación Book-L y el editor de código VS Code lado a lado en la pantalla]**

**[Audio / Narración]:**
> "En conclusión, Book-L demuestra cómo un diseño arquitectónico riguroso basado en Arquitectura Hexagonal y patrones de desarrollo móvil avanzados nos permite estructurar una aplicación que no solo responde de manera eficiente a las necesidades del usuario final, sino que mantiene un código limpio, testeable, escalable y altamente reactivo ante eventos en tiempo real. 
> 
> Muchas gracias por su atención."
