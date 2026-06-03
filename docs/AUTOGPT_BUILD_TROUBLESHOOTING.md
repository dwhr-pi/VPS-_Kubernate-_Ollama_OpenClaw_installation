# AutoGPT Build Troubleshooting

Diese Seite erklaert haeufige AutoGPT-Buildfehler im Ultimate KI Setup.

## Preflight: Speicherplatz und RAM

Der AutoGPT-Installer prueft vor dem grossen Docker-Build und vor
`docker compose up -d` jetzt automatisch:

- freier Linux-/WSL-Speicher
- freier Windows-C:-Speicher unter WSL
- freier Speicher im Docker-Root-Verzeichnis
- verfuegbarer RAM plus Swap
- Docker-Speicheruebersicht mit `docker system df`

Standard-Mindestwerte:

| Ressource | Mindestwert | Empfehlung |
| --- | ---: | ---: |
| Linux-/WSL-Speicher | 40960 MB | 81920 MB oder mehr |
| Windows C: unter WSL | 51200 MB | 81920 MB oder mehr |
| Docker-Root-Speicher | 40960 MB | 81920 MB oder mehr |
| RAM plus Swap | 8192 MB | 12288 MB oder mehr |

Warum so streng? AutoGPT baut viele Docker-Images und startet danach mehrere
Dienste wie RabbitMQ, Redis, Supabase, Frontend und Worker. Ein Build kann
scheinbar erfolgreich sein, waehrend RabbitMQ oder ein anderer Dienst direkt
danach wegen Speicher-, Volume- oder I/O-Problemen beendet wird.

Nur fuer bewusste Tests kann die Pruefung uebersprungen werden:

```bash
AUTOGPT_SKIP_RESOURCE_PREFLIGHT=1 bash scripts/tools/autogpt_install.sh
```

Das wird nicht empfohlen, wenn Windows C:, Docker-Speicher oder RAM bereits
knapp sind.

## Aktueller Fehler: RabbitMQ startet nach erfolgreichem Build nicht

Typisches Logmuster:

```text
frontend DONE
Container rabbitmq Error
dependency failed to start: container rabbitmq exited (1)
```

In diesem Fall ist der lange Docker-Build sehr wahrscheinlich nicht am
Frontend gescheitert. Die Images wurden gebaut, aber `docker compose up -d`
konnte die Plattform nicht starten, weil RabbitMQ als Abhaengigkeit beendet
wurde.

## Diagnose fuer RabbitMQ

Im AutoGPT-Plattformverzeichnis ausfuehren:

```bash
cd /opt/autogpt/autogpt_platform
docker compose ps rabbitmq
docker compose logs --tail=200 rabbitmq
docker compose ps
docker system df
```

Wenn Docker nur mit `sudo` nutzbar ist:

```bash
cd /opt/autogpt/autogpt_platform
sudo docker compose ps rabbitmq
sudo docker compose logs --tail=200 rabbitmq
sudo docker compose ps
sudo docker system df
```

Hauefige Ursachen:

- zu wenig freier Docker-/WSL-/Windows-C:-Speicher
- korrupte oder alte RabbitMQ-Volumes nach einem abgebrochenen Start
- Portkonflikte bei `5672` oder `15672`
- zu wenig RAM/Swap waehrend mehrere AutoGPT-Container gleichzeitig starten
- RabbitMQ-Konfigurations- oder Cookie-Probleme im Upstream-Compose-Setup

Wichtig: Volumes nicht blind loeschen. Erst Logs pruefen und Backups beachten,
weil Laufzeitdaten verloren gehen koennen.

## Fehler: Frontend `pnpm build`

Typisches Logmuster:

```text
[frontend build 4/4] RUN ... pnpm build
Compiled with warnings
Linting and checking validity of types ...
ELIFECYCLE Command failed with exit code 1
target frontend: failed to solve
```

Wenn vorher mehrere Images wie `rest_server`, `executor`, `scheduler_server`,
`notification_server` oder `database_manager` erfolgreich exportiert wurden,
dann funktionieren Docker und BuildKit grundsaetzlich. Der Abbruch liegt dann
sehr wahrscheinlich im AutoGPT-Frontend-Build.

## Was ist wahrscheinlich nicht die Ursache?

### Prisma/Python/Pip-Warnungen

Meldungen wie:

```text
Generated Prisma Client Python
Running pip as root
gen-prisma-stub ... not installed as a script
```

stammen aus dem Container-Build. Sie sind allein normalerweise nicht der finale
Abbruch.

### Edge Runtime Warnungen

Meldungen wie:

```text
A Node.js API is used ... not supported in the Edge Runtime
```

koennen im Next.js/Supabase-Kontext als Warnungen erscheinen. Im gezeigten Log
ist der finale Abbruch spaeter `ELIFECYCLE`.

### Git Commit Metadaten

Meldungen wie:

```text
current commit information was not captured
git rev-parse --is-inside-work-tree
```

sind meistens Docker/Git-Metadatenwarnungen und nicht der eigentliche Fehler.

## Naechste manuelle Diagnose

Im AutoGPT-Plattformverzeichnis ausfuehren:

```bash
cd /opt/autogpt/autogpt_platform
DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker compose build frontend --progress=plain
```

Wenn Docker nur mit `sudo` nutzbar ist:

```bash
cd /opt/autogpt/autogpt_platform
sudo env DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker compose build frontend --progress=plain
```

Wichtig: Die entscheidenden Zeilen stehen meistens direkt vor dem finalen
`ELIFECYCLE`-Fehler.

## Ressourcenhinweis

Der Frontend-Build kann sehr lange laufen und nutzt:

- viel RAM
- viel CPU
- viel Docker-Speicher
- Node mit `--max-old-space-size=8192`

Unter WSL sollte vor AutoGPT ausreichend Windows-C:-Speicher und Linux-/WSL-
Speicher frei sein. Wenn das System waehrend `Linting and checking validity of
types` sehr lange haengt, kann auch Ressourcenknappheit oder I/O-Druck beteiligt
sein.

## Mögliche Workarounds

Diese Punkte sind bewusst nicht automatisch aktiviert:

- AutoGPT-Upstream aktualisieren und erneut bauen.
- Frontend separat mit `--progress=plain` bauen, um den echten TypeScript- oder
  Next.js-Fehler zu sehen.
- Wenn Upstream eine Build-Option fuer Type-Checking/Linting anbietet, nur nach
  Review nutzen.
- Bei wiederholtem Fehlschlag AutoGPT als `experimental/heavy` markieren und im
  Batch ueberspringen.

## Setup-Verhalten

Der Installer erkennt jetzt typische Frontend-Buildmuster und erklaert:

- BuildKit-Fehler
- Frontend/pnpm/ELIFECYCLE-Fehler
- Edge-Runtime-Warnungen
- Git-Metadatenwarnungen

Dadurch soll nach einem langen Build klarer werden, welcher Teil wirklich
fehlgeschlagen ist.
