# BLOW App — Plan de Corrección Integral

## Diagnóstico General

Tras la revisión completa de los 20+ archivos del proyecto, se identificaron los siguientes problemas críticos:

---

## Problemas Identificados

### 🔴 CRÍTICOS (Impiden funcionalidad básica)

| # | Problema | Causa Raíz |
|---|----------|------------|
| 1 | **Música se detiene al salir** | `AudioHandlerCustom` usa `just_audio` puro sin `audio_service`. No hay `MediaSession`, no hay `Service` de Android. |
| 2 | **Botón Play en búsqueda no reproduce** | Al tocar resultado de YouTube, el `url` está vacío en el modelo. La obtención de URL es `async`, pero el `setPlaylist` se llama antes de resolverla correctamente. El stream URL de YouTube expira rápidamente. |
| 3 | **Descarga genera error** | `downloadSong()` en `MusicService` es una simulación que genera path falso. El real en `youtube_service_mobile.dart` requiere URL fresca del stream. |
| 4 | **Icono sigue siendo Flutter** | `flutter_launcher_icons` configurado con `image_path: assets/imagenes/logo.svg`, pero **nunca se ejecutó** `flutter pub run flutter_launcher_icons`. Los íconos SVG además requieren PNG. |
| 5 | **Login no persiste sesión** | No existe lógica de `SharedPreferences` para recordar si el usuario ya inició sesión. Cada arranque va al splash → login. |

### 🟠 MAYORES (Funcionalidad incompleta)

| # | Problema | Causa Raíz |
|---|----------|------------|
| 6 | **Notificaciones multimedia ausentes** | Falta `audio_service` package. Sin MediaSession el sistema no puede controlar la reproducción desde la pantalla de bloqueo. |
| 7 | **Playlists no implementadas** | La pestaña `Biblioteca` no tiene creación/gestión de playlists. Solo favoritos/descargas/local. |
| 8 | **Cola sin drag & drop real** | `queue_bottom_sheet.dart` tiene el ícono `drag_handle_rounded` pero no implementa `ReorderableListView`. |
| 9 | **Búsqueda por voz falsa** | `_triggerVoiceSearch()` espera 2.5s y fija "Ethereal" hardcodeado. No usa reconocimiento de voz real. |
| 10 | **Ecualizador solo visual** | Los sliders del EQ modifican `SettingsService` pero **no aplican ningún efecto real** al `AudioPlayer`. |
| 11 | **Letras no aparecen en búsquedas online** | Solo canciones del catálogo hardcoded tienen `syncedLyrics`. Canciones de YouTube no tienen letras. La pantalla de letras funciona solo para canciones preconfiguradas. |
| 12 | **Nombre hardcodeado** | "Freddy Rangel" está hardcodeado en `home_screen.dart` y `profile_screen.dart`. No usa datos de usuario guardados. |

### 🟡 MENORES (UX / Estabilidad)

| # | Problema | Causa Raíz |
|---|----------|------------|
| 13 | **Spinner splash desalineado** | En `splash_screen.dart`, el spinner usa `Positioned(bottom: 80)` dentro de un `Stack`. En algunos dispositivos con notch puede verse descentrado. Además usa path incorrecto: `'imagenes/logo.svg'` en vez de `'assets/imagenes/logo.svg'`. |
| 14 | **Overflow en algunos títulos** | La pantalla `LibraryScreen` y `HomeScreen` usan `Padding(top: 20)` dentro de `SafeArea` pero algunos textos largos o en notch grande pueden invadir. |
| 15 | **No hay `SafeArea` en PlayerScreen** | El `PlayerScreen` tiene `SafeArea` pero los `Positioned.fill` del blur background no respetan el sistema. Funciona pero puede haber artefactos en Android con gestos. |

---

## Plan de Implementación

### FASE 1 — Correcciones Críticas

---

#### 1. Reproducción en Segundo Plano con `audio_service`

**Archivos a modificar:**
- `pubspec.yaml` — Agregar `audio_service: ^0.18.15`
- `lib/main.dart` — Inicializar con `AudioService`
- `lib/services/audio_handler.dart` — **REESCRIBIR** extendiendo `BaseAudioHandler` de `audio_service`
- `android/app/src/main/AndroidManifest.xml` — Agregar permisos de servicio y `FOREGROUND_SERVICE`

**Enfoque técnico:**
```dart
// audio_handler.dart — nuevo BaseAudioHandler
class BlowAudioHandler extends BaseAudioHandler 
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  // Conecta streams de just_audio a MediaItem
  // Implementa play/pause/next/previous/seek
  // Actualiza playbackState y mediaItem streams
}
```

