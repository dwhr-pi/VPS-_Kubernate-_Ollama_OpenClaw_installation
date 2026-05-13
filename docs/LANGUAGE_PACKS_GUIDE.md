# Sprachpakete fuer Setup und Tools

Dieses Setup kann neben den eingebauten Sprachdateien auch **nachinstallierbare Sprachpakete** laden.

Der erste Anwendungsfall ist bewusst einfach:

- vorhandene Setup-Sprache `de` mit Overlay-Texten erweitern
- spaeter deutsche Hinweise fuer einzelne Tools sammeln
- die Pakete spaeter in ein eigenes Repo auslagern und wieder nachinstallieren

## Ziel

Die Sprachpakete sollen nicht das ganze Setup hart forken, sondern nur ergaenzende oder ueberschreibende Texte liefern.

Typische spaetere Inhalte:

- Setup-Menue-Texte
- Tool-Hinweise
- deutsche Hilfedateien
- Beispiel-Snippets fuer Huginn, OpenClaw, Home Assistant oder weitere Tools

## Ablage im Benutzer-Workspace

Installierte Sprachpakete landen unter:

```bash
~/.openclaw_ultimate_user_data/language_packs/
```

Jedes Paket hat dort seinen eigenen Ordner.

## Aufbau eines Sprachpakets

Minimale Struktur:

```text
mein_sprachpaket/
├── manifest.conf
└── setup/
    └── de.sh
```

Beispiel fuer `manifest.conf`:

```bash
PACK_ID="de_core_ui"
PACK_NAME="Deutsch: Setup-Kerntexte und Tool-Hinweise"
PACK_LANGUAGE="de"
PACK_VERSION="0.1.0"
PACK_ENABLED="true"
PACK_DESCRIPTION="Starter-Paket fuer deutsche Setup-Kerntexte, Tool-Hinweise und spaetere Erweiterungen."
```

## Setup-Overlay-Datei

Eine Datei wie `setup/de.sh` wird **nach** der eingebauten `scripts/lang/de.sh` geladen.

Damit kann ein Paket spaeter gezielt Texte ueberschreiben, zum Beispiel:

```bash
TXT_MENU_14="Installierte Dienste zentral starten"
TXT_OPTIONS_10="Huginn Konfiguration (sichere Vorlage)"
```

## Tool-spezifische Inhalte

Fuer deutsche Tool-Hinweise kannst du spaeter zusaetzlich eigene Unterordner anlegen, zum Beispiel:

```text
tools/huginn/
tools/openclaw/
tools/home_assistant/
docs/
```

Diese Inhalte werden aktuell noch nicht automatisch im Laufzeit-UI eingeblendet, koennen aber schon als strukturierte deutsche Quelle mitgeliefert werden.

## Verwaltung im Setup

Im Setup gibt es jetzt:

- `Optionen`
- `Sprachpakete verwalten`

Dort kannst du aktuell:

- das deutsche Starter-Paket aus diesem Repo installieren
- ein Sprachpaket aus einem lokalen Ordner installieren
- ein Sprachpaket aus einem Git-Repo installieren
- installierte Pakete anzeigen
- Pakete aktivieren oder deaktivieren
- Pakete wieder entfernen

## Installation aus einem anderen Repo

Wenn du spaeter ein eigenes Repo mit Sprachpaketen hochlaedst, sollte es idealerweise so aufgebaut sein:

```text
mein-repo/
└── language_packs/
    ├── de_core_ui/
    └── de_tool_docs/
```

Dann kann der Sprachpaket-Manager das Repo klonen und alle enthaltenen Pakete uebernehmen.

## Aktueller Starter-Pack

Dieses Repo enthaelt bereits ein erstes deutsches Beispiel:

```text
language_packs/de_core_ui/
```

Es ist bewusst klein gehalten und dient als Vorlage fuer spaetere Auslagerung in ein eigenes Repo.
