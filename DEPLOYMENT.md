# Deployment Guide - Globe + Melos Monorepo

This project uses a Melos monorepo with `shared_models` used by both frontend and backend.

## 📦 Monorepo Structure

```
root/
  ├── melos.yaml              # Monorepo config at ROOT
  ├── packages/
  │   ├── shared_models/      # Shared Dart models
  │   ├── backend/            # Dart Frog API
  │   └── frontend/           # Flutter Web
```

## 🚀 Globe Dashboard Configuration

**CRITICAL**: Root Directory must be the repo root for Melos to work!

### Backend Project Settings:

1. **Framework Preset**: Dart Frog
2. **Root Directory**: `Ainsley2007/misclicked_bingo` (just your repo name - NOT `packages/backend`)
3. **Build Command**: `cd packages/backend && dart_frog build`
4. **Entrypoint**: `packages/backend/build/bin/server.dart`
5. **Dart Version**: 3.9.4 (or latest)
6. **Build Runner**: ✅ **ON** (backend needs Drift code generation)
7. **Melos**: ✅ **ON** (required for shared_models)

### Frontend Project Settings:

1. **Framework Preset**: Flutter
2. **Root Directory**: `Ainsley2007/misclicked_bingo` (just your repo name - NOT `packages/frontend`)
3. **Build Command**: `cd packages/frontend && flutter build web`
4. **Entrypoint**: `packages/frontend/build/web` (or leave default)
5. **Flutter Version**: 3.35.6 (or latest)
6. **Build Runner**: ❌ **OFF** (frontend doesn't need it)
7. **Melos**: ✅ **ON** (required for shared_models)

### Why This Configuration Works:

1. **Root Directory at repo root** → Melos finds `melos.yaml`
2. **Melos ON** → Runs `melos bootstrap` before build
3. **Build command with `cd`** → Navigates to correct package
4. **`shared_models` path dependency** → Resolved by Melos

### Option 2: Globe CLI

You can deploy from the monorepo root using the CLI:

```bash
# From repo root
melos bootstrap  # First time only

# Deploy backend
cd packages/backend
globe deploy

# Deploy frontend
cd packages/frontend
globe deploy
```

The CLI will detect the monorepo structure automatically.

## 🔧 How Melos Works with Globe

When Globe detects `melos.yaml` at the repo root, it:

1. Runs `melos bootstrap` which:
   - Links `shared_models` to both `frontend` and `backend`
   - Resolves all dependencies
   - Creates `.dart_tool/package_config.json` with proper paths

2. The `path: ../shared_models` dependencies now work because Melos creates symlinks/references that work in the deployment environment

## ✅ Prerequisites

### 1. Ensure melos.yaml is correct:
```yaml
name: bingo-globe
packages:
  - packages/**
command:
  bootstrap:
    usePubspecOverrides: true
```

### 2. Ensure shared_models is properly referenced:

**In packages/backend/pubspec.yaml:**
```yaml
dependencies:
  shared_models:
    path: ../shared_models
```

**In packages/frontend/pubspec.yaml:**
```yaml
dependencies:
  shared_models:
    path: ../shared_models
```

## 🎯 Environment Variables

Set these in Globe Dashboard for each project:

### Backend:
```
DISCORD_CLIENT_ID=your_client_id
DISCORD_CLIENT_SECRET=your_secret
DISCORD_REDIRECT_URI=https://your-backend-url/auth/discord/callback
JWT_SECRET=your_secret_here
FRONTEND_ORIGIN=https://your-frontend-url
COOKIE_DOMAIN=.yourdomain.com
```

### Frontend:
```
API_BASE=https://your-backend-url
```

Or use `--dart-define` in build command:
```bash
flutter build web --dart-define=API_BASE=https://your-backend-url
```

## 🔄 Continuous Deployment

Set up GitHub Actions or use Globe's automatic deployments:

1. **Globe Auto-Deploy**: Enable in project settings
   - Deploys on every push to `main`
   - Runs `melos bootstrap` automatically
   - Builds and deploys your package

2. **GitHub Actions**: See `.github/workflows/` (if you want custom CI/CD)

## 🐛 Troubleshooting

### "Can't find package:shared_models"

**Cause**: Melos didn't bootstrap properly

**Fix**:
1. Check Globe build logs for `melos bootstrap` output
2. Ensure `melos.yaml` is at repo root
3. Ensure package paths are correct in pubspec.yaml

### "Invalid value for 'path'"

**Cause**: Trying to deploy individual package without monorepo context

**Fix**: 
- Deploy from repo root (not from `packages/backend` alone)
- Or ensure Globe knows about the monorepo (set root directory correctly)

### Build succeeds locally but fails on Globe

**Cause**: Local `.dart_tool` cache differs from Globe environment

**Fix**:
```bash
# Clean and test locally
melos clean
melos bootstrap
cd packages/backend && dart pub get
cd packages/frontend && flutter pub get
```

Then commit and push.

## 📝 Deployment Checklist

- [ ] `melos.yaml` exists at repo root
- [ ] Both packages reference `shared_models` via `path: ../shared_models`
- [ ] Backend env vars set in Globe dashboard
- [ ] Frontend API_BASE configured
- [ ] Discord OAuth redirect URLs updated
- [ ] Custom domains configured (optional)
- [ ] Tested build locally with `melos bootstrap`

## 🌐 Custom Domains (Optional)

For stable URLs:

1. **Backend**: `api.yourdomain.com`
   - Add CNAME in Globe dashboard
   - Update DNS
   - Update Discord OAuth redirect URLs

2. **Frontend**: `app.yourdomain.com`
   - Add CNAME in Globe dashboard
   - Update DNS
   - Set `COOKIE_DOMAIN=.yourdomain.com` in backend

## 🎉 Success!

After deployment:
- Backend: `https://your-backend-url`
- Frontend: `https://your-frontend-url`
- Both can import from `shared_models` seamlessly
- Melos keeps them in sync

## 💡 Pro Tips

1. **Local Development**: Always run `melos bootstrap` after `git clone`
2. **Dependency Updates**: Run `melos exec -- dart pub upgrade` to update all packages
3. **Clean Slate**: Use `melos clean` to remove all generated files
4. **Versioning**: Use `melos version` to bump versions across packages

