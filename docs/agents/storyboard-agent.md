# Storyboard Agent

## Aufgabe

Erzeugt aus Text, Songtext, Produktbeschreibung oder Kampagnenidee ein klares Storyboard.

## Eingaben

- Thema oder Briefing
- Stil
- Zielplattform
- Anzahl Szenen
- gewuenschte Emotion

## Ausgaben

- Szenentabelle
- Bildkomposition
- Kamera
- Bewegung
- Prompt pro Szene
- offene Produktionsrisiken

## Tools

- Ollama
- OpenClaw
- Open WebUI optional
- ComfyUI optional

## Sicherheitsregeln

- Keine irrefuehrenden Produktversprechen.
- Personenrechte und Lizenzen pruefen.
- Keine realen Personen imitieren, wenn keine Zustimmung vorliegt.

## Kostenkontrolle

- Storyboard zuerst als Markdown.
- Danach maximal eine Szene als Render-Test.

## Beispielprompt

```text
Erstelle ein Storyboard fuer einen 30-Sekunden-Short.
Ziel: lokales AI Cinema Studio erklaeren.
Ton: modern, glaubwuerdig, nicht uebertrieben.
Format: Tabelle mit Szene, Visual, Motion, Prompt, Risiko.
```

## Beispielworkflow

1. Briefing normalisieren.
2. Szenen in 3-7 Shots aufteilen.
3. Character- und Stilregeln festlegen.
4. ComfyUI-Prompts erzeugen.
5. Renderreihenfolge vorschlagen.

