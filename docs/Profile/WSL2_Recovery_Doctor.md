# WSL2_Recovery_Doctor

## Zweck
WSL2-Probleme wie langsamer Start, volle VHDX, Docker-Fehler und Dateimodus-Abweichungen diagnostizieren.

## Typische Aufgaben
- Speicher, Windows-Host-Platz und WSL-Dateisystem pruefen.
- Docker-/systemd-/Git-Status erklaeren.
- sichere Reparaturschritte vorschlagen.

## Empfohlene Tools
doctor.sh, check_setup_updates.sh, cleanup_installation_residues, docker system df.

## Hardwarebedarf und Status
Hardware: leicht. Status: stable-doc. Installationsart: WSL2.

## Datenschutz und Sicherheit
Diagnoseausgaben koennen Pfade und Hostnamen enthalten. Vor E-Mail-Versand redigieren.

## Beispiel-Prompt
`Diagnostiziere meinen WSL2-Setup-Start: langsam, Git zeigt viele M, Docker hat Airbyte-Reste.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5-coder:7b`.

## Grenzen
Kein `git reset --hard` oder Loeschen ohne Backup/Freigabe.
