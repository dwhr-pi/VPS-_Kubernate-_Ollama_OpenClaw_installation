# OpenMontage: agentische Videoproduktion aus GitHub

Stand: **22.10.2026**. Neuer experimenteller Tools-Eintrag **OpenMontage**,
kein Docker und keine automatische Videoerstellung.

## Wozu es in deinem Setup dient

OpenMontage verbindet Produktionsanleitungen, Python-Werkzeuge und
Pipeline-Definitionen fuer Recherche, Konzept, Skript, Szenen, Assets,
Schnitt und Komposition. Ein Coding-Agent bedient diese Bausteine.
Es ist kein neues Videomodell und kein eigener Claude-API-Zwang.
[Offizielles Repository](https://github.com/calesthio/OpenMontage).

Fuer dein Setup passt es als **getrenntes Medienprojekt**: Qwen Code Desktop
oder ein anderer Coding-Agent fuer Planung, vorhandenes ComfyUI/Wan/LTX
fuer bewusst eingerichtete Generierung und FFmpeg/optionaler Composer fuer
Montage. Das ist ein Integrationsvorschlag, keine getestete Gesamtpipeline.
Jarvis-Core und OpenClaw werden nicht veraendert oder automatisch verbunden.

Nutzerquelle: [Instagram-Reel](https://www.instagram.com/reel/DeNQ7r7NZ7K/).
Der eingefuegte Text nennt Alan Langhammer/@alan.buildz und Oktober 2026;
der Reel-Abruf war gedrosselt. Inhalt, Datierung und Werbeversprechen nicht
als unabhaengig verifiziert ausgeben. "Automatisch alle 5 Minuten aktualisiert"
im Ausgangstext bedeutet hier **keine** eingerichtete Update-Automation.

## Was wirklich hinzugefuegt wurde

| Baustein | Integration / Abgrenzung |
|---|---|
| OpenMontage | GitHub-Checkout auf festem Commit, private Python-venv, Kernabhaengigkeiten, Import-/Paketpruefung, eigener Installationsmarker |
| Remotion-Composer | Optional aus dem gepinnten OpenMontage-Unterprojekt, npm ci mit Lockfile und ohne Lifecycle-Skripte; separate Lizenzfreigabe |
| HyperFrames | Upstream-Integrationspfad dokumentiert, hier **nicht automatisch installiert**; kein npx-latest-Aufruf |
| FFmpeg/ffprobe, Piper | Bereits vorhandene Setup-Bausteine; nicht erneut global installiert, Stimme/Modell und Runtime separat pruefen |
| Coding-Agent | Vorhandenen Client bewusst waehlen; keine automatische Anmeldung, Skill-Aktivierung oder Agentenstart |
| Cloudanbieter | Keine Accounts/Keys/Probeaufrufe oder Bilder-/Videouploads durch den Installer |

GitHub-Pin: `c8066452325cb57c8fc1ba8c2a71b6e8842e6b65`.
[Quellstand](https://github.com/calesthio/OpenMontage/tree/c8066452325cb57c8fc1ba8c2a71b6e8842e6b65).
Die GitHub-Quelle ist fest; Python-Abhaengigkeiten kommen als Wheels von
PyPI gemaess den Upstream-Mindestversionen. Das ist **kein vollstaendig
gehashter Python-Lock**. Aufgeloeste Versionen werden im Marker protokolliert.
Fehlt ein passendes Wheel, scheitert die Installation statt unbemerkt einen
nativen Build zu beginnen. npm ist nur fuer den optionalen Composer noetig.

## Warum nicht einfach make setup?

Der gepruefte [Upstream-Makefile](https://github.com/calesthio/OpenMontage/blob/c8066452325cb57c8fc1ba8c2a71b6e8842e6b65/Makefile)
installiert mehrere Komponenten, verwendet npm/npx und kann fehlgeschlagenes
Piper-/HyperFrames-Setup ueberspringen. Es ist kein schreibfreier Check und
kein Beleg fuer einen vollstaendig funktionierenden Offline-Renderer.
Unser Installer ruft es nicht auf. Keine Browser-, Voice-, Torch-/CUDA-,
GPU-/Treiber- oder Modelldownloads; kein globaler PATH-/System-Python-Umbau.

## Installation im Ubuntu-/WSL-Setup

**Tools -> OpenMontage** oder direkt vom Setup-Hauptverzeichnis:

```bash
bash scripts/tools/openmontage_install.sh --dry-run
bash scripts/tools/openmontage_install.sh
bash scripts/tools/openmontage_status.sh
bash scripts/tools/openmontage_doctor.sh
```

Voraussetzungen fuer die Basis: vorhandenes Git und Python >=3.10 mit
venv/ensurepip/SSL. Ein anderes vorhandenes Python ueber
`OPENMONTAGE_PYTHON_BIN=/absoluter/pfad/python3` bestimmen. Zum Ausfuehren
des Installers selbst gegebenenfalls `OPENMONTAGE_INSTALLER_PYTHON_BIN`
setzen. Fehlende Systempakete werden nicht ungefragt nachinstalliert.

Ziel: `~/.openclaw_ultimate_user_data/tools/openmontage/` beziehungsweise
das externe `OPENCLAW_USER_DATA_DIR`:

```text
source/          gepinnter GitHub-Stand, Anleitungen und Pipelines
venv/            private Python-Kernumgebung
remotion/        nur nach optionaler Composer-Installation
core-ready.json  Pin, aufgeloeste Pakete und Bereitschaftsangaben
```

Mindestreserve: 4 GiB freier Zielspeicher, unter WSL zusaetzlich 4 GiB auf
C:. Liegt die VHDX auf einem anderen Laufwerk, dort separat pruefen.
Das ist nur die Installationsreserve, **kein** Budget fuer Modelle, Assets
oder fertige Filme. Basis-RAM-Preflight und eigene aktuelle Operationslogs
bleiben aktiv. Abbrueche entfernen nur neu angelegte Komponenten dieses
Versuchs, nicht vorher vorhandene Quellen oder Daten.

**Installationserfolg bedeutet Kernumgebung**, nicht fertiges Filmstudio:
`core_dependencies_ready=true`, `render_ready=false`, kein laufender Dienst.
Status prueft Marker und Grundstruktur; Doctor prueft zusaetzlich den Git-
Stand und die Python-Imports. Fehlende/veraenderte Quellen werden nicht
zurueckgesetzt. Ein reiner Clone gilt nicht als installierte Kernumgebung.

Der Python-Einstieg ist auch direkt aufrufbar, etwa unter Windows mit einem
vorhandenen nativen Python:

```text
python -B scripts/tools/helpers/openmontage.py plan
python -B scripts/tools/helpers/openmontage.py install
```

Die Schaltflaeche **Ubuntu / Windows** im Tools-Menue betrifft weiterhin nur
Marp, listmonk und Mautic; sie installiert nicht automatisch OpenMontage.
Native Windows-Filmproduktion und der optionale npm-Pfad sind hier nicht
end-to-end getestet. Nicht unbemerkt zwischen Windows- und WSL-Python wechseln.

## Remotion optional und bewusst installieren

Remotion hat eine **eigene Lizenz**, nicht pauschal die AGPL des Hauptprojekts.
Kostenfreie Nutzung und eine erforderliche Firmenlizenz haengen vom konkreten
Einsatz ab. Vor Verwendung die Bedingungen der tatsaechlich installierten
Version pruefen: [offizielle Remotion-Lizenz](https://github.com/remotion-dev/remotion/blob/main/LICENSE.md).

Nach dieser Pruefung und mit vorhandenem Node >=22/npm:

```bash
bash scripts/tools/openmontage_install.sh --with-remotion --accept-remotion-license
```

Der Schalter ist deine ausdrueckliche Lizenzpruefungsbestaetigung, keine
Rechtspruefung durch das Setup. Er kann auch nach einer Basisinstallation
verwendet werden. Der Composer wird aus dem GitHub-Unterordner in einen
getrennten Ordner kopiert. `npm ci --ignore-scripts` verwendet dessen Lock;
Remotion ist darin am geprueften Stand 4.0.484. Kein globales npm install,
kein automatisches Renderer-Upgrade, Browserdownload oder Filmtest.
`remotion_ready` bezeichnet bereitgestellte Pakete, **keine** vollstaendige
Browser-/Codec-/Renderabnahme.

HyperFrames ([heygen-com/hyperframes](https://github.com/heygen-com/hyperframes))
ist ein weiterer Upstream-Renderer, nicht Voraussetzung fuer
die Kerninstallation. Den im Makefile vorgesehenen Cache-Warmup/latest-
Download fuehrt unser Setup nicht aus. Fuer einen spaeteren separaten
Installer fehlen hier noch gepruefter Versionspin, Abhaengigkeits- und
Render-Smoke-Test. Kein vorgetaeuschter HyperFrames-Menueeintrag.

## Qwen Code Desktop statt Claude Code

Upstream nennt mehrere Coding-Clients; die uebergreifende Logik steht in
AGENT_GUIDE.md und weiteren Dateien. Trotzdem liest nicht jeder Client
CLAUDE.md automatisch und ein Modellendpunkt allein fuehrt keine Tools aus.
Qwen braucht passende Projekt-, Terminal- und Dateifunktionen sowie Freigaben.

Die [eigene QWEN.md-Vorlage](../../examples/openmontage/QWEN.md) als
**Vorschlag** pruefen und erst dann in das gewaehlte OpenMontage-Projekt
uebernehmen. Vorhandene QWEN.md nicht ueberschreiben. Der Installer aktiviert
diese Vorlage weder global noch im Quellcheckout. Eine hinzugefuegte Datei
zaehlt beim strikten Quellcheck als lokale Aenderung; solche Anpassungen
vor Update bewusst sichern und getrennt pflegen.

Fuer Agentenbefehle die private venv verwenden, etwa durch bewusste Aktivierung
vor dem Oeffnen des Projektclients. Ein Windows-Desktop kann einen WSL-Pfad
nicht automatisch mit seinem nativen Python ausfuehren. Laufzeit und Projekt-
pfade explizit festlegen. Qwen-End-to-end-Kompatibilitaet wurde hier nicht
getestet; keine Notwendigkeit fuer ein bestimmtes 72B-Modell behaupten.
Auf deinem RTX-5080-Host mit 16 GB VRAM zuerst kurze Aufgaben und kleine
Vorschauen; LLM-/Video-/TTS-Jobs nicht unkontrolliert parallel laden.

## Sicherer erster Produktionsauftrag

```text
Lies AGENT_GUIDE.md und die passenden Pipeline-Dateien im Projekt.
Erstelle vorerst nur Konzept, Skript und Szenenplan fuer einen kurzen
deutschen Erklaerclip aus meinen freigegebenen vorhandenen Medien.
Zeige erwartete Werkzeuge, Datenfluesse, offene Rechte und Kosten.
Keine Cloudanfrage, Recherche, Downloads, Generierung, Browser-/Backlot-
Starts oder Rendering ohne gesonderte Freigabe. Kein automatischer Fallback.
Stoppe vor der Assetphase und zeige mir die Entwuerfe.
```

Freigaben fuer Assets und finalen Render sind verschiedene Entscheidungen:
Eine Storyboard-Vorschau kann bereits kostenpflichtig erzeugte Assets enthalten.
Upstream steht `budget.mode` standardmaessig auf **warn**, nicht auf cap;
10 USD im YAML sind damit nicht pauschal ein hartes Ausgabenlimit.
[Gepinnte Konfiguration](https://github.com/calesthio/OpenMontage/blob/c8066452325cb57c8fc1ba8c2a71b6e8842e6b65/config.yaml).
Prompt-Regeln ersetzen weder Netzwerk-/Dateirechte noch Budgetkontrollen.

Piper lokal macht nicht automatisch den Coding-Agenten, Webrecherche,
Stockmaterial oder andere Provider offline/kostenlos. Keys gehoeren in eine
private Konfiguration, nicht in Chat, Git oder die QWEN.md.
[API-Key-Uebersicht](../_API-Keys/README.md).
Keine automatisch kopierte .env, keine Uebernahme aller vorhandenen Masterkeys.

## Wan/LTX und vorhandene Workflows

OpenMontage plant/bedient Produktionsbausteine; Wan/LTX erzeugen Clips und
ComfyUI fuehrt einen passenden Graph aus. Die Anbindung braucht die richtigen
Modellgewichte, API-Workflows, Node-Versionen und Pfade. Ein HTTP-kompatibler
Endpunkt allein belegt keine Medienkompatibilitaet.
[Editierbare Videorezepte](../media_studio/EDITABLE_VIDEO_WORKFLOWS.md) und
[bestehende Avatar-/Providerplanung](../media_studio/SOCIAL_AVATAR_AUTOMATION.md)
beruecksichtigen. Keine automatische ComfyUI-/Wan-/LTX-Installation als
Nebenwirkung dieses Installers.

## Update und Deinstallation

```bash
bash scripts/tools/openmontage_update.sh
bash scripts/tools/openmontage_uninstall.sh
```

Update/Repair pruefen denselben Pin und die vorhandene Umgebung, kein main-
Pull und kein ungefragtes Paketupgrade. Lokale Quellaenderungen werden nicht
verworfen. Eine unverwaltete venv wird nicht automatisch ersetzt.

Deinstallation entfernt nur die nach Marker zugehoerige private venv und
gegebenenfalls verwaltete Remotion-node_modules; der Marker wird entfernt.
Quellen, Remotion-Projektdateien, Filme, Secrets, Logs, Python/Node/FFmpeg und
andere Basiswerkzeuge bleiben. Im Tools-Menue wird der Status danach entfernt;
fehlende venv wird nicht allein wegen eines alten Markers als bereit gewertet.

## Pruefumfang

Offline-Tests fuer Dry-Run, Quell-/Statuspruefung, Fehler-Rollback, Lizenz-
Gate, Menue/Registry und Deinstallationsgrenzen. Kein kompletter Download-/
pip-/npm-Build oder Filmtest auf deinem Zielrechner. Browser, Piper-Stimme,
Codecs, Qwen-Toolaufrufe und GPU-/Cloudpfade brauchen gesonderte Abnahme.
Keine Erfolgs-, Einkommens-, Qualitaets- oder Vollautomatisierungszusage.
