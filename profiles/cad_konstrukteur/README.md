# CAD_Konstrukteur

Lokaler Arbeitsbereich fuer den CAD-Konstrukteur-Agenten des Ultimate KI Setups.

## Inhalt

- `prompts/cad_system_prompt.md`: Systemprompt fuer OpenClaw/Ollama.
- `examples/freecad_box_example.py`: parametrisches FreeCAD-Gehaeuse.
- `examples/cadquery_mount_example.py`: einfache CadQuery-Montageplatte.
- `examples/openscad_case_example.scad`: parametrisches OpenSCAD-Gehaeuse.

## Erste Pruefung

```bash
bash scripts/install/install_cad_tools.sh
bash scripts/check/check_cad_tools.sh
```

Die Beispiele sind als Startpunkte gedacht. Vor echtem Einsatz immer Masse, Toleranzen, Material und Belastung pruefen.
