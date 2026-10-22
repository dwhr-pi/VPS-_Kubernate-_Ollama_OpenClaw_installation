# Agentic_OS: optionaler Evaluationskandidat, nicht die neue Zentrale

Stand: **22.10.2026**. Quelle:
[modimihir07/agentic-os](https://github.com/modimihir07/agentic-os).
**Vermerk fuer dieses Setup:** als isoliertes MiniPC-/Dashboard-Experiment
interessant; vorerst kein Kernbestandteil und kein Ersatz fuer OpenClaw,
Ollama, Open WebUI oder bestehende Kubernetes-/Workflow-Verwaltung.

## Was es ist und was am Ausgangstext zu korrigieren ist

Der gepruefte Stand hat einen **Python-/FastAPI-Server mit JavaScript-/Tailwind-
SPA**, keinen Next.js-Monolithen. Node ist fuer bestimmte Agenten relevant,
nicht die primaere Dashboard-Laufzeit. Es ist ein Agenten-Dashboard, kein
Betriebssystem. Quelle: [README](https://github.com/modimihir07/agentic-os#architecture).

Es kann Aufgabenansichten, ein gemeinsames brain-Verzeichnis, Skills,
FTS5-Suche, Planung und Kostenansichten buendeln. Die vorgesehenen Adapter
sind opencode, Hermes und agy/Antigravity. agy ist nicht einfach ein anderer
Name fuer unsere Gemini CLI. FTS5 ist Volltextsuche, nicht automatisch
semantische Vektorsuche oder ein Beleg fuer Hermes-internes Gedaechtnis.

Lokales Dashboard bedeutet nicht lokale Inferenz: die gestarteten Agenten,
Provider und Tools bestimmen Datenfluss und Kosten. Free-Tier-Werbung und
Kostenanzeigen sind keine Garantie gegen Rechnungen. Fehlende Adapter
machen das Projekt nicht generell unbrauchbar; die Eingliederung unserer
Ollama-/OpenClaw-/Qwen-Wege ist aber nicht nachgewiesen.

## Warum nur mit Vermerk aufnehmen?

| Passend fuer dich | Offene Grenze |
|---|---|
| Zentrale Sicht auf kleine Agentenaufgaben und Skills | Zusaetzliche Orchestrierung neben unserem bestehenden Setup |
| brain/ und nachvollziehbare Projektinformationen | Keine ungepruefte Freigabe fuer Personalakten, Secrets oder Walletdaten |
| MiniPC als separater Kontrollrechner | Nicht dort automatisch alle Modelle oder Agenten parallel ausfuehren |
| Ideen fuer Scheduler und Aufgabenoberflaechen | Kein globaler Ein-Job-Lock oder CPU-/RAM-Schutz fuer unser Setup bestaetigt |
| MIT-lizenziertes Quellprojekt | Agenten, Modelle, Providerzugang und Abhaengigkeiten gesondert pruefen |

Nicht pauschal als zu unflexibel verwerfen, aber auch nicht als fertige
universelle Integrationsschicht empfehlen. Fuer RTX 5080 und Letsung MiniPC
fehlen eigene Last-, Recovery- und Datenschutztests. Dieser Vermerk ist
eine technische Einschaetzung, kein gemessener Benchmark.

## Kritische Punkte im geprueften Quellstand

Fester Quellpin:
[9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6](https://github.com/modimihir07/agentic-os/tree/9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6).
Der Pin fixiert Quellen, nicht alle transitiven Pakete.

- [start.sh](https://github.com/modimihir07/agentic-os/blob/9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6/start.sh)
  installiert bei jedem Start requirements nach und beendet anhand der
  Portbelegung gefundene Prozesse mit kill -9, ohne ausreichenden Eigentumsnachweis.
  In unserem Setup koennte Port 8080 bereits anderweitig genutzt sein.
- [server.py](https://github.com/modimihir07/agentic-os/blob/9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6/server.py)
  startet den Scheduler im Lifespan und liest den OpenRouter-Key aus
  ~/.hermes/.env, falls vorhanden. Ein Start ist daher kein passiver UI-Test.
  Schreib-/Ausfuehrungs- und Webhook-Endpunkte brauchen eine gesonderte
  Authentisierungs-/Autorisierungspruefung; CORS allein ist kein Zugriffsschutz.
- [scheduler.py](https://github.com/modimihir07/agentic-os/blob/9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6/scheduler/scheduler.py)
  kann APScheduler bei fehlendem Import per pip nachinstallieren.
  Keine impliziten Laufzeitdownloads oder Cron-Aktionen fuer eine Evaluation erlauben.
- [requirements.txt](https://github.com/modimihir07/agentic-os/blob/9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6/requirements.txt)
  verwendet Versionsuntergrenzen statt eines vollstaendig gelockten
  Abhaengigkeitsstands. Die [Upstream-Installation](https://github.com/modimihir07/agentic-os/blob/9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6/install.sh)
  kann Laufzeiten herunterladen; sie wird hier nicht ausgefuehrt.

Das ist ein begrenztes Quelltextreview, kein vollstaendiger Security-Audit.
Keine schreibende Probe gegen einen fremden oder produktiven Dienst.

## Im Setup: echter GitHub-Quellcheckout, keine Runtime

Tools-Menue: **Agentic_OS**. Status **experimental**, Modus
**github-source-only**, nicht automatisch ausgewaehlt/installiert.
MIT am Pin; Lizenzdatei und Quellen werden mit vorbereitet.

| Aktion | Umfang |
|---|---|
| Installation | Gepinnte GitHub-Quellen nach externem User-Workspace holen; keine Upstream-Skripte ausfuehren |
| Update / Repair | Denselben Pin pruefen/vorbereiten, kein automatisches main/latest-Upgrade |
| Status / Check / Doctor | Commit, Origin, unveraenderten Quellbestand und Setup-Marker pruefen, keine Imports oder Modellanfragen |
| Deinstallation | Nur Setup-Marker deaktivieren; Quellen und Logs bleiben erhalten, keine Nutzerdaten loeschen |

Ziel: ${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/agentic_os/source.
Der Marker source-ready.json dokumentiert nur Quellen, mit
**runtime_ready=false**. Eine Anzeige als vorbereitet/installiert in der
Toolverwaltung ist bei diesem Eintrag ausdruecklich kein laufendes Dashboard.

Voraussetzungen: vorhandenes Python >=3.10, Git und SSL; keine automatische
Systeminstallation. Fuer diesen Quellcheckout gilt die vorhandene 1-GiB-
Disk-Reserve plus die gemeinsame Ressourcenwache. Das ist kein gemessener
RAM-/Disk-Mindestbedarf einer vollstaendigen Runtime. Windows-Host-Disk und
Linux/WSL-Disk nicht verwechseln. Logs entstehen pro Aktion; ein fehlgeschlagener
Quellcheckout darf keinen Erfolgsmarker erzeugen.

Manuelle Befehle vom Setup-Root, hier nicht zur Installation ausgefuehrt:

```bash
bash scripts/tools/agentic_os_install.sh --dry-run
bash scripts/tools/agentic_os_install.sh
bash scripts/tools/agentic_os_status.sh
bash scripts/tools/agentic_os_doctor.sh
bash scripts/tools/agentic_os_update.sh --dry-run
bash scripts/tools/agentic_os_uninstall.sh
```

Alternativ ohne Bash direkt den vorhandenen Python-Einstieg nutzen:
```text
python -B scripts/tools/helpers/offload_sources.py agentic_os plan
```
Der Plan schreibt nichts und fuehrt keinen Upstream-Code aus. Auf Windows
fuer diesen Plan keine WSL-Distro starten. Bash-Wrapper mit bash aufrufen;
ein nativer Windows-Runtimetest der Anwendung ist damit nicht belegt.

## Bedingungen vor einem spaeteren Laufzeittest

Separates Testkonto/Arbeitsverzeichnis ohne ~/.hermes-Keys und produktive
Cloud-/Git-Zugangsdaten. Scheduler, Agenten, Webhooks und automatische
Nachinstallationen vorab kontrolliert deaktivieren. Portkollisionen melden
statt Prozesse zu beenden; nur Loopback binden. Provider explizit waehlen,
kein Cloud-Fallback oder Upload im Hintergrund.

Zuerst eine synthetische Aufgabe, ein Job gleichzeitig, festes Zeit-/Kosten-
budget, Diff und echte Tests. Memory/Logs/Backups auf sensible Inhalte pruefen;
ein gemeinsames brain-Verzeichnis ist keine Mandantentrennung. Keine
Synchronisation unseres Masterkey-Verzeichnisses oder echter Personalakten.

Diese Schutzmassnahmen sind Voraussetzungen fuer eine spaetere angepasste
Runtime, nicht bereits im fremden Dashboard nachgeruestete Garantien.
Kein Docker oder Kubernetes erforderlich, um nur die Quellen zu evaluieren.
Eine produktive Integration bleibt ein separater, ausdruecklicher Auftrag.

## Verifikation dieser Integration

35 Offline-Tests bestanden: zehn neue Agentic_OS-Tests sowie 25 vorhandene
Source-only-/Colibri-Tests. Git und Ressourcenfehler wurden mit lokalen
Fixtures geprueft; kein echter Upstream-Clone, Import oder Dashboard-Test.
Shell-Syntax und Diff-Pruefung ohne Fehler. Ein nativer Windows-Dry-Run
zeigte nur Pin/Ziel/Umfang, ohne Download oder WSL-Zugriff.
