# Vorlage fuer eine Modell-Detailseite

Diese Vorlage dokumentiert einen konkreten Checkpoint, keine pauschale Modellfamilie.
Alle Platzhalter ersetzen; daraus entstehen weder Trainingsfreigabe noch Installation.

## Identitaet und Rechte

- Modell-ID, Upstream-URL, genaue Revision und Artefakt-Pruefsummen.
- Basismodell, Adapter, Tokenizer, Gewichtslizenz, Codelizenz und Nutzungsbedingungen getrennt.
- Status jeweils: dokumentiert, Quellen vorbereitet, gebaut, getestet oder stabil, mit Beleg.
- Sprache, Aufgabe, Kontext, Quantisierung, GPU/RAM und gemessene Grenzen.

## Daten und Training

- Datenherkunft, Rechte/Einwilligung, personenbezogene Daten, Stichtag und Jurisdiktion.
- Versioniertes neutrales JSONL-Schema; Konverter fuer die konkrete Trainingsbibliothek.
- Trainings-/Validierungs-/Test-Split, Dubletten, Leakage, Holdout, Baseline und Fehlertaxonomie.
- LoRA/QLoRA nur bei nachgewiesener Architektur- und Tool-Unterstuetzung; keine beliebige 8B/14B-VRAM-Garantie.
- Exakte Software-Pins, native Build-Abhaengigkeiten, Lock/SBOM und reproduzierbare Parameter.
- Laufzeit, Peak-RAM/VRAM, Checkpoint-Herkunft und fachlich gepruefte Ergebnisse.

## Export und Integration

1. Basismodell und Adapter passend zusammenfuehren; neue getrennte Ausgabe verwenden.
2. HF-Export auf Vollstaendigkeit und Tokenizer-/Chattemplate-Kompatibilitaet pruefen.
3. [GGUF-Exportplan](../MODEL_ROUTING_EXPORT_AND_MONITORING.md) am konkreten llama.cpp-Pin reviewen.
4. F16 und Quantisierung getrennt pruefen; Qualitaetsverlust gegen den Holdout messen.
5. Ollama-Import separat freigeben; korrekte PARAMETER-Syntax im Modelfile verwenden.
6. OpenClaw-Referenz anhand der installierten Konfigurationsversion pruefen; keine erfundene YAML-Struktur ueberschreiben.
7. Inferenz/Benchmark gesondert freigeben; HTTP-200 ist kein fachlicher Validierungsnachweis.

## Rollback

Vorigen geprueften Modell-Digest und Konfigurationsstand aufbewahren. Keine
Pauschalloeschung von Nutzerdaten, Adaptern, Trainingsdaten, Modellen oder Logs.
Offene Punkte und Grenzen der Reproduzierbarkeit explizit auflisten.
