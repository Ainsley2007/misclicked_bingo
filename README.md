# Bingo Globe - Monorepo

A three-package monorepo for a bingo application with Discord OAuth2 authentication.

## Structure

```
root/
  melos.yaml              # Monorepo configuration
  globe.yaml              # Globe deployment config
  packages/
    shared_models/        # Pure Dart models with json_serializable
    backend/              # Dart Frog API server
    frontend/             # Flutter Web application
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.8.1)
- Dart SDK (>=3.8.0)
- Melos (`dart pub global activate melos`)
- Dart Frog CLI (`dart pub global activate dart_frog_cli`)
- Globe CLI (`dart pub global activate globe_cli`)

### Setup

Bootstrap all packages:

```bash
melos bootstrap
```

Generate JSON serialization code:

```bash
cd packages/shared_models
dart run build_runner build -d
```

### Development

**Backend:**
```bash
cd packages/backend
dart_frog dev
```

**Frontend:**
```bash
cd packages/frontend
flutter run -d chrome
```

### Deployment

Both frontend and backend will be deployed to Globe.dev using the Globe CLI or GitHub integration.

## Tech Stack

- **Shared Models:** json_serializable, equatable
- **Backend:** Dart Frog, Globe DB (SQLite), JWT authentication, Discord OAuth2
- **Frontend:** Flutter Web, BLoC pattern, Material 3 dark theme, GoRouter

## Next Steps

1. Set up database schema and migrations
2. Implement Discord OAuth2 flow
3. Create JWT authentication middleware
4. Build role-based UI (user/captain/admin)
5. Deploy to Globe.dev

