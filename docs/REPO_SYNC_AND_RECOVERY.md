# Repository Sync and Recovery

Diese Seite beschreibt den sichersten Weg, um das Repository auf Windows, Ubuntu/WSL und in Codex-Worktrees wieder in einen sauberen Zustand zu bringen.

## Ziel

Es gibt in diesem Projekt typischerweise drei unterschiedliche Arten von Arbeitskopien:

1. die normale Hauptkopie auf Windows
2. die Laufzeitkopie unter Ubuntu oder WSL
3. temporaere Codex-Worktrees

Wichtig:

- `origin/main` ist die offizielle Wahrheitsquelle
- die Hauptkopie ist deine lokale Referenz
- `~/openclaw_ultimate_setup` ist deine Laufzeitkopie
- Codex-Worktrees sind nur temporäre Bearbeitungskopien

## Woran du einen problematischen Zustand erkennst

Typische Anzeichen:

- `git pull` weigert sich wegen lokaler Änderungen
- eine Version im Menü passt nicht zu GitHub
- Dateien sehen im Editor anders aus als in deiner Laufzeitkopie
- du befindest dich auf `HEAD` statt auf `main`
- `git status` zeigt sehr viele `M` oder `??`

## 1. Windows-Hauptkopie bereinigen

Beispielpfad:

```bash
cd ~/Documents/GitHub/Codex/VPS,_Kubernate,_Ollama_OpenClaw_installation
```

### Nur prüfen

```bash
git status
git branch -vv
git fetch origin --prune
git rev-parse HEAD
git rev-parse origin/main
```

### Sicherung als Patch anlegen

```bash
git diff > ../repo_backup.patch
```

### Hart auf GitHub zurücksetzen

Nur verwenden, wenn du lokale Repo-Änderungen wirklich verwerfen willst:

```bash
git fetch origin --prune
git checkout main
git reset --hard origin/main
git clean -fd
```

## 2. Ubuntu- oder WSL-Laufzeitkopie bereinigen

Beispielpfad:

```bash
cd ~/openclaw_ultimate_setup
```

### Nur prüfen

```bash
git status
git branch -vv
git fetch origin --prune
git rev-parse HEAD
git rev-parse origin/main
grep 'APP_VERSION=' setup_ultimate.sh
```

### Hart auf GitHub zurücksetzen

```bash
git fetch origin --prune
git checkout main 2>/dev/null || git checkout -b main --track origin/main
git reset --hard origin/main
git clean -fd
bash ./setup_ultimate.sh
```

### Komplett neu klonen

