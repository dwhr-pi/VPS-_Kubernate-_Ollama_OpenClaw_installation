# Troubleshooting Ollama

## Verbindung abgelehnt

Fehler:

```text
connection refused 127.0.0.1:11434
```

Pruefen:

```bash
ollama --version
curl http://127.0.0.1:11434/api/tags
```

## Dienst laeuft nicht

Linux/systemd:

```bash
systemctl status ollama --no-pager
```

WSL2 ohne systemd:

```bash
ollama serve
```

## Modelle brauchen zu viel Speicher

- Kleine Modelle fuer Einstieg: 3B bis 7B.
- Grosse Modelle nur mit genug RAM/VRAM.
- Modellcache kann viele GB belegen.

## Externe API statt lokalem Modell

Wenn ein Tool unerwartet externe Provider nutzt:

- `.env` pruefen.
- API-Keys entfernen oder deaktivieren.
- LiteLLM/OpenRouter-Konfiguration pruefen.
- Kostenwarnungen im Setup beachten.

