# Tool Lifecycle Standard

Aktueller Nachweisstand: [Current Status](CURRENT_STATUS.md).
Read-only-Abgleich der zwanzig Core-/Betriebswerkzeuge:
`python3 -B scripts/quality/lifecycle_inventory.py --dry-run`.
Dieser Metadatencheck ist keine Implementierung noch fehlender Lifecycle-Aktionen.

Jedes Tool soll langfristig einen vollstaendigen Lifecycle haben. Ziel ist Idempotenz: wiederholtes Ausfuehren darf nicht kaputtmachen.

## Pflichtaktionen

| Aktion | Zweck | Mindestverhalten |
|---|---|---|
| `check` | pruefen, ob Tool nutzbar ist | kein Installieren, Exitcode sinnvoll |
| `install` | Tool installieren | idempotent, Preflight, Logpfad |
| `update` | Tool aktualisieren | keine lokalen Daten zerstoeren |
| `uninstall` | Tool entfernen | keine Daten/Volumes ohne Nachfrage loeschen |
| `doctor` | Fehlerdiagnose | Log, Ports, Versionen, Reparaturtipps |
| `status` | kurzer Zustand | installiert/nicht installiert/fehlerhaft |

## Aktueller Repo-Stand

Viele Tools besitzen bereits `install` und `uninstall`. `check`, `update`, `doctor` und `status` sind noch nicht fuer alle Tools als eigene Dateien vorhanden. Das ist akzeptabel, solange der Audit dies sichtbar macht und neue Tools nach diesem Standard entstehen.

## Dateinamensschema

Empfohlen:

- `scripts/tools/<tool>_check.sh`
- `scripts/tools/<tool>_install.sh`
- `scripts/tools/<tool>_update.sh`
- `scripts/tools/<tool>_uninstall.sh`
- `scripts/tools/<tool>_doctor.sh`
- `scripts/tools/<tool>_status.sh`

## Preflight fuer schwere Tools

Vor schwergewichtigen Tools pruefen:

- Linux/WSL freier Speicher
- Windows-C:-Speicher bei WSL2
- RAM
- Swap
- Docker/Podman/Systemd
- Ports
- bestehende Installation
- Logpfad

Schwere Tools: Airbyte, AutoGPT, OpenHands, ComfyUI, Blender, Nextcloud, n8n, Activepieces, Kubernetes/K3s, Wazuh, Milvus, Coqui TTS.

## Fehlerverhalten

Bei Fehlern:

- Batch stoppen.
- Log anzeigen anbieten.
- Diagnosebericht erzeugen.
- Wiederholen, ueberspringen oder zurueck ins Menue anbieten.
- keine weiteren schweren Tools blind installieren.

## Verbindlicher Zielvertrag fuer neue und migrierte Core-Tools

- Herkunft: konkreter Commit oder Release samt Artefaktpruefung; Update desselben
  Pins und bewusster Versionswechsel sind getrennte Aktionen.
- Doctor/Check/Status sind schreibgeschuetzt. Kein Download, keine Reparatur,
  keine Agenten-/Modellabfrage, keine Portfreigabe und kein Dienststart als Nebeneffekt.
  Eine echte Anfrage oder schreibende Reparatur braucht eine gesonderte Freigabe.
- Install/Update/Uninstall brauchen einen echten `--dry-run`-Pfad mit demselben
  Aktionsplan, ohne Dateien/Marker/Dienste zu aendern. Kein ignorierter Schalter.
- Uninstall bewahrt Nutzerdaten, Volumes, Logs und geteilte Basiswerkzeuge.
  Besitznachweis und kanonische Pfadgrenzen vor jeder Tool-Dateientfernung pruefen.
- Ressourcen: RAM, Linux-Disk, bei WSL Host-Disk und bei Bedarf GPU/VRAM pruefen;
  Modellgewichte und temporaere Builddaten getrennt budgetieren.
- Nachweis: Plattform, Source-/Artefakt-Pin, Testdatum, Testbefehl und Exitcode.
  Ein Build-/Quellmarker allein darf keine laufende gesunde Anwendung behaupten.
- Reifegrad (`planned`/`experimental`/`stable`) und Bereitschaft (`source-ready`/
  `runtime-ready`/`not-tested`) getrennt speichern. Keine Schemawerte ohne
  Validator-/Menue-/Migrationsanpassung in die Legacy-Registry eintragen.

Abnahme pro Tool: Quellen-Fixture, fehlende Abhaengigkeit, unveraenderter zweiter
Installationslauf, abgebrochener Build ohne Erfolgsmarker, Doctor ohne Seiteneffekt,
Update ohne Fremddatenverlust und Uninstall mit erhaltenen Test-Nutzerdaten.
Erst danach darf ein konkreter Core-Lifecycle als umgesetzt markiert werden.