```bash
rm -rf ~/openclaw_ultimate_setup
cd ~
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

## 3. Codex-Worktrees richtig einordnen

Typische Pfade:

```text
C:\Users\danie\.codex\worktrees\...
```

Diese Worktrees sind:

- temporäre Bearbeitungskopien
- oft auf `detached HEAD`
- nicht deine stabile Hauptkopie
- nicht die bevorzugte Quelle für manuelle Updates

### Prüfen

```bash
git worktree list --porcelain
git branch -vv --all
git status
```

### Wichtig

Wenn ein Codex-Worktree stark abweicht, heißt das nicht automatisch, dass GitHub falsch ist. Häufig ist nur dieser eine temporäre Worktree vom normalen `main` entkoppelt.

## 4. Benutzer-Workspace bewusst getrennt behandeln

Die sensiblen und bearbeitbaren Daten liegen bewusst außerhalb des Repositories:

```bash
~/.openclaw_ultimate_user_data
```

Dort können liegen:

- `.env`-Vorlagen
- `config.json`-Vorlagen
- Statusdateien
- Metriken
- Prompts
- lokale Modelfiles

Wichtig:

- `git reset --hard` im Repository löscht diesen Bereich nicht
- das ist Absicht

### Benutzer-Workspace separat löschen

```bash
rm -rf ~/.openclaw_ultimate_user_data
```

## 5. Schnellprüfung der installierten Setup-Version

```bash
grep 'APP_VERSION=' setup_ultimate.sh
```

Oder über GitHub direkt:

```bash
git show origin/main:setup_ultimate.sh | grep 'APP_VERSION='
```

Wenn du **nicht** im Repository-Verzeichnis bist, nutze stattdessen:

```bash
grep 'APP_VERSION=' ~/openclaw_ultimate_setup/setup_ultimate.sh
git -C ~/openclaw_ultimate_setup show origin/main:setup_ultimate.sh | grep 'APP_VERSION='
```

Wenn beide Werte gleich sind, dann stimmt die Version im Repository mit der Version auf GitHub überein.

## 6. Häufigster Fehler

Der häufigste Denkfehler ist:

- eine Codex-Worktree-Kopie ansehen
- aber die Ubuntu-Laufzeitkopie oder die Windows-Hauptkopie aktualisieren

Dann wirken Versionsanzeigen, Dateien und Menüs widersprüchlich, obwohl nur unterschiedliche Arbeitskopien betrachtet werden.

## 7. Empfehlung für den Alltag

Arbeite künftig nach diesem Muster:

1. `origin/main` als offizielle Quelle behandeln
2. Windows-Hauptkopie als lokale Referenz behalten
3. Ubuntu- oder WSL-Kopie als Laufzeitkopie verwenden
4. Codex-Worktrees nur als temporäre Bearbeitungskopien ansehen

## 8. Wenn etwas komisch wirkt

Dann diese drei Befehle zuerst prüfen:

```bash
git status
git branch -vv
git rev-parse HEAD
```

Und danach:

```bash
git fetch origin --prune
git rev-parse origin/main
git show origin/main:setup_ultimate.sh | grep 'APP_VERSION='
```

Damit lässt sich fast immer schnell erkennen, ob das Problem:

- im lokalen Arbeitsbaum
- im Branch-Zustand
- oder wirklich im GitHub-Stand liegt

## 9. Repository von Ubuntu nach Windows sichern

Ja, das ist moeglich und in WSL oft sogar sinnvoll.

Typischer Windows-Zielpfad aus Ubuntu/WSL heraus:

```bash
/mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/
```

### Repo inklusive `.git` nach Windows kopieren

Damit sicherst du den kompletten Repository-Zustand und kannst ihn spaeter wieder nach Ubuntu zurueckspielen:

```bash
mkdir -p /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_repo_backup
rsync -a --delete ~/openclaw_ultimate_setup/ /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_repo_backup/
```

Wenn `rsync` nicht installiert ist:

```bash
sudo apt-get update
sudo apt-get install -y rsync
```

### Nur die Dateien ohne `.git` sichern

Das ist eher eine Inhaltskopie, aber keine saubere Git-Kopie:

```bash
mkdir -p /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_repo_files_only
rsync -a --delete --exclude '.git' ~/openclaw_ultimate_setup/ /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_repo_files_only/
```

## 10. Benutzer-Workspace separat sichern

Wichtig:

- das Repository allein reicht nicht aus, wenn du auch sensible und bearbeitete Benutzerdaten behalten willst
- diese liegen in `~/.openclaw_ultimate_user_data`

Deshalb bei Bedarf separat sichern:

```bash
mkdir -p /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_user_workspace_backup
rsync -a --delete ~/.openclaw_ultimate_user_data/ /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_user_workspace_backup/
```

## 11. Von Windows nach Ubuntu zurueckspielen

Wenn du spaeter von Windows aus zurueck nach Ubuntu oder WSL spielen willst:

### Repository zurueckkopieren

```bash
rm -rf ~/openclaw_ultimate_setup
mkdir -p ~/openclaw_ultimate_setup
rsync -a /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_repo_backup/ ~/openclaw_ultimate_setup/
```

### Benutzer-Workspace zurueckkopieren

```bash
mkdir -p ~/.openclaw_ultimate_user_data
rsync -a /mnt/c/Users/BENUTZERNAME/Documents/GitHub/Codex/openclaw_user_workspace_backup/ ~/.openclaw_ultimate_user_data/
```

## 12. Danach unbedingt Recovery-Befehle ausfuehren

Wenn du den Windows-Stand nach Ubuntu zurueckgespielt hast und wieder auf GitHub abgleichen willst:

```bash
cd ~/openclaw_ultimate_setup
git status
git branch -vv
git fetch origin --prune
git checkout main 2>/dev/null || git checkout -b main --track origin/main
```

### Wenn der kopierte Stand exakt erhalten bleiben soll

Dann **nicht** sofort hart zuruecksetzen, sondern erst pruefen:

```bash
git diff
```

### Wenn du ihn wieder exakt auf GitHub-Stand bringen willst

```bash
git reset --hard origin/main
git clean -fd
```

## 13. Empfohlener Praxisweg

Am saubersten ist meist dieser Ablauf:

1. Ubuntu- oder WSL-Repo nach Windows sichern
2. Benutzer-Workspace separat nach Windows sichern
3. bei Problemen Ubuntu-Kopie aus Windows zurueckspielen
4. danach gezielt entscheiden:
   - Zustand exakt behalten
   - oder hart gegen `origin/main` bereinigen

So kannst du jederzeit:

- einen funktionierenden Arbeitsstand konservieren
- sensible Benutzerdaten getrennt halten
- und trotzdem spaeter wieder sauber mit GitHub synchronisieren