El `AndroidManifest.xml` necesita el servicio de `audio_service` para funcionar en background.

---

#### 2. Sistema de Acceso con Persistencia (Invitado)

**Archivos a modificar/crear:**
- `lib/services/settings_service.dart` — Agregar `userName`, `isLoggedIn`
- `lib/screens/login_screen.dart` — **REEMPLAZAR** con pantalla de nombre de usuario (guest onboarding)
- `lib/screens/splash_screen.dart` — Agregar lógica: si ya hay nombre → ir directo a `MainNavigationScreen`
- `lib/screens/home_screen.dart` — Leer nombre desde `SettingsService`
- `lib/screens/profile_screen.dart` — Leer nombre desde `SettingsService`, agregar botón "Cerrar Sesión"

**Flujo:**
```
Splash (3.5s) 
  → [usuario ya registrado?] → MainNavigationScreen
  → [primera vez] → GuestOnboardingScreen (solo pide nombre)
                     → MainNavigationScreen
```

---

#### 3. Reproducción de Canciones de YouTube

**Archivos a modificar:**
- `lib/services/youtube_service_mobile.dart` — Mejorar `getAudioStreamUrl()` con retry y validación
- `lib/screens/search_screen.dart` — Mejorar `onTap` para mostrar loading y manejar errores

**Problema raíz:** Las URLs de stream de YouTube tienen TTL corto (~6h). Necesitamos:
1. Obtener URL fresca justo antes de reproducir
2. Mostrar loading indicator mientras se obtiene
3. Manejar error si falla con SnackBar claro

---

#### 4. Descarga Real de Canciones

**Archivos a modificar:**
- `lib/services/music_service.dart` — `downloadSong()` debe llamar al servicio real, no simular
- `lib/services/youtube_service_mobile.dart` — Verificar headers y manejo de errores en `downloadFile()`
- `android/app/src/main/AndroidManifest.xml` — Agregar `FOREGROUND_SERVICE`, `WRITE_EXTERNAL_STORAGE` correcto

**Problema adicional:** En Android 10+ no se puede escribir en almacenamiento externo sin `MediaStore`. Corregir a usar `getExternalFilesDir()` que no requiere permiso en Android 10+.

---

#### 5. Ícono de Aplicación

**Acciones:**
1. El logo SVG necesita convertirse a PNG (el package `flutter_launcher_icons` no acepta SVG bien)
2. Crear PNG de 1024x1024 del logo BLOW
3. Actualizar `pubspec.yaml` para usar PNG
4. Ejecutar `flutter pub run flutter_launcher_icons`

> [!IMPORTANT]
> Generaré una imagen PNG del logo BLOW usando la herramienta de generación de imágenes, ya que el SVG existe pero `flutter_launcher_icons` lo maneja inconsistentemente. El PNG se usará para los iconos adaptativos de Android.

---

### FASE 2 — Funcionalidades Incompletas

---

#### 6. Notificaciones Multimedia (Media Session)

Al integrar `audio_service` en la Fase 1, esto se resuelve automáticamente. El `BaseAudioHandler` publica:
- `playbackState` → controles play/pause/next/prev en notificación
- `mediaItem` → portada, título, artista en notificación y pantalla de bloqueo

---

#### 7. Gestión de Playlists

**Archivos a crear/modificar:**
- `lib/models/playlist_model.dart` — **NUEVO** modelo `PlaylistModel`
- `lib/services/playlist_service.dart` — **NUEVO** servicio con persistencia JSON local
- `lib/screens/library_screen.dart` — Agregar pestaña "Playlists" con CRUD completo
- `lib/screens/playlist_detail_screen.dart` — **NUEVO** pantalla de detalle de playlist

---

#### 8. Cola con Drag & Drop

**Archivos a modificar:**
- `lib/widgets/queue_bottom_sheet.dart` — Cambiar `ListView.builder` por `ReorderableListView`
- `lib/services/audio_handler.dart` — Agregar método `reorderQueue(int oldIndex, int newIndex)`

---

#### 9. Búsqueda por Voz — Eliminar

Dado que la implementación actual es completamente falsa (hardcoded), y el reconocimiento de voz real requiere el paquete `speech_to_text` más permisos de micrófono y manejo de estados complejos (según los requisitos: si no funciona correctamente, eliminar), **la opción más segura es eliminar el botón de micrófono** y los estados de voice search hasta tener una implementación real.

**Archivos a modificar:**
- `lib/screens/search_screen.dart` — Eliminar botón de micrófono, `_isVoiceSearching`, overlay de voz

---

#### 10. Letras para Canciones Online

