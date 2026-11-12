# Open Weights, RAG und Modellherkunft

Stand: **11.11.2026**. Zur [Einrichtung und Sprachuebersicht](README.md),
zum [Weitertraining](TRAINING_AND_EVALUATION.md) und zu [Qwen Coder](../tools/qwen-coder.md).
Keine Gewichte untersucht, keine privaten Daten ausgelesen oder Modelle abgefragt.

## 1. Lassen sich Open Weights entschluesseln?

**Normalerweise sind Gewichte gar nicht verschluesselt.** Es sind Zahlenfelder
(Tensoren) mit gelernter Parametrisierung, kein verschluesseltes Buch und keine
Liste von Originaldokumenten. Bei Quantisierung kommen kodierte niedrige
Bitbreiten, Skalen und weitere Metadaten hinzu. Ein passender Parser kann diese
numerisch lesen; das erzeugt keinen urspruenglichen Klartextkorpus.

Tokenizer-Dateien beschreiben die Zuordnung zwischen Textstuecken und Token-IDs.
Sie sind ebenfalls kein Verzeichnis aller gelernten Fakten. Das Decodieren von
Token-IDs ist nicht das Decodieren der Modellgewichte. Ein Tensor-Dump als CSV
waere vor allem sehr gross und fuer normale Dokumentensuche nicht sinnvoll.

Die Abbildung Trainingsdaten -> Gewichte ist nicht eindeutig umkehrbar. Man
kann daraus nicht zuverlaessig alle Trainingsdokumente, Lizenzen oder fehlenden
Themen rekonstruieren. Mechanistische Interpretierbarkeit und Modell-Editing
sind andere Forschungsfragen, keine Funktion "Export als Wissensdatenbank".

