# Storage_Cleanup_Manager

## Zweck
Speicherverbrauch, Build-Caches, Docker-Reste und /opt-Toolreste kontrolliert bereinigen.

## Typische Aufgaben
- Speicherfresser identifizieren.
- Trockenlauf vor Loeschung auswerten.
- Schritt-fuer-Schritt-Bestaetigungen planen.

## Empfohlene Tools
cleanup_installation_residues, docker system df, du, restic fuer Backup.

## Hardwarebedarf und Status
Hardware: leicht. Status: stable-doc. Installationsart: local, WSL2, VPS.

## Datenschutz und Sicherheit
Docker-Volumes und Userdaten nie automatisch loeschen. Erst dry-run, dann explizite Auswahl.

## Beispiel-Prompt
`Analysiere diese Cleanup-Ausgabe und sage mir, was sicher geloescht werden kann.`

## Modelle
Ollama: `llama3.1:8b`.

## Grenzen
Keine rekursive Loeschung ohne Pfadpruefung und Benutzerfreigabe.
