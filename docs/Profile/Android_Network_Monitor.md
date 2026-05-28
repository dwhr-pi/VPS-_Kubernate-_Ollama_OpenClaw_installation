# Android_Network_Monitor

## Zweck
Android-Netzwerkverhalten eigener Apps und Testgeraete defensiv beobachten.

## Typische Aufgaben
- ADB-Logs und lokale Netzwerkzugriffe auswerten.
- Testgeraete ueber Tailscale oder isoliertes WLAN anbinden.
- Datenschutz- und Telemetrieverhalten dokumentieren.

## Empfohlene Tools
ADB, mitmproxy optional, jadx/apktool fuer eigene APKs, Tailscale, Wireshark optional.

## Hardwarebedarf und Status
Hardware: leicht bis mittel. Status: planned. Installationsart: local, Windows/WSL2 mit USB-Hinweisen.

## Datenschutz und Sicherheit
Nur eigene Geraete, Testapps oder autorisierte Analysen. Keine fremden Apps/Konten abfangen.

## Beispiel-Prompt
`Erstelle eine Checkliste fuer defensives Netzwerkmonitoring meiner eigenen Android-Testapp.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5-coder:7b`.

## Grenzen
Keine Umgehung von Schutzmechanismen oder Analyse fremder Geraete.
