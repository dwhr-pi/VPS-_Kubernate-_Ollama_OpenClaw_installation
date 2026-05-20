# Beispiel: IFC Analyse Workflow

1. IFC-Datei unter `architecture/ifc/input/` ablegen.
2. IFCOpenShell oder Bonsai liest Raeume, Geschosse, Bauteile und Property Sets.
3. OpenClaw ruft den BIM-Analysten auf.
4. Bericht wird unter `architecture/reports/ifc_report_YYYYMMDD.md` gespeichert.
5. Nutzer prueft Auffaelligkeiten, bevor CAD/BIM-Dateien geaendert werden.

Beispielprompt:

```text
Analysiere den IFC-Export. Markiere fehlende Raumfunktionen, fehlende Mengen und Bauteile ohne Material.
```