**Archivos a modificar:**
- `lib/screens/search_screen.dart` — Al hacer tap en resultado de YouTube, después de obtener URL, llamar a `fetchLyrics()`
- `lib/screens/player_screen.dart` — Al abrir letras, si no hay `syncedLyrics` en el modelo, buscar online
- `lib/services/youtube_service.dart` — `fetchLyrics()` ya funciona, necesita integrarse al flujo de reproducción

---

### FASE 3 — Correcciones de SafeArea y UX

---

#### 11. Splash Screen Centrado

- Mover el spinner de `Positioned(bottom: 80)` a dentro de la `Column` principal con `MainAxisAlignment.center`
- Corregir path del SVG: `'assets/imagenes/logo.svg'`
- Usar `SafeArea` apropiado

#### 12. Persistencia de Nombre de Usuario en Home/Profile

- Leer `settings.userName` en vez de texto hardcodeado

---

## Dependencias a Agregar

```yaml
# pubspec.yaml — nuevas dependencias
audio_service: ^0.18.15
```

> [!WARNING]
> `audio_service` requiere cambios en `AndroidManifest.xml` para registrar el servicio en background. Sin esto, la reproducción en segundo plano NO funcionará en Android 8+.

---

## Archivos que se Modificarán

### Nuevos Archivos
- `lib/models/playlist_model.dart`
- `lib/services/playlist_service.dart`
- `lib/screens/playlist_detail_screen.dart`
- `lib/screens/guest_onboarding_screen.dart`

### Archivos Modificados
- `pubspec.yaml` — audio_service, icono PNG
- `lib/main.dart` — inicialización audio_service
- `lib/services/audio_handler.dart` — BaseAudioHandler completo
- `lib/services/settings_service.dart` — userName, isLoggedIn
- `lib/services/music_service.dart` — downloadSong real
- `lib/services/youtube_service.dart` — integración letras
- `lib/services/youtube_service_mobile.dart` — corrección download path
- `lib/screens/splash_screen.dart` — lógica de sesión + centrado
- `lib/screens/login_screen.dart` → convertir a `guest_onboarding_screen.dart`
- `lib/screens/home_screen.dart` — nombre de usuario dinámico
- `lib/screens/search_screen.dart` — eliminar voz, fix play, fix letras
- `lib/screens/library_screen.dart` — pestaña Playlists
- `lib/screens/player_screen.dart` — fix letras online
- `lib/screens/profile_screen.dart` — nombre dinámico + cerrar sesión
- `lib/widgets/queue_bottom_sheet.dart` — ReorderableListView
- `android/app/src/main/AndroidManifest.xml` — permisos background + FOREGROUND_SERVICE

---

## Plan de Verificación

### Pruebas automatizadas
- `flutter analyze` — sin errores
- `flutter build apk --debug` — compilación exitosa

### Verificación manual en dispositivo físico
1. ✅ Splash centrado en cualquier resolución
2. ✅ Primera vez: solicita nombre → se guarda → nunca vuelve a pedirlo
3. ✅ Reproducción de canción desde catálogo
4. ✅ Búsqueda en YouTube → tap → reproduce
5. ✅ App minimizada → música sigue sonando
6. ✅ Pantalla bloqueada → notificación multimedia con controles
7. ✅ Descarga de canción con progreso real
8. ✅ Reproducción offline de descarga
9. ✅ Letras sincronizadas para canciones del catálogo
10. ✅ Letras buscadas online para canciones de YouTube
11. ✅ Crear/editar/eliminar playlist
12. ✅ Reordenar cola con drag & drop
13. ✅ Ícono de app es BLOW (no Flutter)
14. ✅ SafeArea en todos los dispositivos (notch, punch-hole, barra de navegación dinámica)

---

## Preguntas Abiertas

> [!IMPORTANT]
> **¿Tiene imagen PNG del logo BLOW disponible en el proyecto?**
> El `pubspec.yaml` referencia `assets/imagenes/logo.svg`, pero para los iconos de launcher se necesita PNG de alta resolución (mínimo 1024x1024). Puedo generar uno nuevo basado en el nombre "BLOW" con el estilo de la app.

> [!NOTE]
> **Ecualizador:** La implementación actual del EQ es solo visual (los sliders no aplican efectos reales al audio). Para un EQ real en Flutter/Android se necesita el plugin nativo `flutter_equalizer` o `equalizer` (requiere compilación nativa). En el alcance actual, se marcará claramente como "Visual/Preset" si no se puede implementar de forma nativa, y se desactivará el switch "Dolby Atmos" para que no muestre funcionalidad falsa.

> [!NOTE]
> **YouTube API:** `youtube_explode_dart` puede ser bloqueado ocasionalmente por Google. Las URLs de stream tienen TTL corto. Se implementará manejo de error robusto con re-fetch automático.
