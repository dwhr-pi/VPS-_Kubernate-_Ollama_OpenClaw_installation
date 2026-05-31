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

Der neue Installer bricht in diesem Fall vor `pnpm install` ab und fordert zur manuellen Pruefung auf. Wenn der Ordner wirklich nur ein kaputter Clone-Rest ist, kann er manuell entfernt werden:

```bash
sudo rm -rf /opt/flowise
```

Danach den Installer erneut starten.

## Ressourcenhinweis

Flowise ist ein Node/pnpm-Projekt.

| Bereich | Empfehlung |
| --- | --- |
| RAM | 4 GB Minimum, 8 GB+ empfohlen |
| Speicher | mehrere GB fuer Repository, pnpm-Cache und Build |
| Windows/WSL2 | Windows-C:-Speicher beachten |
| Ports | Flowise typischerweise lokal binden und nur ueber Auth/Reverse Proxy freigeben |

## Sicherheitsregel

Keine GitHub-Zugangsdaten eingeben, wenn ein oeffentliches Tool geklont werden soll. Eine Username-Abfrage bedeutet hier fast immer: falsche URL, privates Repo, Netzwerkproblem oder veralteter Installer.
