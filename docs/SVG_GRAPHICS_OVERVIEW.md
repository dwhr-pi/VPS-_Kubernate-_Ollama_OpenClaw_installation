# SVG-Grafikübersicht

Diese Seite sammelt alle im Repository verwendeten `.svg`-Grafiken. Sie dient als zentrale Prüfliste für Architekturdiagramme, Icons, Logos, Profilgrafiken und Setup-Abbildungen.

## Aktueller Stand

Derzeit sind im Repository keine `.svg`-Dateien vorhanden.

Prüfbefehl:

```bash
rg --files -g "*.svg"
```

## Empfohlene Eintragung je SVG

Wenn später SVG-Dateien ergänzt werden, sollten sie hier mit folgenden Angaben dokumentiert werden:

| Datei | Verwendung | Eingebunden in | Status | Hinweis |
| --- | --- | --- | --- | --- |
| - | - | - | - | Noch keine SVG-Dateien vorhanden |

## Qualitätsregeln

- SVGs sollen keine eingebetteten Secrets, Tokens, privaten URLs oder personenbezogenen Daten enthalten.
- Externe Bild- oder Font-Referenzen sollten vermieden oder klar dokumentiert werden.
- Für Architekturdiagramme bevorzugt `docs/architecture/` verwenden.
- Für Profil- oder Feature-Grafiken bevorzugt den jeweiligen Profil- oder Doku-Ordner verwenden.
- Vor dem Commit prüfen, ob die SVG-Dateien wirklich benötigt werden und keine unnötig großen exportierten Editor-Metadaten enthalten.

## Pflegehinweis

Nach dem Hinzufügen neuer SVG-Dateien:

```bash
rg --files -g "*.svg"
rg -n "\\.svg" README.md docs config scripts stacks
```

Die Treffer anschließend in der Tabelle oben eintragen.
