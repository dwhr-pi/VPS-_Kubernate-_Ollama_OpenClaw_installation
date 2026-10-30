# find-skills fuer Claude Code und Qwen Code

**Sinn und Zweck:** find-skills hilft Coding-Agenten, passende Arbeitsanweisungen fuer Webdesign,
Tests, Dokumentation oder Deployment zu finden. Du beschreibst das Ziel, der Agent recherchiert und
empfiehlt Skills. Du entscheidest ueber die Installation. Das ist kein neues Sprachmodell.

## 1. Was du installierst

| Baustein                                                                                                              | Zweck                                  | Einordnung                                                      |
| --------------------------------------------------------------------------------------------------------------------- | -------------------------------------- | --------------------------------------------------------------- |
| [Vercel Skills CLI](https://github.com/vercel-labs/skills)                                                            | Skills suchen, auflisten und verwalten | Optionales MIT-Werkzeug; reine Skill-Kopie baut diese CLI nicht |
| [find-skills](https://github.com/vercel-labs/skills/tree/a80e4c9d12d607631249d4d7d059f835d4b2f13a/skills/find-skills) | Agentenanweisungen zur Auswahl         | Neuer Setup-Eintrag Find_Skills mit GitHub-Kopierinstaller      |
| [skills.sh](https://skills.sh/)                                                                                       | Online-Verzeichnis                     | Externer Katalog, kein Sicherheitszertifikat                    |

Gepruefter Pin am 20.10.2026: `a80e4c9d12d607631249d4d7d059f835d4b2f13a`, CLI-Version am Pin
`1.7.4`. Keine dauerhaften Rang-, Sterne- oder Installationszahlen versprochen. Das Google-Dokument
war online nicht erreichbar; der eingefuegte Text wurde mit GitHub-Quellen abgeglichen und fachlich
ueberarbeitet.

## 2. Nutzen und Sicherheitsgrenzen im Setup

Der Skill ergaenzt unsere [Coding-Agenten](../agents/coding-agent-profiles.md). Jarvis/OpenClaw
bleiben Orchestratoren; Modell, CLI, Berechtigungen und Skills sind getrennte Schichten. Fuer den
Skill selbst ist kein API-Key erforderlich. Agenteninferenz kann lokal oder kostenpflichtig extern
laufen. Online-Suche ist nicht offline: keine vertraulichen Projekttexte senden.

**Kein automatischer Sicherheitsfilter:** Hohe Installationszahlen und bekannte Herausgeber sind im
Upstream Hinweise an das Modell. Repos unter 100 Installationen werden nicht technisch garantiert
ausgeschlossen. Popularitaet ersetzt weder Codepruefung noch Schutz vor Prompt Injection. SKILL.md,
mitgelieferte Skripte, Lizenzen, Netzwerkziele und Rechte pruefen.

## 3. Empfohlen: aus GitHub mit dem Setup installieren

Im Tools-Menue **Find_Skills** waehlen oder im Setup-Checkout:

```bash
bash scripts/tools/find_skills_install.sh
```

Vorhandenes Python 3.10+ und Git genuegen. Keine Node-/npm-/Docker-/GPU-Pflicht fuer die
Skill-Kopie. Der Installer legt ein eindeutiges Log und Lock an, prueft Disk/RAM, laedt den exakten
GitHub-Commit und zeigt den vollstaendigen Skill samt MIT-Lizenz. Erst nach `[(j)a/(N)ein]`
aktiviert er den Skill. Ohne interaktives Terminal keine automatische Zustimmung.

Standardziel: `~/.claude/skills/find-skills/`. Fuer Qwen Code explizit waehlen:

```bash
FIND_SKILLS_AGENT=qwen-code bash scripts/tools/find_skills_install.sh
```

Ziel dann: `~/.qwen/skills/find-skills/`. Kopiert werden nur `SKILL.md` und `LICENSE`, keine
weiteren Skills. Ein Besitznachweis mit Commit und Dateihashes wird erst nach Erfolg geschrieben.
Weder Claude noch Qwen, Suchbefehle oder `npx` werden gestartet.

Pro externem Setup-Workspace wird genau ein Agentenziel verwaltet. Fuer den Wechsel zuerst bewusst
deinstallieren. Abweichende `CLAUDE_CONFIG_DIR`-Pfade werden nicht automatisch verfolgt; dort die
passende native CLI-Anleitung verwenden. Fremde Installationen nie ueberschreiben.

Nur fuer vorher gepruefte, unbeaufsichtigte Aktivierung:

```bash
FIND_SKILLS_ACCEPT=1 bash scripts/tools/find_skills_install.sh
```

`FIND_SKILLS_ACCEPT=0` lehnt ab. Die Freigabe gilt nicht fuer weitere Skills. Bei Ablehnung bleiben
Quelle und Log zur Pruefung, aber kein Installationsmarker und keine Agentendateien. Die
unveraenderten Upstream-Anweisungen enthalten `npx skills`-Vorschlaege: ohne separate Freigabe nicht
ausfuehren lassen.

### Pruefung, Update, Reparatur und Entfernen

```bash
bash scripts/tools/find_skills_install.sh --dry-run
bash scripts/tools/find_skills_install.sh --status
bash scripts/tools/find_skills_doctor.sh
bash scripts/tools/find_skills_install.sh --repair
bash scripts/tools/find_skills_update.sh
bash scripts/tools/find_skills_uninstall.sh
```

Dry-Run schreibt nichts und braucht kein Netzwerk. Doctor prueft Pin und Dateihashes, ohne einen
Agenten zu starten. Update bleibt beim selben Pin, kein blindes latest-Upgrade. Reparatur stoppt bei
fremden/veränderten Dateien; zuerst manuell vergleichen und sichern. Neue Kopierfehler rollen nur
Dateien dieses Versuchs zurueck, nicht bestehende Installationen.

Deinstallation entfernt ausschliesslich nachgewiesene, unveraenderte Dateien und den Marker. Bei
Zusatzdateien/Manipulation Abbruch statt Datenverlust. GitHub-Quelle und Logs bleiben im externen
User-Workspace unter `tools/find_skills/` bzw. `install_logs/`. Keine Basiswerkzeuge oder Modelle
werden entfernt. Einen Lock nach Prozessabsturz erst nach Pruefung auf laufende Operationen manuell
beurteilen, nicht blind loeschen.

## 4. Optionaler Ein-Befehl-Weg aus dem Ausgangstext

**Alternative, nicht GitHub-only:** `npx` bezieht die CLI aus npm, auch wenn der Skill von GitHub
stammt. Node mindestens 22.20.0 und npm/npx erforderlich. Die
[package.json am Pin](https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/package.json)
definiert diese Voraussetzungen. Nicht parallel auf einen vom Kopierinstaller verwalteten Skill
anwenden.

```bash
npx skills@1.7.4 add https://github.com/vercel-labs/skills --skill find-skills -g -a claude-code
```

Das pinnt die CLI, nicht automatisch den Skill-Commit. Ohne `-g` projektbezogene Installation. `-y`
ueberspringt Rueckfragen, `--all` kann viele Skills/Agenten betreffen: beides nicht als sicherer
Standard empfehlen. Die
[Befehlsreferenz](https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/docs/commands.md)
beschreibt Optionen und Quellenformate.

Nach diesem CLI-Weg die globale Installation passend global pruefen:

```bash
npx skills@1.7.4 list -g -a claude-code
npx skills@1.7.4 find documentation
npx skills@1.7.4 check
```

Ein direkt kopierter Skill hat keinen automatisch erzeugten CLI-Lockeintrag. Fuer unseren Setup-Weg
ist deshalb der Doctor massgeblich, nicht nur `skills list`. `skills update` kann mehrere
CLI-verwaltete Skills veraendern: zuerst Quellen und Diffs pruefen, keine blinden Sammelupdates.

Laut
[Upstream-Konfiguration](https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/docs/troubleshooting.md)
deaktivieren `DISABLE_TELEMETRY=1` oder `DO_NOT_TRACK=1` Telemetrie und Security-Audit-Anfragen.
Online-Suche bleibt trotzdem eine Netzwerkfunktion.

### Auch die CLI aus GitHub bauen (manuell, optional)

In einem separaten Benutzerordner, nicht im Setup-Checkout:

```bash
git clone https://github.com/vercel-labs/skills.git vercel-skills
cd vercel-skills
git checkout --detach a80e4c9d12d607631249d4d7d059f835d4b2f13a
# Voraussetzung: Node >=22.20.0 und vorhandenes pnpm 10.17.1
pnpm install --frozen-lockfile --ignore-scripts
pnpm run build
DISABLE_TELEMETRY=1 node bin/cli.mjs find documentation
```

Vorher Build-Skripte und Lockfile pruefen. Tool-Quellcode kommt aus GitHub, Abhaengigkeiten
weiterhin aus Paketregistries. Kein Docker, kein globales CLI. Das Setup baut die CLI nicht mit;
dieser Source-Build wurde hier nicht getestet.

## 5. Qwen Code Desktop unter Windows

Die pauschale Behauptung "geht nicht mit Qwen Desktop" ist zu weitgehend:
[Qwen Code dokumentiert Skills](https://github.com/QwenLM/qwen-code/blob/main/docs/users/features/skills.md).
Vercels
[Agentenliste](https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/docs/agents.md)
kennt `qwen-code`. Das beweist keinen Test jeder Desktop-Version.

1. [Qwen Code Desktop](qwen-desktop-windows.md) von Qwen Chat/Studio unterscheiden.
2. Fuer native Windows-Nutzung PowerShell und das Windows-Benutzerprofil nutzen. Eine
   WSL-Installation erscheint nicht automatisch im Windows-Profil.
3. Mit vorhandenem Windows-Python und Git direkt im Windows-Setup-Checkout:

   ```powershell
   py -3 -B scripts/tools/helpers/find_skills.py --dry-run --agent qwen-code
   py -3 -B scripts/tools/helpers/find_skills.py install --agent qwen-code
   ```

4. Ziel: `$HOME\.qwen\skills\find-skills\SKILL.md`; fuer Claude entsprechend
   `$HOME\.claude\skills\find-skills\SKILL.md`.
5. App/Agent neu laden und die Skill-Verwaltung bzw. `/skills` pruefen. Falls die installierte
   Version das Feature nicht anbietet, offizielle Versionshinweise oder die kompatible Qwen-Code-CLI
   verwenden.

Kein Desktop-Live-Test durchgefuehrt. Die GUI wird dadurch nicht zum lokalen Modellserver; Modell,
Werkzeugrechte und Netzwerkfreigaben separat konfigurieren.

## 6. Drei Prompts zum Kopieren

### Projektbezogene Auswahl

```text
Nutze find-skills fuer dieses Ziel: [Projekt und gewuenschtes Ergebnis].
Lies nur freigegebene Projektdateien, keine ENV-/Secret-Dateien.
Schlage maximal 5 Skills vor: Name, Nutzen, GitHub-Quelle, Lizenz,
belegbare Installationszahl mit Abrufdatum und Installationsbefehl.
Bevorzuge ueber 1.000 Installationen, erfinde keine fehlenden Zahlen.
Pruefe SKILL.md und Skripte auf Rechte und Netzwerkzugriffe.
Installiere und aktualisiere nichts; ich entscheide pro Skill.
```

### Bestehende Skills beurteilen

```text
Nutze find-skills fuer einen Skill-Check. Meine Aufgaben: [drei Aufgaben].
Pruefe nur freigegebene Skill-Verzeichnisse.
Zeige moegliche Ueberschneidungen und hoechstens 3 sinnvolle Ergaenzungen.
Begruende jede Empfehlung. Nenne Quelle, Lizenz und belegbare Metadaten.
Markiere Unbekanntes als unbekannt. Nichts installieren, entfernen oder updaten.
```

### Wiederkehrenden Workflow planen

```text
Plane mit find-skills diesen Workflow: [z. B. 3 Reels pro Woche fuer mein Cafe].
Tabelle: Schritt, Skill, Quelle, Lizenz, benoetigte Rechte und Kostenrisiko.
Kein automatisches Publizieren und keine Account-/Cloud-Aktivierung.
Erst nach Freigabe der konkreten Skill-Liste, Pins und Zielpfade
darfst du genau diese Skills installieren. Ein allgemeines "ok" fuer den Plan
ist keine unbeschraenkte Installationsfreigabe. Zeige danach einen Start-Prompt.
```

## 7. Fehlersuche und Ressourcen

| Problem / Zielhost        | Einordnung                                                                            |
| ------------------------- | ------------------------------------------------------------------------------------- |
| Node/npx fehlt            | Fuer Kopie nicht erforderlich; fuer optionale CLI passende Runtime separat einrichten |
| Skill fehlt im Agenten    | Benutzerprofil/Ziel/Version pruefen, Agent neu laden, Setup-Doctor nutzen             |
| Ziel vorhanden            | Nicht erzwingen: erst vergleichen/sichern                                             |
| Kein Treffer              | Spezifischere Suchbegriffe; keine Erfolgsgarantie                                     |
| MiniPC / RPi5 / Dual Xeon | Kopie ohne GPU, 256 MiB freie Disk/RAM-Reserve; Modellbedarf separat                  |
| WSL2 / Oracle VPS         | Getrennte Benutzerprofile; C: unter WSL mindestens 512 MiB Reserve                    |
| Gaming-PC / RTX 5080      | Skill selbst 0 VRAM; Modellinferenz unabhaengig                                       |
| Kubernetes                | Kein Daemon/Deployment; nur in freigegebenen Agentenkontext einbinden                 |

Die Reserven betreffen den kleinen Checkout, keine CLI-Builds/Modelle. Das Tools-Menue kann vorher
seine strengere allgemeine Speicherplatz-Wache anwenden (ohne Messwerte 4 GiB Linux / 5 GiB
Windows-C:, spaeter ggf. mehr). Die kleine direkte Installer-Reserve schwaecht diese Menuepruefung
nicht ab. Ein Lock verhindert parallele Find_Skills-Operationen im selben Workspace. Logs enthalten
aktuelle Vorpruefungsfehler. Keine API-Keys werden benoetigt oder erzeugt; kein Konto, Port oder
Hintergrunddienst wird aktiviert. [Security Baseline](../SECURITY_BASELINE.md),
[Secrets](../SECRETS_AND_KEYS.md) und [Queue](../CODEX_TASK_QUEUE.md) beachten. Prompts sind keine
Sandbox.

## Quellen

- [find-skills-Anweisungen](https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/skills/find-skills/SKILL.md)
- [MIT-Lizenz](https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/LICENSE)

Zurueck zum [Tool-Index](../TOOL_INDEX.md).
