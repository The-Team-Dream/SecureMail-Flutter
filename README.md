# SecureMail Flutter

A cross-platform mobile client for SecureMail.

## ✅ Run Options

### 1. Via Turborepo (Root)
To build the web version:
```bash
npm run dev:flutter
```

### 2. Manual Execution
1. **Dependencies**:
   ```bash
   flutter pub get
   ```
2. **Run**:
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture
- **State Management**: Riverpod.
- **Networking**: Dio (pointing to Backend API on port 3000).
- **Navigation**: go_router.
