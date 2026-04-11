# SecureMail Flutter

Cross-platform SecureMail client (Flutter): Riverpod, Dio, secure storage, Firebase messaging, routing with **go_router**.

## Tech stack

- **Flutter** (Dart SDK `>=3.0.0 <4.0.0`)
- **flutter_riverpod**, **dio**, **go_router**
- **flutter_secure_storage**, **google_sign_in**, etc.

## Ports (relevant when using Flutter Web)

| Deployment | URL |
|------------|-----|
| Local `flutter run -d chrome` | Varies (Flutter tool picks a port) |
| Docker Compose profile `flutter` | http://localhost:8080 (nginx serving `build/web`) |

The app talks to the **backend REST API**, not to the AI gRPC service directly.

## Environment / configuration

Point the HTTP client at the same base URL as the web app:

| Setting | Purpose |
|---------|---------|
| API base URL | Must match your deployed **SecureMail-Backend** (e.g. `http://localhost:3000` in dev) |

If you add `--dart-define=API_BASE_URL=...` for CI/Docker web builds, read that constant in your Dio `BaseOptions` (wire-up is project-specific).

## API documentation & code generation

REST contracts are defined by the backend OpenAPI spec:

| Resource | URL (backend local default) |
|----------|-----------------------------|
| Swagger UI | http://localhost:3000/api/docs |
| **OpenAPI JSON** | http://localhost:3000/api/docs-json |

**Suggested workflow**

1. Start the backend (or use a staging URL).
2. Download: `openapi.json` from `GET /api/docs-json`.
3. Generate Dart models/clients with [openapi_generator](https://pub.dev/packages/openapi_generator) or your preferred OpenAPI → Dart toolchain.
4. Keep generated code in sync when the backend bumps the API (re-fetch JSON on each contract change).

**Auth:** use `Authorization: Bearer <token>` from `POST /auth/login` or `POST /auth/verify-2fa` (see Swagger).

## Run locally (step-by-step)

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and run `flutter doctor`.
2. From `SecureMail-Flutter`:
   ```bash
   flutter pub get
   ```
3. Configure your API base URL in the app’s config (where Dio is set up).
4. Run on a device or emulator:
   ```bash
   flutter run
   ```
5. For web only:
   ```bash
   flutter run -d chrome
   ```

## Run with Docker (Flutter **Web** only)

The repo includes an optional Compose service that builds **web** and serves it with nginx:

```bash
cd ..   # monorepo root
docker compose --profile flutter up --build flutter-web
```

Then open **http://localhost:8080**.

Native iOS/Android builds are **not** produced by this Dockerfile; use Flutter tooling locally or CI (Fastlane, Codemagic, etc.).

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| SSL / certificate errors | Dev often uses `http://localhost`; production needs valid certs. |
| 401 on all routes | Token missing/expired; refresh login flow. |
| CORS (web only) | Backend `FRONTEND_URL` / CORS must allow your Flutter web origin. |
| Outdated models | Regenerate from latest `/api/docs-json`. |

## Related docs

- [Monorepo README](../README.md) — architecture, Compose, all service URLs
- [Backend README](../SecureMail-Backend/README.md) — Swagger paths, env vars
