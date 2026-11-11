# Coding-Modelle: Luecken messen, trainieren und Daten migrieren

Stand: **11.11.2026**. Zur [Modell-Einrichtung](README.md) und zu
[RAG, Gewichten und Herkunft](WEIGHTS_RAG_AND_PROVENANCE.md).
Alle folgenden Schritte sind ein Arbeitsplan, kein gestartetes Training.
Keine Produktivdienste, Modelle, Compilertests oder Downloads automatisch ausfuehren.

## 1. Wie erkennt man fehlendes oder ungenaues Wissen?

Es gibt keinen vollstaendigen Wissensindex in den Gewichten. Ein Modell kann
etwas im Test nicht abrufen, obwohl es aehnliche Daten im Training gesehen hat.
Eine bestandene Frage beweist ebenfalls keine Zugehoerigkeit zum Trainingssatz.
Nicht nach Selbsteinschaetzung des Modells entscheiden, sondern nach messbarer
Leistung auf **eigenen, bisher ungesehenen Aufgaben**.

Fuer dein Setup getrennt messen: Python-/Shell-Installer; Kubernetes/YAML;
Sicherheitsgrenzen; Code-Refactoring; C/C++/Rust; Assembler mit genauem ABI;
Versionswissen fuer verwendete Bibliotheken; Quellenbelege und Tool-Calling.

### Fehlerklassen statt pauschal "mehr Daten"

| Beobachtung | Zuerst untersuchen | Wahrscheinliche Massnahme, keine Diagnosegarantie |
| --- | --- | --- |
| Modell kennt neue API nicht | Richtige Dokumentrevision im Kontext? | RAG oder aktuelle Referenz bereitstellen |
| Richtige Seite existiert, wird aber nicht gefunden | Chunking, Metadaten, Suchabfrage, Retriever | Retrieval verbessern statt sofort trainieren |
| Antwort trotz korrekter Referenz falsch | Kontextlaenge, Prompt, Modellkapazitaet, widerspruechliche Quellen | Prompt/Test oder anderes Modell, danach gezielte Beispiele |
| Code kompiliert nicht | Sprache, Compiler-/Framework-Version, Chat-Template | Passende Reparaturpaare und Compilerfeedback |
| Falsches JSON oder Tool-Schema | Clientparser, Template, Modellfaehigkeit | Vertrag und Formatbeispiele pruefen |
| Assembler scheitert | ISA, Syntax, ABI, Clobber-/Stack-Regeln | Dialektbezogene Beispiele mit Referenztests |
| Regelbrueche / Zugriff auf Secrets | Agentenrechte und Ausfuehrungsgrenze | Harte Sandbox-/Policy-Grenzen, nicht nur Fine-Tuning |

Kontrollversuche: gleiche Aufgabe ohne RAG, mit normalem Retrieval und mit
manuell ausgewaehltem korrektem Kontext. Verbessert nur der letzte Versuch
die Antwort, liegt ein Retrievalproblem nahe. Das ist eine begruendete
Inferenz, kein Beweis fuer ein bestimmtes fehlendes Trainingsdokument.

## 2. Eigene Evaluationssuite aufbauen

1. Reale Fehlersituationen mit anonymisierten Minimalbeispielen sammeln.
2. Aufgaben nach Sprache, Schwierigkeit, Bibliotheksversion, Sicherheitsrisiko
   und Fehlerklasse markieren. Erwartung unabhaengig vom Modell bestimmen.
3. Nach Projekt/Familie gruppieren; nahe Duplikate nicht auf Train und Test
   verteilen. Zukunfts-/Versionsaufgaben als zeitlichen Holdout verwenden.
4. Testset vor Training einfrieren und hashen. Nicht zum Prompt-Tuning oder
   zur Beispielsammlung verbrauchen; separates Entwicklungsset verwenden.
5. Basismodell, RAG-Variante und Fine-Tune unter gleichen Ressourcen messen.
6. Mehrere Seeds/Laeufe, Anzahl Aufgaben und Unsicherheit berichten; bei
   kleinen Stichproben keine pauschale Prozent- oder Sprachgarantie.