[Safetensors](https://huggingface.co/docs/safetensors/index) beschreibt ein
Tensorformat ohne Pickle-Ausfuehrung. Das beseitigt nicht alle Risiken eines
unvertrauten Downloads: Parser, Dateigroessen, Architekturdefinitionen und
Begleitcode weiterhin pruefen; keine automatischen Remote-Code-Imports.

## 2. Aber ein Modell kann doch Trainingssaetze wiedergeben?

Ja, bestimmte Trainingsbeispiele koennen memoriert sein. Das ist eine
Datenschutz-/Datenleckgefahr, kein vollstaendiger, korrekter Korpusexport.
Wortgetreue Erinnerung und frei erfundene Fortsetzungen lassen sich nicht
allein anhand einer ueberzeugenden Antwort sicher unterscheiden.
Die Forschung [Extracting Training Data from Large Language Models](https://arxiv.org/abs/2012.07805)
belegt moegliche Extraktion einzelner Beispiele, nicht die Rekonstruktion des
gesamten Trainingsbestands. Keine fremden personenbezogenen Daten extrahieren
oder vermeintlich erinnertem Text automatisch eine Herkunft zuschreiben.

## 3. Was gehoert stattdessen in RAG?

RAG kombiniert Dokumentabruf mit Generierung; siehe
[urspruengliche RAG-Arbeit](https://arxiv.org/abs/2005.11401).
Fuer das Setup: eigene Handbuecher, erlaubte Repository-Dateien, API-Versionen,
Release Notes, Architekturentscheidungen und verifizierte Loesungsbeispiele.
Keine Gewichte, Secrets, ungeprueften Modellantworten oder private Promptlogs.

```text
freigegebene Dokumente / Code + Quellenrechte + Revision
  -> bereinigen, strukturieren, deduplizieren
  -> Chunks mit Pfad, Sprache, Lizenz, Datum und Inhalts-Hash
  -> Volltext-/Code-Suche, optional Embeddings
  -> relevante Ausschnitte mit Quellenangabe in den Modellkontext
  -> Antwort gegen Quelle und Tests pruefen
```

Eine vorhandene SQLite-/Volltextsuche reicht fuer den Einstieg oft aus.
Vektor-RAG ist eine Option, kein Zwang. Code besser entlang Funktionen,
Klassen und Modulen strukturieren, nicht blind mitten in Symbolen schneiden.
Importpfade und verknuepfte Definitionen mit abrufen. Zugriffsrechte beim
Abruf durchsetzen, auch wenn der Index technisch lesbar ist.
Web-/Repo-Inhalte sind untrusted data, keine neuen Systemanweisungen.
Keine darin gefundenen Shellbefehle automatisch ausfuehren.

Das Modell lernt durch einen RAG-Aufruf nicht dauerhaft in seinen Gewichten.
Neue Dokumente erfordern Indexaktualisierung; geaenderte Embedding-Modelle
koennen eine vollstaendige Neuindizierung erfordern. Alte und neue Vektoren
unterschiedlicher Encoder nicht einfach mischen. Ein anderes generatives
LLM braucht nicht zwingend neue Embeddings, wenn der Retriever gleich bleibt;
Antwortqualitaet und Kontextformat trotzdem erneut testen.

## 4. Kann man Modellwissen per Fragen in RAG exportieren?

Man kann zu eigenen Aufgaben Antworten erzeugen und daraus nach Pruefung
einen **synthetischen Datensatz** bauen. Das sind Ausgaben eines Modells,
nicht dessen originale Trainingsdaten. Quellen, Lehrer-Modellrevision,
Promptversion, Validierung, Nutzungsbedingungen und synthetische Herkunft
mitfuehren. Halluzinationen nicht durch Indexierung scheinbar belegen.

Bei Code: kompilierbare, getestete Loesung mit menschlichem Review und
Rechtenachweis statt ungepruefter Antwort sammeln. Testset nicht in den
Trainingskorpus zurueckkopieren. Eine vom Modell angegebene Quellen-URL
unabhaengig pruefen. API-/Modellbedingungen koennen Distillation und
Weitergabe einschraenken; kein pauschal erlaubter Wissenstransfer.

## 5. Wenn ich ein Modell umbenenne: ist es dann meines?

**Ein neuer Name oder Systemprompt macht aus einem Basismodell kein selbst
trainiertes Originalmodell.** Ein LoRA oder Fine-Tune ist ein eigener Beitrag,
aber dessen Basisherkunft bleibt relevant. Sachgerecht ist etwa
"MeinProjekt-Coder, Fine-Tune von DeepSeek-R1-Distill-..., mit Datensatz v2",
nicht die Behauptung eines eigenstaendig von Grund auf trainierten Modells.

Bei Weitergabe konkrete Lizenzbedingungen einhalten: Lizenztexte, relevante
Copyright-/NOTICE-Hinweise und erforderliche Aenderungskennzeichnung erhalten.
Apache-2.0 gewaehrt nicht automatisch Markenrechte. Daten-, Basis-, Adapter-
und Dienstbedingungen getrennt pruefen, auch bei erlaubter Umbenennung.
Primaerquellen: [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0),
[DeepSeek-R1-Lizenz](https://github.com/deepseek-ai/DeepSeek-R1/blob/0cf78561f1d51c84a21b2190626b21116d5c68bb/LICENSE).
Dies ist eine technische Herkunftsregel, keine individuelle Rechtsberatung.

## 6. Woran erkennt man DeepSeek oder eine andere Basis?

| Nachweis | Aussagekraft | Grenze |
| --- | --- | --- |
| Bytegleiche Datei mit bekanntem vertrauenswuerdigem SHA256 | Sehr starker Nachweis identischen Artefakts | Andere Serialisierung, Quantisierung oder Fine-Tune veraendert den Datei-Hash |
| Geprueftes Manifest, Signatur, Ausgangsrevision und Build-/Trainingstagebuch | Nachvollziehbare Liefer- und Ableitungskette | Vertrauensanker und Vollstaendigkeit muessen stimmen |
| Tensor-Namen, Formen, Wertevergleich und Architektur | Hinweise bis hin zum Nachweis identischer Tensoren trotz anderer Verpackung | Gleiche Architektur allein beweist keine gemeinsame Gewichtsbasis; Vergleich kann teuer sein |
| Tokenizer, Chat-Template, Konfiguration und Adapter-Metadaten | Hilfreiche Herkunftsindikatoren | Metadaten sind veraenderbar; allein kein sicherer Beweis |
| Antwortstil, bekannte Fehler, Benchmarks oder behaupteter Name | Verhaltensindizien | Systemprompt, Sampling, Training und Distillation beeinflussen alles; keine eindeutige Identifikation |

Die Frage "Wer bist du?" ist kein Herkunftstest. Es gibt keinen universellen
zuverlaessigen Detektor, der bei jedem stark veraenderten oder nur per API
sichtbaren Modell die Basis beweist. Ausbleibender Nachweis macht eine falsche
Urheberbehauptung nicht richtig. Keine Anleitung zum Entfernen von Herkunft
oder Lizenzhinweisen; stattdessen sauber dokumentierte Ableitungen erstellen.

## 7. Herkunft bei eigenen Modellen dokumentieren

Ausserhalb von Git je Modell ein freigegebenes Manifest mit Modell-ID,
Gewichtsrevision, SHA256 je Datei, Code-/Runtime-Pin, Lizenzquelle,
Tokenizer-/Chat-Template-Hash, Konvertierungs-/Quantisierungsparametern,
Adapterrevision, Datensatzversion und freigegebenem Evaluationsbericht halten.
Keine privaten Trainingsbeispiele oder Keys ins oeffentliche Manifest aufnehmen.

Originalgewichte read-only behalten; Fine-Tunes und konvertierte Modelle in
eigene Versionsverzeichnisse schreiben. Signaturen binden Integritaet und
Herkunftsbehauptung, beweisen aber nicht die Richtigkeit aller Trainingsdaten.
Rollback bedeutet auf den vorher getesteten Modell-/Adapter-Digest zurueck,
nicht Benutzerdaten oder ganze Modellverzeichnisse pauschal zu loeschen.
