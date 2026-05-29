# AutoGPT Build Troubleshooting

Diese Seite erklaert haeufige AutoGPT-Buildfehler im Ultimate KI Setup.

## Aktueller Fehler: Frontend `pnpm build`

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
