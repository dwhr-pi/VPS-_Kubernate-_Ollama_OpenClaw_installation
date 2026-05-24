# Tutorial: Integritaetspruefung und automatisierter Support

Dieses Tutorial beschreibt, wie das Ultimate KI Setup gegen unbemerkte Veraenderungen abgesichert werden kann, ohne normale Weiterentwicklung und Updates zu blockieren.

Ziel ist ein pruefbarer Support-Pfad:

1. Das Setup prueft seine Herkunft und Dateiintegritaet.
2. Ein signierter Originalzustand wird mit einem oeffentlichen Schluessel verifiziert.
3. Bei Abweichungen wird ein Diagnosebericht erzeugt.
4. Der Bericht kann per E-Mail an den automatisierten Support gesendet werden.
5. Spaeter kann dieser Support lokal durch Ollama + OpenClaw + Codex-nahe Agenten ausgewertet werden.

Wichtig: Dieser Mechanismus ist kein Kopierschutz im klassischen Sinn. Er ist ein Sicherheits- und Support-Gate. Er soll erkennen, ob ein Setup noch dem Original entspricht oder ob es sich um Fork, lokale Manipulation oder unbekannte Quelle handelt.

## Warum nicht MD5?

MD5 ist fuer Integritaets- und Sicherheitspruefungen nicht mehr geeignet. Besser:

- `SHA256` fuer Datei-Hashes
- `GPG`, `minisign` oder `cosign` fuer Signaturen
- `git` fuer Commit-, Remote- und Diff-Pruefung

Empfohlen fuer dieses Setup:

- Kurzfristig: `git remote`, `git status`, `git diff`, `SHA256-Manifest`
- Danach: signiertes Manifest mit GPG oder minisign
- Spaeter: automatische Support-Auswertung ueber lokalen OpenClaw-Agenten

## Zielarchitektur

```text
Lokales Setup
    |
    |-- git remote / commit / diff pruefen
    |-- SHA256-Manifest pruefen
    |-- Manifest-Signatur mit Public Key pruefen
    |
    v
Integritaetsbericht
    |
    |-- Status: original / fork / manipuliert / unbekannt
    |-- Abweichende Dateien
    |-- Git-Remote / Branch / Commit
    |-- Systeminfos ohne Secrets
    |
    v
E-Mail an Support-Adresse
    |
    v
Automatisierter Support
    |
    |-- Eingang ueber Mail / IMAP / Webhook
    |-- OpenClaw Agent analysiert Bericht
    |-- Ollama fasst Ursache und Handlungsempfehlung zusammen
    |-- Codex-nahe Reparaturvorschlaege nur fuer Originalsetup
```

## Grundregel fuer Support

Automatisierte Selbstheilung via Update wird nur angeboten, wenn:

- `origin` auf das Original-Repository zeigt
- der aktuelle Commit zum erwarteten Originalverlauf passt
- keine unautorisierten lokalen Aenderungen erkannt werden
- die Manifest-Signatur gueltig ist

Bei Forks oder unbekannten Quellen gilt:

```text
Supportstatus: eingeschraenkt
Selbstheilung: deaktiviert
Empfehlung: Fork manuell pruefen oder mit Original abgleichen
```

## Schritt 1: Repo-Herkunft pruefen

Bereits vorgesehen ist eine Herkunftspruefung ueber:

```bash
git remote get-url origin
git remote get-url upstream
git rev-parse --short HEAD
git rev-parse --abbrev-ref HEAD
```

Das Ergebnis landet in Diagnoseberichten im Abschnitt:

```text
Setup-Repo-Herkunft
```

Moegliche Statuswerte:

| Status | Bedeutung |
|---|---|
| `original` | `origin` zeigt auf das erwartete Original-Repository. |
| `fork_with_original_upstream` | Setup stammt wahrscheinlich aus einem Fork, kennt aber das Original als `upstream`. |
| `fork_or_unknown_source` | Quelle ist Fork, unbekannt oder nicht eindeutig pruefbar. |

