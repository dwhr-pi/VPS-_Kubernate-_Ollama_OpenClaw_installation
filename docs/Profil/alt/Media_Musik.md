# Profil: Media_Musik

## Überblick

Dieses Profil ist dokumentiert als Medien- und Musikprofil, wird script-seitig aktuell aber nur sehr schlank umgesetzt.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`
- Profil-Tooling:
  - Clawbake unter `/opt/clawbake`

## Verantwortlichkeiten

- Build- und Deployment-Unterstützung für kreative oder mediennahe Workflows

## Verfügbare Kommandos

```bash
scripts/tools/clawbake_install.sh
```

## Vergleich

### ✅ In Sync

- Clawbake ist vorhanden und im Profilskript verankert.

### ⚠ Missing in Setup

- Kein `ffmpeg`
- Keine Audio-AI-Tools
- Keine Video-Generatoren
- Keine direkte Alexa-Integration aus dem Profil heraus

### ❌ Missing in Docs

- Es gibt keine dedizierte Profil-Markdown-Datei im ursprünglichen Repo.

## Hinweise

- Das Profil wirkt aktuell eher wie ein Platzhalter mit einem einzelnen Tool als wie ein vollständiges Medienprofil.
