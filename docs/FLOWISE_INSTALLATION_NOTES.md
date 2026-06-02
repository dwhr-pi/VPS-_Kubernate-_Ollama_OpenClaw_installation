# Flowise Installation Notes

## Warum fragt Git nach einem GitHub-Username?

Bei Flowise ist kein GitHub-Login noetig, solange die richtige oeffentliche Quelle verwendet wird:

```text
https://github.com/FlowiseAI/Flowise.git
```

Die alte/falsche Quelle

```text
https://github.com/FlowiseAI/FlowiseChatbot.git
```

ist nicht oeffentlich erreichbar und fuehrt bei `git clone` zu einer GitHub-Username-/Passwortabfrage. GitHub akzeptiert Passwort-Authentifizierung fuer Git ohnehin nicht mehr; fuer oeffentliche Tools soll das Setup deshalb gar nicht nach Credentials fragen.

## Sicherer Setup-Pfad

Der Installer verwendet jetzt:

```bash
GIT_TERMINAL_PROMPT=0 git clone https://github.com/FlowiseAI/Flowise.git /opt/flowise
```

Dadurch bricht der Clone bei falscher URL sauber ab, statt interaktiv nach Username oder Token zu fragen.

## Abgebrochener Clone und `ERR_PNPM_NO_PKG_MANIFEST`

Wenn der alte Installer bereits gelaufen ist, kann ein leerer oder unvollstaendiger Ordner liegen bleiben:

```text
/opt/flowise
```

Dann findet `pnpm install` keine `package.json` und meldet:

```text
ERR_PNPM_NO_PKG_MANIFEST No package.json found
```

Der neue Installer nutzt die zentrale Git-Reparaturlogik. Ein leerer oder unvollstaendiger Zielordner wird nicht blind geloescht, sondern unter

```text
~/.openclaw_ultimate_user_data/setup_repair_backups/
```

gesichert. Danach wird Flowise erneut aus der korrekten GitHub-Quelle geklont.

Wenn du einen kaputten Ordner bewusst selbst entfernen willst:

```bash
sudo rm -rf /opt/flowise
```

Das ist aber nicht mehr der Standardpfad des Installers.

## Ressourcenhinweis

Flowise ist ein Node/pnpm-Projekt.

| Bereich | Empfehlung |
| --- | --- |
| Node.js | Node 20.x erforderlich; Node 18 fuehrt zu `Unsupported engine` und darf nicht fuer den Build genutzt werden |
| pnpm | Muss zur Node-20-Umgebung passen |
| RAM | 4 GB Minimum, 8 GB+ empfohlen |
| Speicher | mindestens 8 GB Linux-/WSL-Speicher fuer Repository, pnpm-Cache und Build |
| Windows/WSL2 | mindestens 20 GB freier Windows-C:-Speicher empfohlen, falls die WSL-Distro auf C: liegt |
| Ports | Flowise typischerweise lokal binden und nur ueber Auth/Reverse Proxy freigeben |

Der Installer prueft diese Werte vor dem Build. Wenn Node 18.x gefunden wird, bricht er bewusst ab, weil Flowise aktuell Node 20.x erwartet und der Build sonst erst nach langer Laufzeit fehlschlagen oder beendet werden kann.

Wenn eine passende Node-20-Installation bereits separat vorhanden ist:

```bash
FLOWISE_NODE_BIN=/pfad/zu/node20 bash scripts/tools/flowise_install.sh
```

Nur fuer bewusste Tests kann die Node-Pruefung uebergangen werden:

```bash
FLOWISE_ALLOW_NODE_MISMATCH=true bash scripts/tools/flowise_install.sh
```

Das wird nicht empfohlen, weil genau dadurch lange Builds mit spaetem Abbruch entstehen koennen.

Unter WSL2 kann die Windows-C:-Pruefung nur bewusst uebersprungen werden:

```bash
FLOWISE_SKIP_WINDOWS_DISK_CHECK=true bash scripts/tools/flowise_install.sh
```

## Sicherheitsregel

Keine GitHub-Zugangsdaten eingeben, wenn ein oeffentliches Tool geklont werden soll. Eine Username-Abfrage bedeutet hier fast immer: falsche URL, privates Repo, Netzwerkproblem oder veralteter Installer.
