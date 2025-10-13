# Backend - Dart Frog API

[![style: dart frog lint][dart_frog_lint_badge]][dart_frog_lint_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dart-frog.dev)

Dart Frog backend for Bingo Globe with Discord OAuth2 authentication and Globe DB.

## Features

- 🔐 Discord OAuth2 authentication
- 🍪 JWT-based sessions (HttpOnly cookies)
- 🗄️ Globe DB (SQLite-compatible) with auto-migrations
- 👥 Role-based access (user, captain, admin)
- 🎯 Team management APIs

## Setup

### 1. Environment Variables

Copy `env.example` to `.env` and fill in your values:

```bash
cp env.example .env
```

Required variables:
- `DISCORD_CLIENT_ID` - From Discord Developer Portal
- `DISCORD_CLIENT_SECRET` - From Discord Developer Portal
- `DISCORD_REDIRECT_URI` - Your callback URL
- `JWT_SECRET` - Generate with `openssl rand -base64 32`
- `GLOBE_DB_URL` - From Globe dashboard
- `GLOBE_DB_TOKEN` - From Globe dashboard
- `FRONTEND_ORIGIN` - Your frontend URL
- `COOKIE_DOMAIN` - Cookie domain (e.g., `.yourdomain.com`)

### 2. Run Development Server

```bash
dart_frog dev
```

Server runs on `http://localhost:8080`

## Database

### Schema

Tables:
- `users` - User accounts with Discord OAuth data
- `games` - Game instances with unique 6-char codes
- `teams` - Teams within games
- `team_members` - Join table for team membership

### Migrations

Migrations are in `migrations/` and run automatically on server start.

To add a new migration, create `migrations/00X_description.sql`.

## Project Structure

```
backend/
├── lib/
│   ├── db.dart              # Database client singleton
│   └── run_migrations.dart  # Migration runner
├── main.dart                # Server entry with DB init
├── routes/
│   ├── _middleware.dart     # Global middleware
│   └── index.dart           # Health check route
└── migrations/
    └── 001_init.sql         # Initial schema
```

[dart_frog_lint_badge]: https://img.shields.io/badge/style-dart_frog_lint-1DF9D2.svg
[dart_frog_lint_link]: https://pub.dev/packages/dart_frog_lint