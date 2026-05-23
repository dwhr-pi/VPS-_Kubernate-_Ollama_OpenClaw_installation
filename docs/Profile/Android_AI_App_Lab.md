# Android AI App Lab

Status: `planned`  
Hardwarebedarf: `medium`  
Installationsart: Linux-PC, WSL2 mit Android-SDK-Pfaden, GPU nicht erforderlich

## Zweck

Android-App-Building mit Codex/OpenClaw: Gradle-Projekte pruefen, APKs bauen, Debugging vorbereiten und F-Droid-kompatible Open-Source-Apps analysieren.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| Android SDK CLI | Build-Tools, Plattformen, Emulator optional | geplant |
| Gradle/Kotlin/Java | Android-Builds | empfohlen |
| adb/scrcpy | Geraetezugriff und Bildschirmspiegelung | optional |
| apktool/jadx | Defensive APK-Analyse | optional |
| MobSF/Frida | Nur defensive lokale Analyse | experimentell |

## OpenClaw-Agenten

- Android-Build-Agent: analysiert Gradle-Fehler und schlaegt Fixes vor.
- APK-Review-Agent: prueft Berechtigungen und Netzwerkzugriffe defensiv.
- MyExplorer/myBOX-Agent: bereitet Companion-App-Aufgaben fuer OpenClaw/Codex vor.

## Sicherheitsregeln

- Keine fremden APKs ohne Rechte analysieren.
- Keine Umgehung von App-Schutzmechanismen dokumentieren.
- Signing-Keys nie ins Repository schreiben; nur `.env.example` oder lokale Keystores.
