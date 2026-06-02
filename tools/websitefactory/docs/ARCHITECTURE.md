# WebsiteFactory Architektur

## Pipeline

1. CLI oder OpenClaw sammelt Briefing-Daten.
2. Briefing wird normalisiert und mit Defaults angereichert.
3. Standardprovider ist Ollama unter `http://127.0.0.1:11434`.
4. Generator erzeugt ein Astro/Tailwind-Projekt.
5. Queue-Worker verarbeitet immer nur einen Job gleichzeitig.
6. Build- und Preview-Skripte pruefen das Ergebnis.
7. Reports landen im Projekt unter `docs/build-report.md`.

## Komponenten

- `src/cli.mjs`
- `src/generate-site.mjs`
- `src/providers/ollama.mjs`
- `src/queue-store.mjs`
- `src/queue-worker.mjs`
- `jobs/queue.json`

## Schutzlogik

- Lockfile fuer nur einen Worker
- RAM-/Load-Pruefung
- maximal 3 Korrekturrunden vorgesehen
- keine Cloud-Pflicht
