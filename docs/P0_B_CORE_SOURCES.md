# P0-B: Quellen vor Ausfuehrung pruefen

Stand: 01.11.2026. Erster Schutz-Teilsatz, **kein neuer fertiger Installer**.
Die regulaeren Ollama-/K3s-Tool-Einstiege fuehren keine veraenderlichen
Internet-Skripte mehr aus. Vorhandene Programme, Modelle, Cluster, Dienste,
Konfigurationen und Installationsstatus bleiben unveraendert.

## Befund und Breaking Change

Die bisherigen Dateien `scripts/tools/ollama_install.sh` und
`scripts/tools/k3s_install.sh` fuehrten folgende veraenderliche Quellen direkt aus:

```text
Historisch, NICHT ausfuehren:
curl -fsSL https://ollama.com/install.sh | sh
curl -sfL https://get.k3s.io | sh -
```

Dabei fehlten unveraenderlicher Quell-Pin, vorgelagerte Integritaetspruefung und
eine technische Trennung vom moeglichen Dienst-/Clusterstart. Ein lokal
vorhandenes `ollama` wurde zudem ohne verwalteten Herkunftsnachweis als Erfolg
akzeptiert. Diese automatischen Pfade sind jetzt bewusst gesperrt.

**Auswirkung:** Die zwei Menuepunkte zeigen einen Quellenplan, installieren aber
noch nichts. Das ist eine beabsichtigte Sicherheitsbarriere, keine fehlgeschlagene
fertige Native-Integration. Es gibt keinen `--force`, unsignierten Ersatzdownload,
automatischen Paketmanager-Fallback oder versteckten Service-Start.

## Rein lesender Plan

Die weiteren Legacy-Einstiege `scripts/base_install.sh` und
`scripts/vps_standalone.sh` delegieren jetzt ebenfalls sofort an den jeweiligen
Quellen-Guard, bevor Paketinstallation, OpenClaw-Build, Workspace-Initialisierung
oder Cluster-Abfragen beginnen. Ihr restlicher Legacy-Code samt Funktionsdefinitionen
bleibt vorerst als **nicht erreichbare Migrationsreferenz** fuer bestehende
isolierte Funktionstests erhalten, nicht als freigegebener Installationspfad.
Die zusaetzlichen Ollama-/K3s-Vendor-Pipes wurden auch aus diesen Altteilen entfernt.
Breaking Change: Basis-/VPS-Legacy-Assistenten fuehren keine automatische Einrichtung
mehr durch. Diese Abschaltung ist notwendig, damit die zwei Tool-Sperren nicht
durch einen zweiten Einstieg umgangen werden.

```bash
bash scripts/tools/ollama_install.sh --plan
bash scripts/tools/k3s_install.sh --plan
```

Auch ein Aufruf ohne Optionen plant nur. Code 3 bedeutet **nicht installiert**.
Der interaktive Tool-Dispatcher faengt diese beiden Planpfade vor generischer
Logbereinigung, Speicherpruefung, Installationssperre, Messung und
Status-/Autostart-Verarbeitung ab. Selbst ein unerwarteter Guard-Code 0 kann
dort keinen Installationsmarker erzeugen. Sein UI-Rueckgabewert ist kein
Installationsnachweis. Direkte Aufrufe aus Profilskripten erhalten Code 3;
Profile koennen deshalb abbrechen statt einen Scheinerfolg zu vermerken.

Die Wrapper benutzen ihren eigenen Repositorypfad, nicht ein geerbtes
`INSTALL_DIR`, und laden keine Status-/Workspace-Helfer. Fehlt der Pruefhelfer,
wird geschlossen abgebrochen.

## Bereits vorhandene Quellenbytes pruefen

Eine bewusst bereitgestellte kleine JSON-Datei muss genau diese Felder haben:

| Feld | Vertrag |
| --- | --- |
| `schema` | Ganzzahl 1 |
| `tool` | `ollama` oder `k3s`, passend zum aufgerufenen Wrapper |
| `source_commit` | Voller, nicht nullgesetzter 40-stelliger Hex-Commit |
| `url` | Exakte GitHub-Archivadresse fuer offiziellen Owner/Repo und diesen Commit |
| `sha256` | Separat gepruefte 64-stellige Hex-Pruefsumme, nicht nur Nullen |
| `size` | Exakte Bytezahl, mindestens 1, maximal 1 GiB |

Erlaubte Formen sind `https://github.com/ollama/ollama/archive/COMMIT.tar.gz`
und `https://github.com/k3s-io/k3s/archive/COMMIT.tar.gz`. `COMMIT` muss im echten
Vertrag durch den tatsaechlich geprueften vollen Commit ersetzt sein. Es wird
hier kein Release, Hash oder baubarer Quellstand erfunden oder freigegeben.

```bash
bash scripts/tools/ollama_install.sh --verify-source \
  --manifest /srv/reviewed/ollama-source.json \
  --artifact /srv/reviewed/ollama-source.tar.gz
```

Beide Dateien muessen bereits existieren und absolute, unverlinkte Pfade sein.
Keine Links/Junctions in Elternpfaden, keine Hardlinks oder Geraetedateien.
Die JSON-Datei ist auf 64 KiB begrenzt; doppelte/zusatzliche Felder, Branches,
fremde Quellen, falsche Groessen und Hashes werden abgewiesen. Die Quelle wird
blockweise gelesen und auf Austausch/Aenderung waehrend des Lesens geprueft.
Fehlende Dateien fuehren zu Code 1, nicht zu einem Netzwerk-Fallback.

