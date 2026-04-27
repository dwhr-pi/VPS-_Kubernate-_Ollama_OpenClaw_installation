# Profil: Texter_Werbung_Marketing

## Überblick

Dieses Profil fokussiert im aktuellen Repo-Stand vor allem Workflow-Automatisierung.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`
- Profil-Tooling:
  - n8n unter `/opt/n8n`
  - Activepieces unter `/opt/activepieces`

## Verantwortlichkeiten

- Content-nahe Workflows
- Marketing-Automatisierung
- Integrationen zwischen Diensten

## Verfügbare Kommandos

```bash
scripts/tools/n8n_install.sh
scripts/tools/activepieces_install.sh
```

## Vergleich

### ✅ In Sync

- n8n und Activepieces sind sowohl dokumentiert als auch script-seitig umgesetzt.

### ⚠ Missing in Setup

- Keine SEO-Tools
- Kein Social-Media-Management
- Keine dedizierten Textmodelle oder Copywriting-Agenten

### ❌ Missing in Docs

- Keine dedizierte Profil-Datei im ursprünglichen Repo

## Hinweise

- n8n nutzt standardmäßig Port `5678`.
- Activepieces nutzt standardmäßig Port `3000` und kollidiert potenziell mit OpenClaw und weiteren Diensten.
