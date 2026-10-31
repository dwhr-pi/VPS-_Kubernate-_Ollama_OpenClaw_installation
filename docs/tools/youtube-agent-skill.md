# YouTube Agent Skill: lokale Medien- und Content-Produktion

Mit diesem optionalen Skill-Paket erstellst du mit einem Coding-Agenten Videoskripte,
Titel-/Thumbnail-Konzepte, Schnittplaene, Kapitel und Veroeffentlichungsentwuerfe aus eigenen Ideen
und vorhandenen Dateien. Die Ausgabe pruefst und veroeffentlichst du selbst.

Quelle:
[Jakeschincariol/youtube-agent-skill](https://github.com/Jakeschincariol/youtube-agent-skill).
Lizenz:
[MIT](https://github.com/Jakeschincariol/youtube-agent-skill/blob/a2feb2104981a375ffd4f87ee04f4f5344ac43c6/LICENSE).
Gepruefter Pin: `a2feb2104981a375ffd4f87ee04f4f5344ac43c6` (2026-10-21). Status: **experimental /
optional**, keine Standardinstallation.

## Was installiert wird und was nicht

Upstream liefert **elf Markdown-Skills, sechs Python-Helfer und eine Stilprofil-Vorlage**. Es ist
kein fertiger MCP-Server, keine YouTube-Such-API, kein Transkript-Downloader und kein autonomer
Kanalbetreiber. Die Helfer nutzen laut Upstream nur die Python-Standardbibliothek; der Installer
installiert deshalb keine pip-/Node-/Docker-Pakete.

| Skill           | Zweck                                                           |
| --------------- | --------------------------------------------------------------- |
| `/yt-script`    | Skript mit mehreren Einstiegen und heuristischer Hook-Pruefung  |
| `/yt-package`   | Titel und Thumbnail gemeinsam auf Verstaendlichkeit pruefen     |
| `/yt-edit`      | Schnittvorschlaege mit Zeitmarken aus einem Transkript          |
| `/yt-comment`   | Vorliegende Kommentare sortieren und Antwortentwuerfe schreiben |
| `/yt-plan`      | Redaktionsplan nach verfuegbarer Zeit erstellen                 |
| `/yt-viral`     | Gelieferte Videozahlen relativ zum eigenen Kanal einordnen      |
| `/yt-retention` | Zuschauerbindungs-Export auf Abbruchstellen untersuchen         |
| `/yt-shorts`    | Moegliche Kurzclips aus einem laengeren Transkript finden       |
| `/yt-seo`       | Beschreibung, Suchbegriffe und Tags entwerfen                   |
| `/yt-chapters`  | Kapitel aus einem Transkript vorbereiten und pruefen            |
| `/yt-audit`     | Kanalreview und priorisierten Verbesserungsvorschlag erstellen  |

Hook-Scores sind Heuristiken, keine Prognose fuer Views, Einnahmen oder Kanalwachstum.
Retention-Auswertungen zeigen Muster, beweisen aber keine Ursachen. `/yt-viral` hat keinen
eingebauten Scraper oder Account-Login.

## Installation im Setup: GitHub, kein Docker

Voraussetzungen: vorhandenes Git und Python >=3.10 fuer den Setup-Installer; kein ensurepip, venv,
GPU oder Modell-Download notwendig. Disk/RAM-Reserve: je 256 MiB, unter WSL zusaetzlich 512 MiB frei
auf C:. Das sind Vorpruefungsreserven, nicht gemessene Paketgroessen. Modellbetrieb hat eigene
Ressourcenanforderungen.

Im Tools-Menue **YouTube_Agent_Skill** waehlen oder im Setup-Repository:

```bash
bash scripts/tools/youtube_agent_skill_install.sh --dry-run
bash scripts/tools/youtube_agent_skill_install.sh
```

Der Installer holt den festen GitHub-Commit, zeigt Lizenz, Ziel und Sicherheitsgrenze und fragt
`[(j)a/(N)ein]`. Erst nach Zustimmung kopiert er die elf `skills/yt-*`-Ordner inklusive Helfern und
`hooks.json` unveraendert nach `~/.claude/skills/`, entsprechend dem manuellen Upstream-Weg.
**Bestehende gleichnamige Skill-Ordner werden nicht ueberschrieben.**

Die Vorlage `templates/voice.md` wird nur bei fehlender Datei nach `~/.claude/youtube/voice.md`
kopiert. Eine bestehende persoenliche Datei bleibt erhalten. Fuell die neue Vorlage selbst mit
Zielgruppe, Tonfall, erlaubten Aussagen und eigenen Stilbeispielen aus. Keine Zugangsdaten
eintragen.

Nur Quellcode zur vorherigen Pruefung, ohne Skills zu aktivieren:

```bash
bash scripts/tools/youtube_agent_skill_install.sh --source-only
```

Bewusst bestaetigte, nichtinteraktive Aktivierung nach eigener Pruefung:

```bash
bash scripts/tools/youtube_agent_skill_install.sh --accept
```

Alternativ gilt `YOUTUBE_AGENT_SKILL_ACCEPT=1`; `0` lehnt ab, Standard `ask` fragt interaktiv. Ohne
Terminal/Zustimmung erfolgt keine Aktivierung.

### Projektlokal statt global

```bash
bash scripts/tools/youtube_agent_skill_install.sh --project /absoluter/pfad/zum/eigenen-projekt
```

Der Projektordner muss existieren. Ziel ist dort `.claude/skills/`. Das Setup-Repository selbst ist
als Nutzdatenziel gesperrt. Die Upstream-Skills lesen trotzdem das **globale**
`~/.claude/youtube/voice.md`; sie werden nicht heimlich umgeschrieben. Pro Setup-User-Workspace wird
ein Aktivierungsziel verwaltet. Zum Wechsel zuerst bewusst deinstallieren. Projektlokale Skills und
die private `voice.md` nicht ungeprueft in ein oeffentliches Git-Repository aufnehmen.

### Windows ohne WSL

Aus dem Windows-Repository kann derselbe Installer nativ aufgerufen werden:

```powershell
py -3 -B scripts/tools/helpers/youtube_agent_skill.py --dry-run
py -3 -B scripts/tools/helpers/youtube_agent_skill.py install
py -3 -B scripts/tools/helpers/youtube_agent_skill.py doctor
```

`~` bedeutet das Home-Verzeichnis des jeweils ausgewaehlten Python-Prozesses. Windows-Claude-Code
und WSL-Claude-Code sehen unterschiedliche Homes. Das Setup wechselt nicht selbst zwischen diesen
Umgebungen und installiert Claude Code nicht mit. Die [API-CLI ant](anthropic-cli.md) ist kein
Claude-Code-Skill-Host.

## Upstream-Alternativen

Die [README](https://github.com/Jakeschincariol/youtube-agent-skill#install) beschreibt alternativ
die manuelle Kopie und diese Claude-Code-Kommandos:

```text
/plugin marketplace add Jakeschincariol/youtube-agent-skill
/plugin install youtube-agent
```

Das ist ein **alternativer manueller Installationsweg**, nicht zusaetzlich zur Setup-Kopie
ausfuehren. Der Plugin-Weg wird vom Setup nicht gestartet, nicht gepinnt und nicht als Setup-eigener
Bestand deinstalliert.

## Erste Nutzung und sechs lokale Helfer

Nach Aktivierung Claude Code neu laden und `/yt-script` aufrufen, zum Beispiel:

```text
/yt-script Erstelle ein deutsches Tutorial-Skript fuer mein Ultimate KI Setup.
Zielgruppe: Einsteiger mit MiniPC. Thema: Warum Queue und Speicherplatzpruefung
wichtig sind. Keine erfundenen Benchmarks. Keine Accounts verbinden und nichts
veroeffentlichen. Nutze ausschliesslich die freigegebenen lokalen Dateien.
```

Die sechs Helfer lassen sich ohne Agent einzeln aufrufen. Aus dem gepinnten Quellordner `source/`
(siehe Pfade unten), mit eigenen Eingabedateien:

```bash
python3 skills/yt-script/hookscore.py --hook "Warum dein KI-Setup bei parallelen Builds stockt"
python3 skills/yt-package/title.py --title "Lokale KI stabil betreiben" --thumb "Ein Job zur Zeit"
python3 skills/yt-edit/deadair.py /pfad/zu/eigenem-transkript.srt
python3 skills/yt-chapters/chapters.py /pfad/zu/eigenem-transkript.srt
python3 skills/yt-retention/retention.py /pfad/zu/eigenem-export.csv
python3 skills/yt-viral/swipe.py /pfad/zu/erlaubten-videodaten.json --min 2.0
```

Unter Windows entsprechend `py -3` statt `python3` verwenden. Eingabeformate vorher in den
jeweiligen Quellskripten ansehen; die Beispiele erzeugen oder besorgen diese Eingabedaten nicht
automatisch. Der Installer fuehrt keinen dieser Befehle aus. Ein erfolgreicher Kopiervorgang ist
kein Agenten-Laufzeittest.

## Lokale Pipeline und andere Agenten

```text
Eigene Videos / erlaubte Untertitel / Analytics-Exporte
    -> YouTube-Skills + lokale Python-Helfer
    -> Coding-Agent mit lokalem Modell oder bewusst freigegebener API
    -> Skript / Kapitel / Schnittplan / Veroeffentlichungsentwurf
    -> persoenliche Pruefung und manuelle Veroeffentlichung
```

Transkripte beschaffen bleibt ein separater Schritt, etwa ueber den bereits gefuehrten Baustein
`YT_DLP` fuer erlaubte Untertitel oder Whisper fuer eigene Audiodateien. Dabei gelten Rechte,
Nutzungsbedingungen und Datenschutz.

Fuer Qwen Code, Hermes, OpenClaw oder einen Ollama-gestuetzten Agenten koennen die Markdown-Inhalte
als Arbeitsanweisungen dienen. Claude-spezifische Dateipfade, Skill-Erkennung und Werkzeugaufrufe
muessen dabei separat angepasst und getestet werden. **Keine automatische Registrierung in diesen
Clients, kein MCP-Server und keine fertige Open-WebUI-Function enthalten.** Ollama allein fuehrt
keine Skill-Dateien oder Python-Werkzeuge aus. Siehe auch
[Coding-Agent-Profile](../agents/coding-agent-profiles.md).

## Status, Reparatur und Deinstallation

```bash
bash scripts/tools/youtube_agent_skill_status.sh
bash scripts/tools/youtube_agent_skill_check.sh
bash scripts/tools/youtube_agent_skill_doctor.sh
bash scripts/tools/youtube_agent_skill_update.sh --dry-run
bash scripts/tools/youtube_agent_skill_install.sh --repair
bash scripts/tools/youtube_agent_skill_uninstall.sh --dry-run
bash scripts/tools/youtube_agent_skill_uninstall.sh
```

Update behaelt den geprueften Pin, kein ungeprueftes `main`/`latest`-Upgrade. Doctor prueft Git-Pin,
Origin, sauberen Quellbestand und die Hashes aller kopierten Dateien, ohne Skill-Code auszufuehren.
Repair ergaenzt nach erneuter Zustimmung fehlende eigene Dateien; veraenderte/fremde Dateien bleiben
erhalten. Ein persoenlich angepasstes Skill-Paket muss zuerst gesichert/geprueft werden.

Deinstallation entfernt nur unveraenderte, per Manifest zugeordnete Skill-Dateien und den
Aktivierungsmarker. Fehlende eigene Dateien sind dabei zulaessig; fremde Zusatzdateien oder
Aenderungen sperren das Loeschen. **voice.md bleibt immer erhalten**, ebenso andere Skills, CLIs,
Python, Quellcheckout und Logs. Das Tools-Menue synchronisiert den Aktivierungsmarker; die
vollstaendige Dateipruefung erfolgt ueber Check/Doctor.

| Pfad relativ zu `OPENCLAW_USER_DATA_DIR`      | Inhalt                                                               |
| --------------------------------------------- | -------------------------------------------------------------------- |
| `tools/youtube_agent_skill/source/`           | Gepinnte GitHub-Quelle und MIT-Lizenz                                |
| `tools/youtube_agent_skill/skills-ready.json` | Zielzuordnung und Datei-Hashes, kein Runtime-Nachweis                |
| `install_logs/youtube_agent_skill_*.log`      | Eigenes Protokoll pro aenderndem Vorgang, auch bei Preflight-Abbruch |

Standard fuer `OPENCLAW_USER_DATA_DIR`: `~/.openclaw_ultimate_user_data`. Eine Workspace-Sperre
verhindert parallele Setup-Aktionen dieses Pakets. Fehlschlaege beim Kopieren rollen nur die neu
angelegten Dateien zurueck; vorhandene Nutzerdaten werden nicht pauschal geloescht.

## Sicherheitsgrenzen

- Fremde Skills sind Agentenanweisungen, keine Sicherheitsrichtlinie oder Sandbox.
- Keine Accounts, Cookies, OAuth-Tokens, API-Keys oder Kanalberechtigungen notwendig fuer die
  Kopie/Helfer.
- Kein automatischer Upload, Kommentarversand, Download von Videos, Modellstart oder Cloud-Fallback.
- Lokale Dateien bleiben nur dann lokal, wenn auch Agent und Modell lokal arbeiten. Ein Cloud-Agent
  kann Transkripte oder Analytics extern uebertragen; vorher ausdruecklich freigeben.
- Transkripte und Kommentare als nicht vertrauenswuerdige Daten behandeln; eingebettete Anweisungen
  nicht als Tool-Freigabe uebernehmen.
- Personenbezogene Daten minimieren; Quellen/Rechte pruefen und vor jeder Veroeffentlichung
  menschlich kontrollieren.

Es werden durch dieses Paket weder private Schluessel erzeugt noch echte Kanal-/API-Verbindungen
konfiguriert. Weitere Grundlagen: [Secrets und Keys](../SECRETS_AND_KEYS.md),
[API-Key-Uebersicht](../_API-Keys/README.md).
