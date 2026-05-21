# Boardroom fuer Ultimate KI Setup

Dieses Modul adaptiert eine Boardroom-Idee fuer ein lokales Setup mit **Ollama + OpenClaw**.

Ziel ist eine strategische Entscheidungsrunde mit fuenf unabhaengigen Rollen:

1. **CFO** - Kosten, ROI, Cashflow, Risiko
2. **Operator** - Umsetzung, Prozesse, Skalierbarkeit
3. **Vertriebler** - Kundenreaktion, Markt, Pricing, Pitch
4. **Mentor** - Erfahrung, Langzeitfolgen, Mustererkennung
5. **Skeptiker** - versteckte Risiken, Worst Case, Annahmenpruefung

Danach erfolgen anonymisiertes Peer-Review und ein finales Chairman-Verdict.

## Anpassung gegenueber Claude-Version

Entfernt oder ersetzt wurden:

- `CLAUDE.md` als Pflicht-Kontext
- Claude Code / Claude Cowork Installationslogik
- Claude-Skill-spezifische Triggerbeschreibung
- Toolnamen wie `Glob` und `Read` als Claude-spezifische Annahmen

Ersetzt durch:

- OpenClaw-/Ollama-kompatibles Rollenprofil
- optionaler Projektkontext aus `docs/Profile/`, `docs/Profil/`, `memory/`, `README.md`, `.env.example`, Setup-Skripten und frueheren Boardroom-Protokollen
- lokaler Betrieb mit einem oder mehreren Ollama-Modellen

## Dateien

```text
docs/Profile/Boardroom.md
profiles/boardroom/prompts/codex_integrate_boardroom.md
skills/boardroom/SKILL.md
```

## Trigger

- `Boardroom rufen`
- `Boardroom fragen`
- `Lass das Boardroom entscheiden`
- `Stress-test das`
- `Pressure-test das`
- `Lass CFO, Operator, Vertrieb, Mentor und Skeptiker pruefen`

## Wann nutzen?

Gut geeignet fuer:

- Tool-Auswahl im KI-Setup
- VPS/Kubernetes/Ollama/OpenClaw-Architekturentscheidungen
- Kosten-/Nutzen-Abwaegungen
- Automatisierung vs. manuelle Umsetzung
- Security-/Privacy-Entscheidungen
- Produkt-, Marketing-, Musik-, Video- oder App-Projektentscheidungen

Nicht ideal fuer:

- einfache Faktenfragen
- reine Zusammenfassungen
- reine Schreibauftraege ohne Entscheidung
- Aufgaben mit genau einer objektiv richtigen Antwort
