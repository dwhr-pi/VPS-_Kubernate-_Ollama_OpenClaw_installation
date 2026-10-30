# Beispielkonfiguration fuer ein eigenes Python-Projekt

`pyproject.example.toml` ist eine Vorlage, keine automatisch aktive Konfiguration dieses
Setup-Repositories. Bestehende Projektkonfiguration erst pruefen und Abschnitte bewusst
zusammenfuehren, nicht ueberschreiben.

Black **oder** Ruff als Formatierer waehlen. mypy ergaenzt Tests, ersetzt sie nicht. Beispielbefehle
setzen bereits installierte Werkzeuge voraus:

```bash
python -m pytest tests/
python -m black --check --diff src/ tests/
python -m mypy src/
```

Keine Pakete, Vorschau oder Agenten werden durch diese Dateien gestartet. Anleitung:
[Manus-Entwicklungsablauf](../../docs/tutorials/manus-development-workflow.md).
