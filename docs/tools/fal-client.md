# Fal-Client aus GitHub ohne Docker

Stand: 16.10.2026. Wir installieren das Python-Paket **fal-client 1.0.3**
aus [fal-ai/fal](https://github.com/fal-ai/fal), Unterordner
`projects/fal_client`, Pin `80ddb1d8f2f4b0a28a0323fd3c1d96e34c849eb5`
([Tag fal_client_v1.0.3](https://github.com/fal-ai/fal/tree/fal_client_v1.0.3)).

**Das ist ein lokaler API-Client, nicht die lokale fal.ai-Plattform.**
Keine Docker-Installation, kein Modellserver und kein selbstgehostetes Veo.
Die spaetere Nutzung von fal.ai kann kostenpflichtig sein und Daten hochladen.
Ein installiertes SDK bedeutet weder ein kostenloses Konto noch API-Zugang.

## 1. Installation im Setup

Unter Tools **Fal_Client** auswaehlen oder im Setup-Verzeichnis:

```bash
bash scripts/tools/fal_client_install.sh --dry-run
bash scripts/tools/fal_client_install.sh
bash scripts/tools/fal_client_status.sh
bash scripts/tools/fal_client_doctor.sh
```

Der Installer:

1. Prueft Linux x86_64/ARM64, Python 3.10-3.13, RAM und Disk.
   Das ist die bewusst begrenzte Setup-Unterstuetzung; Upstream am Pin nennt Python >=3.8.
2. Laedt den festen GitHub-Commit ohne interaktive GitHub-Anmeldung.
3. Erstellt eine private venv und installiert **nur den Client-Unterordner**.
   Der Monorepo-Root und das andere Paket `fal` werden nicht installiert.
4. Laedt Build-/Runtime-Abhaengigkeiten von PyPI, bevorzugt ausschliesslich
   vorhandene Wheels; keine automatischen nativen Abhaengigkeits-Builds.
5. Prueft Paketversion, lokalen Installationsursprung und `pip check`.
   Er importiert dabei nicht `fal_client` und fuehrt keine SDK-Funktion aus.

Ziele:

```text
~/.openclaw_ultimate_user_data/tools/fal_client/source/
~/.openclaw_ultimate_user_data/tools/fal_client/venv/
~/.openclaw_ultimate_user_data/tools/fal_client/source-built
~/.openclaw_ultimate_user_data/install_logs/fal_client_*.log
```

Fuer einen anderen bestehenden Interpreter:

```bash
FAL_CLIENT_PYTHON_BIN=python3.11 bash scripts/tools/fal_client_install.sh
```

Ubuntu-Python 3.12 passt zum gewaehlten Setup-Pfad. Bei fehlendem venv/ensurepip
das zum ausgewaehlten Python passende Ubuntu-venv-Paket separat einrichten.
Kein System-Python wird ersetzt, kein sudo/apt automatisch ausgefuehrt.
Fremde oder beschaedigte venv-Verzeichnisse erst sichern und separat pruefen.

## 2. Ressourcen und Wiederholbarkeit

Reserve: 1 GiB RAM gesamt, mindestens 512 MiB aktuell verfuegbar und 2 GiB
freie Linux-Disk sowie messbare Windows-C:-Reserve unter WSL.
Freie WSL-Disk allein garantiert nicht, dass die Windows-SSD Platz hat.
Keine GPU/VRAM und keine lokalen Modellgewichte erforderlich.
MiniPC/RPi5/Oracle-ARM/Linux-x86 sind nur geeignet, wenn passende Wheels
verfuegbar sind. Windows/macOS nativ sind durch diesen Bash-Installer nicht getestet.
Kubernetes wird nicht eingerichtet; GPU-Workstation/Dual-Xeon bieten dem Client
allein keinen besonderen Inferenzvorteil.

Ein Lock verhindert parallele Installer. Disk wird vor/nach Paketinstallation
gemessen. Ein konsistentes installiertes Paket wird bei install wiederverwendet.
Update behaelt denselben Pin, kein stilles latest.

Der GitHub-Tag verwendet setuptools-scm fuer die Version. Beim flachen
Commit-Checkout wird genau fuer diesen geprueften Pin
`SETUPTOOLS_SCM_PRETEND_VERSION_FOR_FAL_CLIENT=1.0.3` gesetzt, damit nicht
versehentlich Fallback-Version 0.0.0 gebaut wird.
SDK-Pin ist fest; die erlaubten Abhaengigkeitsbereiche upstream sind jedoch
kein vollstaendiger Hash-Lock. Paketaufloesungen koennen sich bei Update/Repair
aendern. Vollstaendig reproduzierbare Abhaengigkeits-Locks bleiben TODO.

## 3. Cloud und Geheimnisse bewusst trennen

Installation und Doctor benoetigen **keinen API-Key**. Kein Login, Upload,
Generierungsauftrag, Deployment oder Cloud-Smoke-Test wird aufgerufen.
Die drei Key-Umgebungsvariablen werden im Installer-Unterprozess entfernt,
ohne deine aufrufende Shell zu veraendern. Keine Token-Ausgabe in unseren Skripten.

Das SDK selbst ist **keine technische Cloud-/Kostensperre**: Ein spaeteres
eigenes Skript kann mit vorhandenen Zugangsdaten externe Anfragen ausfuehren.
Die Installation setzt keine Netzwerksandbox oder API-Budgetgrenze.
Vor manueller Nutzung muessen gelten:

- Eigener fal.ai-Zugang mit bewusstem Kostenlimit und passenden Dienst-/Modellrechten.
- Freigabe fuer externe Verarbeitung; keine Personalakten, fremden Stimmen,
  vertraulichen Bilder oder sonstigen privaten Daten ohne passende Rechte hochladen.
- Echte Secrets nur ausserhalb des Repositories, Dateirechte restriktiv.
  Kein API-Key in Prompts, Markdown, Commit, Terminalprotokoll oder Beispiel-URL.
- Timeout, begrenzte Wiederholungen, ein Auftrag gleichzeitig und manuelle
  Freigabe vor kostenpflichtigen Jobs oder Veroeffentlichung.

Wir liefern hier deshalb kein sofort laufendes Beispiel mit
`subscribe`, `submit`, `run` oder Upload-Funktionen. Es wird kein Port geoeffnet.
Ollama und ComfyUI bleiben die vorhandenen lokalen Alternativen fuer passende
Text-/Medienaufgaben; der Client verlagert fal.ai nicht auf deine GPU.

## 4. Status, Update und Deaktivierung

```bash
bash scripts/tools/fal_client_update.sh --dry-run
bash scripts/tools/fal_client_update.sh
bash scripts/tools/fal_client_install.sh --repair
bash scripts/tools/fal_client_uninstall.sh
```

Status bestaetigt nur die lokale SDK-Installation, niemals Konto, Kredit,
API-Verfuegbarkeit oder erfolgreichen Modellzugriff. Doctor prueft Metadaten,
Quell-Pin und Paketabhaengigkeiten, ohne SDK-Import.

Fehler fuehren nicht zu git reset, rekursivem Loeschen oder dem Ueberschreiben
fremder Checkouts. Daten sichern, Ursache beheben, dann --repair aufrufen.
Uninstall entfernt nur den Setup-Marker; Quelle, venv, eigene Daten und
eventuell separat hinterlegte Zugangsdaten bleiben erhalten.
Ein danach weiterhin manuell nutzbares SDK ist dadurch nicht gesperrt.

Offen: reale Installation je Linux/Python/Architektur, vollstaendiger
Dependency-Hash-Lock und eine separat freizugebende API-/Budget-Integration.
Keine echten Cloud-Anfragen oder Installationen waehrend unserer Repository-Tests.

Quellen: [Paketmetadaten am Pin](https://github.com/fal-ai/fal/blob/80ddb1d8f2f4b0a28a0323fd3c1d96e34c849eb5/projects/fal_client/pyproject.toml),
[SDK-Einstieg](https://github.com/fal-ai/fal/blob/80ddb1d8f2f4b0a28a0323fd3c1d96e34c849eb5/projects/fal_client/src/fal_client/__init__.py),
[Apache-2.0-Code-Lizenz](https://github.com/fal-ai/fal/blob/80ddb1d8f2f4b0a28a0323fd3c1d96e34c849eb5/LICENSE).
fal.ai-Dienstbedingungen und Modelllizenzen davon getrennt pruefen.
