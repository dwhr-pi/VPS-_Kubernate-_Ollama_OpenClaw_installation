# Tool Lifecycle Standard

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
