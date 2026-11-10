# Migration auf den neuen GitHub-Namen

Das offizielle GitHub-Repository heisst jetzt
[OpenClaw-AI_Infrastructure-_Ultimate_Setup](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup).
Der sichtbare Projekttitel lautet **OpenClaw & AI Infrastructure - Ultimate Setup**.
Der alte Name in historischen Berichten und Archivbefehlen bleibt als Quellenangabe erhalten.
Alte GitHub-Weiterleitungen sind kein Ersatz fuer die lokale Origin- oder Signaturpruefung.

## Windows und verknuepfte Worktrees

Keine Ordner im Explorer umbenennen, keinen Checkout neu anlegen. Im bereits
bekannten Hauptcheckout zuerst `git status --short --branch` und
`git remote -v` pruefen. Nur fuer das offizielle Original-Repository:

```bash
git remote set-url origin https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup.git
git remote -v
git ls-remote --exit-code origin refs/heads/main
```

Verknuepfte Worktrees teilen die Remote-Konfiguration, nicht ihren Branch
oder Dateistand. Ein abweichender Push-URL oder ein Fork ist getrennt zu
pruefen; den Fork-Origin nicht durch den Original-Origin ersetzen.
GitHub Desktop weiter mit dem vorhandenen lokalen Ordner verwenden.

## Bestehende Installationen und GitOps

1. Erst nach erfolgreicher CI und Uebernahme der Migration einen geprueften
   Stand fuer die getrennten Linux-/WSL-/VPS-Checkouts waehlen. Lokale
   Aenderungen und den bestehenden Remote pruefen und den Checkout sichern.
2. Das gepruefte Bootstrap-Verfahren und den neuen Remote als Einheit
   umstellen: Alte Skripte koennen den neuen Namen absichtlich ablehnen.
   Bei sauberem, nachvollziehbarem Branch nur Fast-forward auf den geprueften
   Commit. Kein Reset, Clean, Neuinstallieren oder Loeschen von
   `~/.openclaw_ultimate_user_data`.
3. Bei Argo CD Repository-Verbindungen, AppProject-Allowlist und
   Application-Quellen gemeinsam pruefen. Nicht automatisch synchronisieren,
   Controller neu starten oder Staging/Produktion deployen.
4. Fuer den [Markdown-Server](tools/markdown-docs-server.md) einen neuen,
   geprueften Commit verwenden. Bereits eingerichtete Snapshots nicht
   manuell aendern oder ausraeumen.

## Minisign und Rueckweg

Der neue [Release-Vertrag](SIGNED_RELEASES.md) verlangt den exakten neuen
Repository-Namen in den signierten Metadaten. Bereits signierte Altdateien
nicht umschreiben. Neue Releases aus dem geprueften Migrationsstand
exportieren und mit unabhaengigem Schluessel pruefen; kein automatischer
Altpfad bei einer fehlgeschlagenen Pruefung. Diese Migration publiziert
kein Release und aendert keine Schluessel.

Bei Problemen zuerst die betroffene Arbeitskopie, den Branch und den
Remote pruefen. Die lokale Migrationsaenderung laesst sich ueber Git
nachvollziehen, ohne Benutzerdateien oder installierte Tools anzutasten.
