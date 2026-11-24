# BINGO ET v3.0 — Finalized Web Portal & Android Release Bundle

## Included Assets & Configurations
1. **Official BINGO ET Logo Included**:
   * `web/logo.png` (header icon & favicon)
   * `android_flutter/assets/images/logo.png` (in-app Flutter branding)
   * `android_flutter/android/app/src/main/res/mipmap-*/ic_launcher.png` & `ic_launcher_round.png` (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`)
2. **Release Signing & Play Store Pipeline**:
   * `android_flutter/android/app/build.gradle.kts` automatically loads `android/key.properties` for release signing when present, and falls back safely for CI test builds.
   * `android_flutter/.github/workflows/main.yml` decodes `KEYSTORE_BASE64` from GitHub Secrets (if set) and outputs both `app-release.apk` and `app-release.aab` (Google Play format).
3. **Payment & Account Configuration**:
   * **Account Holder**: `Kibur shiferaw kassa`
   * **Telebirr**: `0912341486`, `0941705946`
   * **CBE**: `1000058081624`
   * **BOA**: `82323805`

4. **Language Choice Support (Web & Flutter Android)**:
   * **Amharic** (`am` / አማርኛ)
   * **Afan Oromo** (`om` / Afaan Oromoo)
   * **Tigrigna** (`ti` / ትግርኛ)
   * **English** (`en` / English)
   * **Arabic** (`ar` / العربية — includes RTL layout direction)
   * **Others** (`other` / Others)
