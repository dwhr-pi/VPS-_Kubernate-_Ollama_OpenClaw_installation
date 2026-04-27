# Profil: KI_Forschung

## Überblick

Dieses Profil richtet sich an RL- und LLM-Experimentier-Workflows.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `python3-venv`
- Profil-Tooling:
  - OpenClaw RL unter `/opt/openclaw-rl`
  - Flowise unter `/opt/flowise`
  - LangFlow unter `/opt/langflow`

## Verantwortlichkeiten

- Reinforcement-Learning-Experimente
- visuelle LLM-Workflow-Erstellung
- OpenClaw-nahe Forschung und Prototyping

## Verfügbare Kommandos

```bash
scripts/tools/openclaw_rl_install.sh
scripts/tools/flowise_install.sh
scripts/tools/langflow_install.sh
```

## Vergleich

### ✅ In Sync

- OpenClaw RL ist sauber im Profil verankert.
- Flowise und LangFlow sind sowohl in Doku als auch im Profilskript vorgesehen.

### ⚠ Missing in Setup

- Kein automatisches `gemini-1.5-pro`-Setup
- Keine breitere ML-Bibliotheksauswahl wie TensorFlow oder PyTorch

### ❌ Missing in Docs

- Keine dedizierte Profil-Datei im ursprünglichen Repo

## Hinweise

- Flowise nutzt standardmäßig Port `3000`.
- LangFlow nutzt standardmäßig Port `7860`.
- Port-3000-Kollisionen mit OpenClaw, Huginn, Activepieces und Zenbot sind wahrscheinlich.