Metriken: Compile-/Unit-Test-Quote, funktionale Korrektheit, Regressionen,
Sicherheitsverletzungen, korrekte Quellen, Retrieval-Treffer, Abstention bei
fehlender Evidenz, Latenz, Tokenzahl, Peak-RAM/VRAM und Energie soweit messbar.
LLM-as-Judge nur ergaenzend und mit unabhaengigem menschlichem Review.
Testabdeckung des generierten Codes ist nicht dasselbe wie dessen Korrektheit.

Bekannte Benchmarks wie [MultiPL-E](https://github.com/nuprl/MultiPL-E) helfen
bei Methodik und Sprachvergleich. Ihre moegliche Trainingskontamination und
Abweichung von eigenen Aufgaben benennen. Keine nicht bestandenen Sprachen
aus dem Bericht entfernen, um die Quote zu verbessern.

Lokale Vorlage: [Coding-/Assembler-Testfaelle](../../examples/models/coding-eval-cases.json).
Die Vorlage ist kein Evaluationsrunner und hat keine automatischen Shellbefehle.
Generierten Code ausschliesslich in einer freigegebenen nicht privilegierten,
Docker-freien Sandbox/VM mit Ressourcen-/Zeit-/Netzlimits ausfuehren, nicht im
normalen Setup- oder Produktivverzeichnis. Worktrees allein sind keine Sandbox.

## 3. Wann RAG, SFT oder anderes Training?

| Ziel | Bevorzugter erster Weg | Grenzen |
| --- | --- | --- |
| Neue Repository-/API-Dokumentation | RAG, Volltext- oder Codesuche | Muss richtige Quellen abrufen, kostet Kontext |
| Konsistentes Ausgabeformat und Arbeitsstil | Gute Prompts, dann SFT/LoRA | Kein Ersatz fuer Berechtigungspruefungen |
| Bestimmte wiederkehrende Codefehler | Gepruefte Aufgaben-/Loesungs-/Testpaare | Generalisierung mit ungesehenen Aufgaben pruefen |
| Tiefe Domaen-/Sprachanpassung | Erst Messung, eventuell continued pretraining | Hoher Daten-/Rechenbedarf, Vergessensrisiko |
| Bevorzugung einer von zwei korrekten Antworten | Kuratierte Praeferenzdaten, eventuell DPO | Kein automatischer Wahrheitsbeweis |

SFT trainiert auf vorgegebenen Beispielen; LoRA lernt kleinere Adapter statt
alle Basisgewichte zu aendern. QLoRA kombiniert quantisierte eingefrorene
Basisgewichte mit trainierbaren Adaptern, nicht mit einer beliebigen direkt
trainierbaren GGUF-Datei. [PEFT-LoRA](https://huggingface.co/docs/peft/main/en/conceptual_guides/lora),
[QLoRA-Arbeit](https://arxiv.org/abs/2305.14314) und
[PEFT-Quantisierung](https://huggingface.co/docs/peft/developer_guides/quantization).

Training aendert statistisches Verhalten und kann Fakten fehlerhaft verankern.
RAG ist fuer aktualisierbare, belegbare Fakten oft geeigneter. Beides kann
kombiniert werden; nichts davon garantiert Halluzinationsfreiheit.

## 4. Welche Daten hinzufuegen?

Gezielte kleine Datensaetze zuerst: echte wiederkehrende Fehler, korrekte
Loesung, Begruendung mit pruefbarer Quelle und unabhaengige Tests. Nicht einfach
gesamte Logs oder tausende ungepruefte Lehrerantworten aufnehmen.

Pro Datensatz Rechte/Lizenz, Quelle/Revision, Datum, Sprache, Versionen,
Schwierigkeitsgrad, menschliche Pruefung und synthetische Herkunft erfassen.
Secrets, personenbezogene Daten, private Repositories und Zugangsdaten vor
Sammlung ausschliessen. Auffaellige Fast-Duplikate, falsche Loesungen,
kontradiktorische Regeln und Benchmark-Leaks entfernen oder isolieren.

Negative Beispiele nicht kommentarlos als richtige Assistant-Antwort trainieren.
Fuer Reparaturpaare fehlerhaften Ausgangszustand als Aufgabe und gepruefte
Korrektur als Ziel kennzeichnen. Bei Praeferenzdaten `chosen`/`rejected`
und die Begruendung in einem eigenen Schema speichern.
Maschinell bestandene Tests beweisen nicht automatisch die Lizenz oder
Abwesenheit versteckter Nebenwirkungen.

## 5. Portables kanonisches Datenformat

[Beispieldaten](../../examples/models/coding-training.records.jsonl) sind kleine,
selbst verfasste **synthetische Vorlagen**, keine Trainingsempfehlung nach Menge.
JSONL: ein JSON-Objekt pro Zeile. Metadaten vom eigentlichen Chat trennen:

```json
{
  "schema_version": 1,
  "id": "owned-example-001",
  "group_id": "project-family-a",
  "language": "python",
  "license": "Apache-2.0",
  "source": "self-authored-synthetic",
  "review_status": "template-not-training-approved",
  "messages": [
    {"role": "user", "content": "Beschreibe eine harmlose Coding-Aufgabe."},
    {"role": "assistant", "content": "Eine gepruefte Musterantwort."}
  ]
}
```

Dieses Archivschema ist absichtlich modellneutral; es ist keine Zusage,
dass jeder Trainer alle Metadatenspalten akzeptiert. Gesondert speichern:
Dateihashes, Dataset-Version, Quellenrechte und Split-Liste. Ohne Freigabe
bleiben die Beispieldaten Vorlagen, nicht automatisch Trainingseingaben.

## 6. Daten fuer ein Nachfolgemodell konvertieren

**Rohdaten bleiben, Tokenisierung und Template werden neu erzeugt.**
Erst Zielmodell und Trainer festpinnen, dann in einer Kopie exportieren:

1. Kanonisches JSONL validieren: UTF-8, Schema, Rollen, Pflichtfelder,
   eindeutige IDs, Rechte und Duplikatgruppen. Original unveraendert behalten.
2. Exportziel festlegen: Chat-`messages`, Text-SFT, FIM-Code oder Praeferenzpaar.
   Inhalt semantisch passend transformieren; Praeferenzpaare sind keine
   gewoehnlichen User-/Assistant-Dialoge.
3. Nur unterstuetzte Spalten an den Trainer geben; Metadaten in Sidecar behalten.
   Tool-Aufrufe und Multimodalitaet brauchen ein eigenes passendes Zielschema.
4. **Tokenizer und Chat-Template des neuen Checkpoints** anwenden. Alte Token-IDs
   nicht uebernehmen. BOS/EOS, Assistant-Masken, Tool-Rollen und Stop-Sequenzen
   mit kurzen Roundtrip-Tests pruefen. Kein doppeltes Templating.
5. Laengen messen: keine Zielantwort unbemerkt abschneiden. Packing und
   Loss-Masking pruefen; private Metadaten nicht versehentlich mittrainieren.
6. Quell-/Exporthashes, Konverterversion und unveraenderte Split-Zuordnung
   dokumentieren. Deduplication und Kontaminationscheck erneut ausfuehren.

Lesendes Exportbeispiel fuer unser **einfaches Text-Chat-Schema**, kein Trainer,
keine Tokenisierung und kein allgemeiner Tool-/Multimodal-Konverter:

```python
import json
from pathlib import Path

path = Path("examples/models/coding-training.records.jsonl")
for line in path.read_text(encoding="utf-8").splitlines():
    record = json.loads(line)
    if record["schema_version"] != 1:
        raise ValueError("Unsupported schema")
    print(json.dumps({"messages": record["messages"]}, ensure_ascii=False))
```

Ausgabe zuerst pruefen, erst danach bewusst in eine neue externe Exportdatei
uebernehmen; dieses Beispiel startet kein Training. Nicht fuer riesige Dateien
verwenden: dann streaming, Groessenlimits und umfassendere Schema-Pruefung.
Quellen: [Transformers-Chat-Templates](https://huggingface.co/docs/transformers/chat_templating),
[TRL SFT](https://huggingface.co/docs/trl/main/en/sft_trainer).

Ein alter **LoRA-Adapter** ist dagegen nicht einfach ein portabler Datensatz.
Layernamen, Dimensionen, Basismodellrevision und Architektur muessen passen.
Ein Qwen-Adapter funktioniert nicht pauschal mit DeepSeek oder einem neuen
Qwen-Modell. In der Regel den freigegebenen Datensatz fuer die neue Basis
erneut trainieren. Konvertierte Gewichte, migrierte Daten, neue Embeddings
und neu trainierte Adapter sind vier unterschiedliche Vorgaenge.

## 7. Sicherer Trainingsablauf auf der Heim-GPU

1. Kleine Zielbasis und kompatiblen nativen Trainer aus geprueften GitHub-
   Quellen waehlen; Code-/Gewichts-/Datensatzpins und Lizenzen dokumentieren.
2. Isolierte Umgebung unter externen Benutzerdaten, keine globalen Python-
   Pakete ersetzen. Passende Treiber/CUDA/PyTorch-/Trainer-Kombination vorab
   pruefen; kein festes CUDA-Versprechen fuer jede RTX-Generation.
3. Offline-Cache nur aus zuvor freigegebenen und gehashten Artefakten fuellen.
   Kein automatisches `trust_remote_code`, keine Telemetrie-/Cloud-Tracker.
4. GPU exklusiv reservieren oder Inferenz kontrolliert pausieren; kein
   Time-Slicing als VRAM-Isolation ansehen. CPU/RAM/Disk sowie Gradient-/
   Optimizer-/Aktivierungsbedarf beruecksichtigen, nicht nur Gewichtsdateien.
5. Nach expliziter Freigabe einen kurzen Pilot mit kleinem Batch, begrenzter
   Sequenzlaenge und wenigen Schritten starten. Peak-Speicher messen;
   OOM-Abbruch und Checkpointing vor einem langen Lauf testen.
6. Basismodell read-only halten, Checkpoints/Adapter versionieren. Keine
   bestehenden Modelle, Benutzerdateien oder Produktivdienste ueberschreiben.
7. Holdout, alte Sprachfaehigkeiten und Sicherheitsregressionen evaluieren.
   Mehr Training kann Overfitting, Datenmemorierung und catastrophic forgetting
   verursachen; sinkender Training-Loss allein ist kein Freigabekriterium.
8. Erst nach menschlichem Review einen neuen privaten Modellalias freigeben.
   Alten Digest und Evaluationsbericht fuer Rollback behalten.

Qwen3-Coder-30B, MiniMax-M3 und das grosse DeepSeek-R1 sind nicht automatisch
auf einer einzelnen Heim-GPU trainierbar. Fuer den Einstieg kleine passende
Modelle/Adapter und eine gemessene Reserve statt eines 18-Stunden-Blindlaufs.
Es wird hier kein produktionsreifes Trainingsskript suggeriert: Ein solches
braucht einen ausgewaehlten Checkpoint, Trainer-Pins und echte Hardwaretests.

## 8. Freigabebericht je Modellversion

Festhalten: Basis/Adapter/Dataset-Digests, Lizenzpruefung, Datenherkunft,
Trainingsparameter, Code-/Runtime-Pins, Hardware, Zeiten und Peak-Ressourcen;
danach Testset-Digest, Aufgabenzahl je Sprache, Fehlerkategorien, Unsicherheit,
RAG-Ablationen, Sicherheitsbefunde und unabhaengige Reviewentscheidung.
Keine privaten Beispiele in oeffentlichen Logs. Schlechtere Varianten als
gescheitert dokumentieren, nicht durch Umbenennen zu erfolgreichen erklaeren.
