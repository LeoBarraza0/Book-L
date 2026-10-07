<p align="center">
  <img src="book_l/assets/images/logo.svg" alt="Book-L" width="260" />
</p>

<p align="center">
  <b>Collaborative micro-learning mobile app built with Flutter and Supabase.</b><br>
  Create courses, learn through short lessons, practice with graded exercises and keep your streak going.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-PostgreSQL%20%C2%B7%20Storage-3FCF8E?style=flat-square&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/State-Provider-7B61FF?style=flat-square" alt="Provider" />
  <img src="https://img.shields.io/badge/Architecture-Hexagonal-F7931E?style=flat-square" alt="Hexagonal architecture" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%C2%B7%20iOS%20%C2%B7%20Web-555?style=flat-square" alt="Platforms" />
</p>

---

## Features

| | |
| --- | --- |
| 🔐 **Accounts** | Sign up and login with hashed passwords, password recovery by email, profile editing, followers |
| 📚 **Courses & lessons** | Create and edit courses; lessons split into chapters with video, PDF and rich-text content |
| 🧩 **Exercises** | Ordering, fill-in-the-blank, short answer and theory questions, with automatic grading and results |
| 💬 **Community** | Discussion forums with nested replies and likes, course ratings and content reports |
| 🔥 **Progress** | Learning progress, daily streaks, saved items and notifications |
| 🔎 **Discovery** | Search with filters, onboarding flow and an in-app assistant chatbot |
| 🛠️ **Admin** | Moderation panel for users, lessons and reported content |

## Architecture

Book-L follows **hexagonal architecture (ports and adapters) organized by feature**: 17 isolated modules under `lib/features/`, each with the same three layers and dependencies pointing inward.

```mermaid
flowchart LR
  UI["Screens & widgets"] --> C["Controller<br/>(ChangeNotifier + Provider)"]
  C --> UC["Use case"]
  UC --> P["Repository port<br/>(interface)"]
  P -.implemented by.-> R["Repository adapter"]
  R --> S[("Supabase<br/>PostgreSQL · Storage")]
  R --> L[("Local cache<br/>SharedPreferences")]
```

```
lib/
├── core/        # router, theme, global state, Supabase client, error handling
├── shared/      # reusable widgets (video player, rich-text editor, filters, modals)
└── features/
    └── <feature>/
        ├── domain/          # pure Dart models, no Flutter imports
        ├── application/     # use cases + output ports
        └── infrastructure/
            ├── adapters/in/   # screens, widgets, controllers
            └── adapters/out/  # repository implementations, DTOs
```

- **Remote data, local fallback:** repositories work against Supabase and fall back to a local JSON snapshot in SharedPreferences when the backend is unreachable.
- **Predictable state:** controllers expose state through `ChangeNotifier`; the UI rebuilds with Provider and `ListenableBuilder`.
- Design notes, use cases and class diagrams: [`ARQUITECTURA_BOOKL.md`](book_l/ARQUITECTURA_BOOKL.md), [`casosdeuso.json`](book_l/casosdeuso.json), [`diagramaclases.json`](book_l/diagramaclases.json) (Spanish).

## Tech stack

- **App:** Flutter · Dart · Provider · flutter_quill · video_player · flutter_pdfview · image_picker / file_picker
- **Backend:** Supabase (PostgreSQL, Storage) · password hashing with `crypto` · email recovery
- **Quality:** flutter_lints · unit and database tests in `book_l/test/`

## Getting started

```bash
git clone https://github.com/LeoBarraza0/Book-L.git
cd Book-L/book_l
flutter pub get
flutter run            # choose an Android/iOS emulator or Chrome
flutter test
```

The database schema is in [`book-l_supabase.sql`](book_l/book-l_supabase.sql). To use your own Supabase project, run it there and update the URL and anon key in `lib/core/infrastructure/services/supabase_client.dart`. Without a reachable backend the app runs on the sample data in `assets/data/`.

## Team

Built by **[Leonardo Barraza](https://github.com/LeoBarraza0)** and **Freddy Rangel**.
