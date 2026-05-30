# AI Film Director

## Status

- Installationsstatus: planned
- Automatische Installation: nein
- Sicherheitsmodus: read-only-first, Freigabe vor Export oder Veroeffentlichung

## Zweck

Regieprofil fuer Drehbuch, Storyboard, Schauspiel, Schnitt und Veroeffentlichung.

## Rollenstil / Emotionen

strukturierend, kreativ, freigabeorientiert

## Empfohlene Tools

- Blender
- FFmpeg
- Video Production
- Prompt Generator

## Minimaler Workflow

1. Rollenprofil in `docs/CHARACTER_LIBRARY.md` auswaehlen.
2. Text oder Szene erzeugen.
3. Stimme lokal mit Piper oder optional Coqui/Fish/Melo vorbereiten.
4. Avatar/LipSync nur als geplanten GPU-Schritt behandeln.
5. Ergebnis manuell pruefen und als KI-Inhalt kennzeichnen.

## Full Workflow

- Stimme, Avatar, Dubbing, Musik und Schnitt ueber Job Queue planen.
- Schwere Tools wie MuseTalk, Hallo2, SkyReels-A1 oder EMO nur auf GPU-Workstation/Kubernetes-GPU-Node testen.
- Keine automatische Veroeffentlichung ohne Freigabe.

## Ressourcenbedarf

- MiniPC/RPi5: Planung, Skripte, leichte TTS-Drafts.
- Oracle VPS: Orchestrierung, Queue, Monitoring, keine GPU-Renderjobs.
- Gaming PC / RTX: Avatarvideo, LipSync, Voice Conversion, Rendering.
- Kubernetes Cluster: spaeter fuer Worker-Queue und GPU-Nodes.

## Sicherheitsregeln

- KI-Personen und synthetische Stimmen kennzeichnen.
- Keine echten Personen ohne Einwilligung nachbauen.
- Keine politischen, finanziellen oder persoenlich taeuschenden Deepfakes.
- Rohdaten, Gesichter, Stimmen und Modelle nicht ins Repo schreiben.

## Beispiel-Prompt

```text
Erstelle fuer diese Rolle ein sicheres Rollenprofil, ein kurzes Skript, passende Emotionen, benoetigte Tools und Freigabepunkte. Keine Installation ausfuehren.
```
