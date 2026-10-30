# Installation aus einem privaten Repository

Die fruehere V4-Anleitung empfahl Tokens in Clone-URLs und `curl | bash`. Diese unsicheren Verfahren
sind zurueckgezogen: URLs landen in Git-Konfigurationen, Logs und Prozessargumenten. Ein Loeschen
der Shell-History behebt diese Offenlegung nicht.

## Zugriff vorbereiten

Einen bereits eingerichteten SSH-Zugang oder einen geschuetzten Git-Credential-Manager verwenden.
Keine Schluessel hier hochladen und keine Zugangsdaten in URLs, Skripte oder Git schreiben.

Falls ein PAT benoetigt wird, unter
[GitHub Fine-grained Tokens](https://github.com/settings/tokens?type=beta) nur das eigene Repository
und `Contents: Read-only` freigeben, kurze Laufzeit setzen und den Token ausschliesslich im
Credential-Manager hinterlegen. Bereits ueber URL oder Prozessargumente offengelegte Tokens
widerrufen und ersetzen. Keine fremden Credentials auslesen.

## Zuerst nur Quellen herunterladen

Die folgenden Befehle setzen einen bereits eingerichteten und separat geprueften SSH-Zugang voraus.
Sie starten keinen Installer:

```bash
git clone --no-recurse-submodules git@github.com:dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git openclaw_setup
cd openclaw_setup
git status --short
git rev-parse HEAD
```

Repository-Inhalt allein ist kein unabhaengiger Vertrauensanker. Vor Ausfuehrung dem
[signierten Release-Pfad](SIGNED_RELEASES.md) mit separat erhaltenem Minisign-Schluessel folgen.
Ohne verifizierte Signatur keine Release-Installation. Unsigniertes Main oder ein Featurebranch ist
keine gleichwertige sichere Alternative; Ausnahmen bleiben bewusstes Opt-in.

## Betrieb

Benutzerdaten und `.env` bleiben im externen Workspace `~/.openclaw_ultimate_user_data`, niemals im
Checkout. Zugangsdaten nicht an Support-Adressen senden. Nicht mehr benoetigte PATs widerrufen; ein
SSH-Schluessel muss nicht fuer jeden Installationsversuch neu erstellt werden. Der private Download
ersetzt weder Code-Review noch Integritaetspruefung.
