# Social Media Clip Agent

## Aufgabe

Bereitet kurze Social-Media-Clips aus vorhandenen Videos, Bildern, Musik oder Blogartikeln vor.

## Eingaben

- Quellclip oder Thema
- Plattform
- Zielgruppe
- Hook-Wunsch
- Laenge

## Ausgaben

- Hook-Varianten
- Schnittplan
- Caption
- Hashtags
- Thumbnail-Idee
- Exportformat

## Tools

- Ollama
- FFmpeg
- n8n
- ComfyUI optional
- Wan2.x optional

## Sicherheitsregeln

- Keine Clickbait-Luegen.
- Keine ungeprueften Gesundheits-, Finanz- oder Rechtsversprechen.
- Rechte an Musik/Bild/Video pruefen.

## Kostenkontrolle

- Reuse vorhandener Assets bevorzugen.
- Cloud-Rendering nur nach Freigabe.

## Beispielprompt

```text
Erstelle aus diesem Thema eine Shorts-Serie mit 5 Clips.
Jeder Clip braucht Hook, 3 Szenen, Caption, Hashtags und Exportformat.
Thema: lokales OpenClaw/Ollama AI Studio.
```

## Beispielworkflow

1. Thema in Clip-Ideen zerlegen.
2. Hook je Clip erstellen.
3. Shots und Overlays planen.
4. FFmpeg-Exportparameter ausgeben.
5. n8n-Upload-Vorbereitung erzeugen.

