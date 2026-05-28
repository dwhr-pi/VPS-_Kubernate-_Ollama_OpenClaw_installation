# android_tools

Status: `documentation-first`

## Zweck
Android-Building, APK-Analyse, Companion-App-Planung und Privacy-Firewall-Konzepte vorbereiten.

## Modelle
- Lokal/Ollama: Build-/Code-Erklaerungen
- Optional extern: nur fuer Open-Source-Code ohne Secrets

## Tools
Android Studio, Android SDK CLI, Gradle, Kotlin, adb, jadx, apktool, scrcpy.

## Beispielprompt
`Erstelle eine Build-Checkliste fuer eine Android-App unter Windows 11, WSL2 und Android Studio.`

## Sicherheitsregeln
Nur eigene Apps oder explizit erlaubte Open-Source-Apps analysieren. Keine Signing-Keys ins Repo.

## Speicher-/Kostenkontrolle
SDK/Gradle-Caches dokumentieren und Cleanup anbieten.

## Workflows
Clone -> Build -> Test -> Signing-Check -> Datenschutzcheck -> Release-Notizen.

## OpenClaw-Agent
`android-build-agent`: Build-Hilfe und Checklisten, keine Veroeffentlichung automatisieren.