Auch bei richtiger Pruefsumme lautet der Wrapper-Code 3. Der Bericht trennt
`verified: true` von `installed: false`, `authenticity_verified: false` und
`archive_contents_verified: false`. **Das Archiv wird nicht entpackt oder
ausgefuehrt.** Eine erfolgreiche Bytepruefung beweist weder offiziellen Ursprung
noch sicheren/baubaren Archivinhalt, Runtime-Bereitschaft oder eine Signatur.

Ein vom selben kompromittierbaren Kanal bezogener Hash ist kein unabhaengiger
Vertrauensanker. Der Manifestvertrag muss separat reviewt/authentisiert werden;
die [Minisign-Releasepruefung](SIGNED_RELEASES.md) des Setups ersetzt keine
Upstream-Artefaktpruefung. Vor einem spaeteren Build muessen die tatsaechlich
verwendeten Bytes erneut geprueft und in einen kontrollierten Build-Snapshot
uebernommen werden. Es wird kein dauerhafter Vertrauensmarker erzeugt.

## Bestehende Alternativpfade und ihre Grenzen

- [Native Core-Playbooks](SECURE_CORE_REFACTOR.md) verlangen volle Quell-Pins und
  explizite Toolchains. Sie sind ein separat zu pruefender Migrationspfad,
  kein aus diesem Menue automatisch gestarteter Installer. Quell-Pins allein
  sind keine vollstaendige Supply-Chain-Abnahme aller Buildabhaengigkeiten.
- [GitOps-Bootstrap](GITOPS_SMALL_VPS.md) besitzt einen getrennten Artefaktvertrag
  und eigenstaendige Apply-Freigaben. Dieser Schutzpatch startet ihn nicht.
- [P0-A-Uninstall-Schutz](P0_A_CORE_UNINSTALL.md) fuer Ollama/OpenClaw bleibt
  bestehen. K3s-Uninstall und weitere Legacy-Skripte werden nicht pauschal mitgehaertet.

## Abnahme und Rollback

`tests/test_core_source_gate.py` prueft synthetische Quellenbytes, Manipulationen,
fehlende Dateien im Offline-Fall, Schema-/Pin-/URL-Fehler, Hardlinks, sensible
Fehlerausgaben sowie die echten Shell-Wrapper gegen einen Python-Spy. Die echte
Basis-/VPS-Delegation wird ebenfalls gegen denselben Spy geprueft. Die echte
Menuefunktion wird mit Stubs gegen vorzeitige Installations-Nebenwirkungen geprueft.
Die Ubuntu-24.04-P0-CI fuehrt die neue Suite und Shell-Syntaxpruefungen aus.
Hier wurden keine echten Quellen heruntergeladen, gebaut oder ausgefuehrt.

Lokale Nachweise vom 01.11.2026 (ueberlappende Auswahlen, nicht addieren):

- Neue Quellen-/Wrapper-/Menue-Suite: 16 Tests; der echte Symlink-Test ist unter
  Windows mangels Berechtigung uebersprungen, die uebrigen Tests bestehen.
- Breite Auswahl einschliesslich P0-Safety, Legacy-Uninstall, Shell-Tools,
  Registry, Navigation, Medienstatus und ComfyUI: 108 Tests, 105 bestanden,
  drei Symlink-Skips unter Windows.
- Zusaetzliche Quellen-/Shell-Manager-/Shell-Fehler-Auswahl nach Schliessen der
  Basis-/VPS-Zugaenge: 32 Tests, 31 bestanden, ein Symlink-Skip unter Windows.
- Vollstaendiger statischer Repositorycheck: 0 Fehler, 802 bestehende
  Metadatenhinweise. Shell-Syntax, ShellCheck und shfmt fuer die fuenf
  geaenderten Shell-Dateien ohne Befund. Geaenderte Markdown-Dokumente lintfrei.
- Kein vollstaendiger neuer Windows-Discovery-Lauf, keine Online-CI-/Linux-Host-
  oder Build-/Runtime-Abnahme. Die CI-Erweiterung ist kein lokal mit Actionlint
  oder einer YAML-Laufzeit validierter Workflow.

Rollback nur als reviewter Code-Revert; keine Nutzdaten oder Marker loeschen.
Ein Revert auf die zwei alten Direktinstaller reaktiviert das dokumentierte
Supply-Chain-Risiko und ist deshalb kein empfohlener Betriebs-Workaround.

## Naechster Teilsatz

1. OpenClaw-Legacy-Installer: bewegliche Clone-/Pull-Ziele und ungefrorene
   Paketinstallation beseitigen; bestehendes `/opt/openclaw` niemals implizit
   adoptieren oder veraendern. `scripts/tools/openclaw_install.sh` ist weiterhin offen.
2. Reviewte Quell-/Toolchain-Vertraege mit authentisierter Herkunft,
   sicherer Extraktion und frischem isolierten Build verbinden; erst nach echter
   Build-/Smoke-Abnahme einen getrennten Runtime-Nachweis erzeugen.
3. Dienstregistrierung/-start und Statusmigration separat freigeben; danach
   Fresh-Host-Abnahme auf Ubuntu 24.04 amd64 und ARM. P0-B insgesamt bleibt offen.