## Schritt 2: SHA256-Manifest erzeugen

Ein Manifest ist eine Liste von Dateien plus Hashwerten.

Beispiel:

```bash
mkdir -p security
find . \
  -path './.git' -prune -o \
  -path './node_modules' -prune -o \
  -path './logs' -prune -o \
  -type f \
  -not -name '*.zip' \
  -print0 \
  | sort -z \
  | xargs -0 sha256sum > security/file_manifest.sha256
```

Dieses Manifest sollte nur Dateien enthalten, die zum Original-Setup gehoeren. Ausgeschlossen werden sollten:

- `.git/`
- `node_modules/`
- lokale Logs
- lokale `.env`
- `~/.openclaw_ultimate_user_data`
- grosse Archive oder Build-Artefakte

## Schritt 3: Manifest pruefen

Pruefung:

```bash
sha256sum -c security/file_manifest.sha256
```

Wenn Dateien veraendert wurden, erscheint eine Meldung wie:

```text
setup_ultimate.sh: FAILED
scripts/tools/example_install.sh: OK
```

Diese Liste ist spaeter fuer den Support sehr wertvoll.

## Schritt 4: Manifest signieren

Damit ein Fork nicht einfach ein neues Manifest erzeugen und behaupten kann, es sei original, wird das Manifest signiert.

### Variante A: GPG

Einmalig Schluessel erzeugen:

```bash
gpg --full-generate-key
```

Public Key exportieren:

```bash
gpg --armor --export DEINE_KEY_ID > security/public_support_key.asc
```

Manifest signieren:

```bash
gpg --armor --detach-sign security/file_manifest.sha256
```

Das erzeugt:

```text
security/file_manifest.sha256.asc
```

Pruefung mit oeffentlichem Schluessel:

```bash
gpg --import security/public_support_key.asc
gpg --verify security/file_manifest.sha256.asc security/file_manifest.sha256
sha256sum -c security/file_manifest.sha256
```

### Variante B: minisign

`minisign` ist schlanker als GPG.

Signieren:

```bash
minisign -S -m security/file_manifest.sha256
```

Pruefen:

```bash
minisign -Vm security/file_manifest.sha256 -P "PUBLIC_KEY_HIER"
sha256sum -c security/file_manifest.sha256
```

## Schritt 5: Update-freundlicher Ablauf

Bei jeder offiziellen Aenderung gilt:

1. Dateien aendern
2. Tests ausfuehren
3. Manifest neu erzeugen
4. Manifest signieren
5. Manifest und Signatur committen
6. Update veroeffentlichen

Dadurch duerfen sich Hashwerte aendern, aber nur kontrolliert und signiert.

## Schritt 6: Diagnosebericht fuer E-Mail

Ein Supportbericht sollte enthalten:

- Produkt-ID
- Report-ID
- Datum
- Repo-Herkunft
- `origin`
- `upstream`
- Branch
- Commit
- Manifest-Signaturstatus
- Hash-Pruefergebnis
- Liste abweichender Dateien
- letzte Installationslogs
- keine Secrets

Beispielstruktur:

```markdown
# Setup Integrity Report

- Status: fork_or_unknown_source
- Selbstheilung: deaktiviert
- Grund: origin zeigt nicht auf Original
- Commit: abc1234
- Manifest-Signatur: ungueltig oder fehlt

## Abweichende Dateien

- setup_ultimate.sh
- scripts/tools/example_install.sh

## Empfehlung

Bitte Fork manuell pruefen oder Originalsetup neu synchronisieren.
```

## Schritt 7: Versand an automatisierten Support

Der Bericht kann ueber die bestehende Mail-Konfiguration versendet werden.

Prinzip:

```bash
bash scripts/install_run_diagnostics.sh --email
```

Oder spaeter:

```bash
bash scripts/security/verify_setup_integrity.sh --email
```

Die Support-Adresse muss eindeutig sein, weil sie auch von anderen Produkten genutzt wird. Deshalb sollten Betreff und Report-ID eindeutig sein:

