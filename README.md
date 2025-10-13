# Misclicked Bingo 🎯

A Flutter Web + Dart Frog bingo game with Discord OAuth authentication.

## 📁 Project Structure

```
monorepo/
├── packages/
│   ├── shared_models/       # Shared Dart models
│   ├── backend/             # Dart Frog API
│   └── frontend/            # Flutter Web app
├── melos.yaml               # Monorepo configuration
└── globe.yaml               # Globe deployment config
```

### Frontend Structure (Feature-First)

```
frontend/lib/
├── features/
│   ├── admin/              # Admin feature
│   │   ├── data/           # Repositories
│   │   ├── logic/          # BLoCs
│   │   └── presentation/   # Screens
│   ├── auth/               # Auth feature
│   └── lobby/              # Lobby feature
├── core/                   # Shared code
│   ├── di.dart             # Dependency injection
│   └── widgets/            # Reusable widgets
├── router/                 # Navigation
└── theme/                  # Styling
```

See `frontend/lib/PROJECT_STRUCTURE.md` for detailed docs.

## 🚀 Getting Started

### Prerequisites
- Flutter 3.35.6+
- Dart 3.9.4+
- Melos (`dart pub global activate melos`)

### Local Development

```bash
# Bootstrap monorepo
melos bootstrap

# Run backend
cd packages/backend
dart_frog dev

# Run frontend (in another terminal)
cd packages/frontend
flutter run -d chrome
```

## 🌐 Deployment (Globe.dev)

### Backend
1. Create Dart Frog project in Globe
2. Enable **Melos** toggle
3. Build Command: `cd packages/backend && dart_frog build`
4. Entrypoint: `packages/backend/build/bin/server.dart`
5. Set environment variables (Discord, JWT, etc.)

### Frontend
1. Create Flutter Web project in Globe
2. Enable **Melos** toggle
3. Build Command: `cd packages/frontend && flutter build web --release --dart-define=API_BASE=<backend-url>`
4. Entrypoint: `packages/frontend/lib/main.dart`

See `DEPLOYMENT.md` for complete guide.

## 🏗️ Architecture

- **Frontend**: Flutter Web with BLoC pattern
- **Backend**: Dart Frog REST API
- **Database**: Drift (SQLite)
- **Auth**: Discord OAuth2 + JWT cookies
- **State**: BLoC for business logic
- **DI**: GetIt for dependency injection

See `ARCHITECTURE.md` and `STRUCTURE_REFACTOR.md` for details.

## ✨ Features

- ✅ Discord OAuth login
- ✅ Role-based access (user/captain/admin)
- ✅ Game management (admin)
- ✅ Clean architecture with repositories
- ✅ Web-native sidebar navigation
- ✅ Material 3 dark theme

## 📚 Documentation

- `DEPLOYMENT.md` - Deployment guide
- `ARCHITECTURE.md` - Clean architecture docs
- `STRUCTURE_REFACTOR.md` - Why we reorganized
- `frontend/lib/PROJECT_STRUCTURE.md` - Frontend structure
- `FEATURES_ADDED.md` - Recent features

## 🛠️ Tech Stack

**Frontend:**
- Flutter Web
- flutter_bloc
- go_router
- dio
- get_it
- Material 3

**Backend:**
- Dart Frog
- Drift (SQLite)
- dart_jsonwebtoken
- uuid

**Shared:**
- json_serializable
- equatable

## 📝 License

MIT
