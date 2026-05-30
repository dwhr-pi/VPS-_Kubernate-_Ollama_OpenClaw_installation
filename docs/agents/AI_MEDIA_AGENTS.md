# AI Media Production Agents

## Agenten
- NewsAnchorAgent
- ModeratorAgent
- ActorAgent
- VoiceDirectorAgent
- CastingAgent
- DubbingAgent
- PodcastAgent
- DocumentaryAgent
- AudiobookAgent
- FilmDirectorAgent

## Gemeinsame Regeln
- Keine echten Personen ohne Einwilligung nachbauen.
- KI-Inhalte kennzeichnen.
- Keine automatische Veroeffentlichung.
- Schwere Jobs ueber Job Queue.
- Rohdaten und Modelle ausserhalb des Repos speichern.

## Beispiel-Agent
```json
{
  "name": "NewsAnchorAgent",
  "provider": "ollama",
  "mode": "local",
  "permissions": {
    "publish": false,
    "shell": "dry-run-first"
  },
  "rules": [
    "Quellen nennen",
    "KI-Sprecher kennzeichnen",
    "Freigabe vor Export"
  ]
}
```