```text
[OpenClaw Ultimate Setup][Integrity][Report:...] Integritaetspruefung
```

## Schritt 8: Automatisierter Support mit Ollama + OpenClaw

Der lokale Support-Agent kann spaeter so arbeiten:

```text
E-Mail Eingang
    |
    v
Mail Parser
    |
    v
OpenClaw Support Agent
    |
    |-- erkennt Produkt-ID
    |-- erkennt Report-ID
    |-- prueft Repo-Herkunft
    |-- bewertet Hash-Abweichungen
    |-- trennt Originalfehler von Fork-/Manipulationsfehlern
    |
    v
Ollama Analyse
    |
    |-- Zusammenfassung
    |-- Risiko
    |-- empfohlene naechste Schritte
    |
    v
Antwortentwurf / Ticket / lokale Aktion
```

## OpenClaw Agentenrolle

```markdown
# Agent: Setup Integrity Support

Du analysierst Diagnoseberichte des Ultimate KI Setups.

Regeln:
- Keine Selbstheilung empfehlen, wenn Repo-Herkunft nicht `original` ist.
- Bei Forks nur Analyse, Warnung und manuelle Abgleichschritte vorschlagen.
- Keine Secrets ausgeben.
- Keine destruktiven Reparaturbefehle automatisch ausfuehren.
- Bei gueltigem Originalsetup darfst du sichere Update-/Repair-Schritte vorschlagen.
- Bei ungueltiger Manifest-Signatur Supportstatus auf `eingeschraenkt` setzen.

Ausgabe:
1. Kurzfazit
2. Herkunftsstatus
3. Integritaetsstatus
4. Risiko
5. Empfohlene Schritte
6. Darf Selbstheilung angeboten werden: ja/nein
```

## Beispielauswertung

### Fall 1: Original, keine Aenderung

```text
Status: original
Manifest: gueltig
Dateien: OK
Selbstheilung: erlaubt
```

### Fall 2: Original, lokale Aenderung

```text
Status: original
Manifest: gueltig
Dateien: abweichend
Selbstheilung: eingeschraenkt
Empfehlung: lokale Aenderungen anzeigen, Nutzer bestaetigen lassen
```

### Fall 3: Fork

```text
Status: fork_with_original_upstream
Manifest: fehlt oder ungueltig
Selbstheilung: deaktiviert
Empfehlung: Fork manuell pruefen
```

### Fall 4: unbekannte Quelle

```text
Status: fork_or_unknown_source
Manifest: ungueltig
Selbstheilung: deaktiviert
Empfehlung: nicht automatisch reparieren
```

## Empfohlene naechste Dateien

Sinnvolle naechste Umsetzung:

```text
scripts/security/generate_manifest.sh
scripts/security/verify_setup_integrity.sh
scripts/security/send_integrity_report.sh
security/file_manifest.sha256
security/file_manifest.sha256.asc
security/public_support_key.asc
docs/SETUP_INTEGRITY_AND_SUPPORT_TUTORIAL.md
```

## Sicherheitsgrenzen

- Ein Hash schuetzt nicht vor Veraenderung, er erkennt sie nur.
- Eine Signatur schuetzt nur, wenn der private Schluessel geheim bleibt.
- Forks koennen eigene Hashes erzeugen, aber nicht die Originalsignatur.
- Automatisierte Reparatur darf niemals unbekannte Quellen blind ueberschreiben.
- Diagnoseberichte muessen Secrets redaktieren.

## Kurzfazit

Die Kombination aus Git-Herkunft, SHA256-Manifest, Signatur und Support-Mail ist fuer dieses Setup realistisch und updatefreundlich. Sie blockiert Weiterentwicklung nicht, macht aber klar unterscheidbar:

- Originalsetup mit gueltiger Integritaet
- Originalsetup mit lokalen Aenderungen
- Fork mit eingeschraenktem Support
- unbekannte oder manipulierte Quelle ohne Selbstheilung
