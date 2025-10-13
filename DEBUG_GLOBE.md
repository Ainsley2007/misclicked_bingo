# Globe Frontend Build Debug

## Current Status
- ✅ Backend deploys successfully
- ✅ Local frontend builds successfully
- ✅ Melos bootstrap succeeds on Globe
- ❌ Frontend fails during Assets phase (0.2s) with "Null check operator used on a null value"

## What We've Tried
1. Committed shared_models generated files
2. Removed usePubspecOverrides from melos.yaml
3. Standardized SDK constraint format
4. Simplified build command to: `cd packages/frontend && flutter build web`

## Next Steps

### Test 1: Create minimal Flutter web app
Create a separate minimal Flutter web project in Globe to isolate if it's:
- A) Globe's Flutter 3.35.6 environment issue
- B) Our specific code/dependencies

### Test 2: Request detailed Globe logs
Contact Globe support and request:
- Full verbose build logs (`flutter build web --verbose`)
- Stack trace of the null check error
- Which file/line is causing the null check failure

### Test 3: Try different Globe settings
- Change Flutter version to 3.24.0 (LTS)
- Disable Melos temporarily
- Try building from a different branch

### Test 4: Check if it's a dependency issue
Try temporarily removing dependencies one by one:
1. Remove `intl` 
2. Remove `web`
3. Remove `go_router`
4. Keep only essential Flutter + dio + bloc

## Globe Build Command
Current: `cd packages/frontend && flutter build web`

Globe adds automatically: `--pwa-strategy none --no-web-resources-cdn -t lib/main.dart`

## Question for Globe Support
"Our Flutter web build consistently fails during the Assets phase (0.2s) with 'Null check operator used on a null value'. The same code builds successfully locally with Flutter 3.32.7. Backend (Dart Frog) deploys successfully. Melos bootstrap succeeds. Can you provide verbose build logs or the stack trace showing where the null check fails?"

