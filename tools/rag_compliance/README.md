# RAG Compliance Review: begrenzte Offline-Werkzeuge

Python 3.10+, Standardbibliothek, keine Paket-/Modellinstallation. Dieser
Repository-Prototyp prueft Metadaten und synthetische Dateien; er verbindet
sich nicht mit Datenbanken, LLMs oder Rechtsportalen. **Keine Rechtsfreigabe.**

Vom Repository-Hauptverzeichnis:

```bash
bash scripts/check_rag_compliance.sh
bash scripts/check_rag_compliance.sh doctor --as-of 2026-10-21
bash scripts/check_rag_compliance.sh assess tools/rag_compliance/examples/scenario.json
bash scripts/check_rag_compliance.sh deletion-plan tools/rag_compliance/examples/deletion-plan.json
bash scripts/check_rag_compliance.sh audit-check tools/rag_compliance/examples/audit.json
```

Windows nativ ohne Bash/WSL:

```powershell
py -3 -I -B tools/rag_compliance/review.py doctor
py -3 -I -B tools/rag_compliance/review.py assess tools/rag_compliance/examples/scenario.json
```

`RAG_COMPLIANCE_PYTHON_BIN` waehlt fuer den Shellwrapper ein vorhandenes Python.
Das Setup-Hauptmenue 18 zeigt nur den Doctor. Keine Installed-Marker werden
angelegt. Es braucht keine Deinstallation und es wird nichts automatisch aktiviert.

## Ergebnisgrenzen

### Historische Versionsauswahl

```bash
bash scripts/check_rag_compliance.sh temporal-context tools/rag_compliance/examples/temporal-versions.json --as-of 2025-12-31 --known-on 2026-10-21 --jurisdiction RU --tenant demo --role reviewer
```

`temporal-context` filtert ausschliesslich lokale Versionsmetadaten mit
halb offenen Datumsintervallen, Erfassungsdatum und selbst angegebenen
Mandanten/Rollen. Keine semantische Suche, Authentisierung, automatische
Rechtskonflikterkennung oder Datenbankanbindung. Kein Treffer erweitert den
Suchraum; `insufficient-evidence` bleibt ein technisches Ergebnis mit Exit 0.
Die Beispiele sind erfunden. Details und Aktualisierungskonzept:
[Rechtsaenderungen und Osteuropa](../../docs/legal/TEMPORAL_UPDATES_AND_EASTERN_EUROPE.md).

### Bisherige Befehle

- `doctor`: Quellenfrist und Abdeckung; `within-review-window` bezieht sich
  nur auf einen datierten Ueberblick, nicht auf gesamte Rechtslage oder Produkt.
  `--strict` liefert Exit 1 bei offenen Quellen. Kein automatischer Webabruf.
- `assess`: Selbstauskunft pruefen, fehlende Kontrollnachweise und fachliche
  Themen benennen. Auch bei allen gesetzten Haken bleibt
  `legal_approval=false` und `execution_permitted=false`.
- `deletion-plan`: Nur Mengen und Speicherabdeckung planen. Legal Holds und
  ungepruefte Aufbewahrung blockieren Vorschlaege; nichts wird geloescht.
- `audit-check`: Versionierte kanonische JSON-Hashkette pruefen, niemals neu
  schreiben oder reparieren. Ohne extern bekannten Head/Anzahl ist eine
  Endkuerzung nicht nachweisbar. Optional beide Werte mit `--expected-head`
  und `--expected-count` uebergeben. Herkunft/Echtheit dieser Werte wird durch
  den CLI-Aufruf nicht authentisiert; `authenticity_verified=false` bleibt.

Exit 0 bedeutet standardmaessig erfolgreich ausgefuehrte technische Pruefung,
keine Rechtskonformitaet. Audit-Inkonsistenz/Ankerabweichung oder eine leere
Auditdatei ohne Vergleichswerte liefert Exit 1,
ungueltige Eingabe Exit 2. Eingaben sind auf 2 MiB begrenzt. Fehler geben keine
Rohdatensaetze aus. Die Beispiele sind synthetisch und enthalten keine Keys.

[Rechts-/Architekturdokumentation](../../docs/legal/README.md) und
[Master-Prompt](../../docs/legal/prompts/GLOBAL_AI_RAG_REVIEW.md) bleiben
bewusst von einem produktiven Enforcement-/Policy-System getrennt.
