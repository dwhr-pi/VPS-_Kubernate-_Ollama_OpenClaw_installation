# Resource And Cost Control

## Zweck

Diese Datei hilft dabei, lokale Ressourcen und optionale Cloud-Kosten im Blick zu behalten.

## Lokal prüfen

```bash
bash scripts/resource_estimator.sh
```

## Was geprüft wird

- freier Festplattenplatz
- RAM-Basis
- Docker-Volume-Größen
- vorhandene Ollama-Modelle
- GPU-/VRAM-Hinweise

## Typische Empfehlungen

- **MiniPC / WSL2:** schwere Bild-/Video-Profile nur bewusst installieren
- **VPS / K3s:** Monitoring-, Data- und Gateway-Profile eher auslagern
- **GPU-Workstation:** ComfyUI, Forge, SVD, Whisper/faster-whisper deutlich sinnvoller

## Cloud-/API-Kosten

Das Repository setzt grundsätzlich auf lokal und kostenlos als Standard.

Optional kostenpflichtig können je nach Nutzung sein:

- Gemini / OpenAI / Anthropic / OpenRouter
- Cloudflare-Tunnel- oder Zusatzdienste
- größere VPS/Storage-Tarife

Regel:

- niemals versteckte Cloud-Kosten voraussetzen
- jede Cloud- oder API-Nutzung bewusst in der Doku kennzeichnen
