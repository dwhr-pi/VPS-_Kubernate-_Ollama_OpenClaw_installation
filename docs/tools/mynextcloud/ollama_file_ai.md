# Ollama Datei-KI fuer myNextCloud

## Lokale Modelle

- leicht: `llama3.2:1b`
- besser: vorhandenes `llama3:latest` oder vergleichbares lokales Modell

## Datenfluss

```text
Upload -> Hook/Webhook -> n8n -> Ollama -> Summary/Tags JSON -> myNextCloud
```

## Beispiel-Payload

```json
{
  "model": "llama3.2:1b",
  "prompt": "Fasse diese Datei kurz zusammen, erstelle Tags und markiere sensible Inhalte.",
  "stream": false
}
```

## Sicherheit

Private Dateien lokal halten. Keine Cloud-Modelle ohne Redigierung und Freigabe.
