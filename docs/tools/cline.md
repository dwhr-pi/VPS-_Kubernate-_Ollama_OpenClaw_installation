# Cline aus GitHub, ohne Docker

## Zuerst verstehen

Cline ist ein Coding-Agent, kein Video-/Modellpaket. Der bisherige gemeinsame
Hybrid-Platzhalter installierte nichts. Jetzt bietet das Setup einen eigenen
optionalen **GitHub-Release-Pfad fuer die VS-Code-Erweiterung**. Kein Docker,
apt-App-Paket, npm-Globalinstall oder grosser Bun/Node-Source-Build.
Das ist **nicht** die separate Cline-CLI oder Desktop-App.

Quelle: [cline/cline](https://github.com/cline/cline), Code Apache-2.0.
Festgelegt: [Release v4.1.25](https://github.com/cline/cline/releases/tag/v4.1.25),
Asset `cline-4.1.25.vsix`. Die
[Extension-Metadaten](https://github.com/cline/cline/blob/v4.1.25/apps/vscode/package.json)
nennen `saoudrizwan.claude-dev` und VS Code `^1.101.0`.
Es wird kein bewegliches `latest` heruntergeladen.

## 1. Paket bereitstellen

Im aktuellen Setup-Verzeichnis, als normaler Benutzer ohne sudo:

```bash
bash scripts/tools/cline_install.sh --dry-run
bash scripts/tools/cline_install.sh
bash scripts/tools/cline_doctor.sh
bash scripts/tools/cline_status.sh
```

Oder im Tools-Menue **Cline** auswaehlen. Erforderlich: Bash, Python 3.10+,
curl, sha256sum und flock. Python 3.12 passt. Die Basiswerkzeuge bei Bedarf
bewusst separat einrichten, keine automatische System-/Editorinstallation.
Das Release-Paket braucht weder lokales Node/Bun noch Modelle/GPU.
Konservative Setup-Reserve: 256 MiB freie Ziel-Disk, unter WSL zusaetzlich
1 GiB auf Windows C:. Dies sind Paketbereitstellungsgrenzen, keine gemessenen
RAM-Mindestwerte des Editors oder eines lokalen LLM.

Ziel: `~/.openclaw_ultimate_user_data/tools/cline/cline-4.1.25.vsix`.
Protokolle: `~/.openclaw_ultimate_user_data/install_logs/cline_*.log`.
`OPENCLAW_USER_DATA_DIR` erlaubt einen anderen absoluten, normalisierten
Workspace ausserhalb des Repos. Symlink-Pfade werden abgelehnt.

Vor der Bereitstellungsmarkierung werden SHA-256, Version, Publisher und
Extension-Identitaet geprueft. Erwarteter Hash aus GitHubs Release-Metadaten:

```text
aac83af0513f5168372905c02a72eee3835d32a53b9d635d3b055ed4a7bd71fc
```

Der Download nutzt HTTPS, Timeout und Groessenlimit. Die ZIP-Datei wird nur
gelesen, nicht entpackt/ausgefuehrt. Hashvergleich ist kein vollstaendiger
Supply-Chain-Audit und keine Publisher-Signaturpruefung.

**Wichtig:** `package_ready: true` und `release-ready` bedeuten nur
**Paket bereitgestellt**, nicht **im Editor installiert**. Die allgemeine
Toolliste erkennt diesen Paketmarker, nicht den Zustand deiner Windows-IDE.
Doctor/Status pruefen offline und laden nichts nach.

## 2. In deinem gewuenschten VS Code installieren

Den vorhandenen Windows- oder Linux-Editor selbst oeffnen. Unter Windows
in dessen Erweiterungsansicht **... -> Install from VSIX...** auswaehlen
und die gerade bereitgestellte Datei angeben. Fuer eine in WSL liegende
Datei ueber den Explorer `\\wsl.localhost\<DEINE-DISTRO>\home\<DEIN-LINUX-USER>\`
oeffnen, dann zum obigen `.openclaw_ultimate_user_data`-Unterordner navigieren.
Alternativ die VSIX bewusst in einen Windows-Downloadordner kopieren.
Keine EXE, keinen Container und kein zweites Quellrepository benoetigt.

Native Linux-Alternative, **nur selbst im gewuenschten Editor-Kontext**:

```bash
code --install-extension "$HOME/.openclaw_ultimate_user_data/tools/cline/cline-4.1.25.vsix"
```

Das Setup ruft `code` nicht automatisch auf: Unter WSL kann es zum Windows-
Editor oder zu einem Remote-Extension-Host gehoeren. In VS Code kontrollieren,
ob die Extension lokal unter Windows oder im Remote-WSL-Kontext installiert
werden soll. Bestehende Editorprofile und Schluessel werden nicht angefasst.
Auf einem headless Oracle-VPS/RPi nur Paketbereitstellung, keine IDE voraussetzen.
Windows-/Linux- und ARM-Editorfunktion wurden hier nicht Ende-zu-Ende getestet.

## 3. Modelle und Rechte bewusst konfigurieren

Provider erst nach Installation selbst in Cline konfigurieren. Fuer lokale
Nutzung einen bereits vorhandenen Ollama-Server und ein passendes Coding-Modell
waehlen; das Setup installiert weder Ollama noch Modelle und testet keine API.
Ollama nicht oeffentlich freigeben. Bei getrennter Windows-/WSL-Ausfuehrung muss
der eingestellte lokale Endpunkt aus genau diesem Kontext erreichbar sein.
Cloud-Provider koennen Kosten und Datenuebertragung verursachen.

Zuerst synthetisches Testprojekt, Plan-Modus und einzelne Freigaben nutzen.
Auto-Approve deaktiviert lassen; keine Wallet-/SSH-/Produktionskeys an den
Agenten geben. Keine automatischen Shellfreigaben oder ENV-Tresorimporte.
OpenClaw/n8n-Adapter sind hier nicht umgesetzt; nicht beliebige Agentenaufgaben
parallel ausfuehren. Erst ein Auftrag mit festen Zeit-/Budgetgrenzen.
VSIX-Bereitstellung ist kein Sicherheitsnachweis fuer spaetere Agentenaktionen.

## Update, Fehler und Entfernen

```bash
bash scripts/tools/cline_update.sh
bash scripts/tools/cline_install.sh --repair
bash scripts/tools/cline_uninstall.sh
```

Update prueft/erneuert denselben festen Release, kein stilles Versionsupgrade.
Ein eigenes Operations-Lock verhindert parallele Paketoperationen. Bestehende
abweichende Pakete werden weder ersetzt noch geloescht: erst manuell sichern.
Fehlerhafte neue Downloads bleiben ohne Erfolgsmarkierung. Paketinstallation
ist bei passendem Hash idempotent und laedt nicht erneut herunter.

Uninstall entfernt nur das gepruefte VSIX und den Paketmarker, nicht die IDE-
Erweiterung, Editor-Einstellungen, Keys, Projekte oder Logs. Eine separat
installierte Extension im richtigen VS-Code-Profil selbst deinstallieren.
VS Codes eigener Extension-Updater ist unabhaengig vom Setup-Pin; dessen
Updateverhalten im Editor bewusst festlegen.

Die Entwicklung/Tests hier verwenden nur synthetische Archive und Mocks.
Kein echtes VSIX, Modell oder Editor wurde installiert und keine WSL veraendert.
