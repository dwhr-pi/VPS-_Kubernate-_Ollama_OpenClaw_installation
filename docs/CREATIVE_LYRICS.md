# Lokale Reim-, Gedicht- und Songtext-Werkzeuge

Stand **11.11.2026**. GitHub-Quellen nativ bevorzugt; kein Docker-Fallback.
Keine Installation, Modelle, Trainingslaeufe, Audiowiedergabe, Provider-APIs oder
Dienste durch diese Dokumentation. Quellen-Fixtures sind keine Runtime-Abnahme.

## Bestand und tatsaechlicher Umfang

[Ergaenzender Musik-/Lyrics-Katalog](MUSIC_LYRICS_MODEL_CATALOG.md):
YuE, LeVo 2, ACE-Step, MusicGen, MOSS-Music, SongSage, PoeLM, PoeTone, CoPoet
und CTGS mit ihren getrennten Quellen-/Lizenz-/Runtime-Grenzen.

| Bestandteil | Aufgabe | Implementiert | Offen |
| --- | --- | --- | --- |
| [Outlines](tools/outlines.md) | Strukturierte Ausgabe / eingeschraenktes Decoding | Gepinnte Quellenverwaltung und optionaler Python-Adapter | Nativer Paket-/Backend-Build, echtes LLM-Decoding |
| [eSpeak NG](tools/espeak-ng.md) | Aussprache-/IPA-Vorschlaege | Gepinnte Quellenverwaltung und dokumentierter lautloser CLI-Weg | Nativer Build, Sprach-/IPA-/Audio-Abnahme |
| [Offline-Lyric-Pruefer](../scripts/creative/lyric_constraints.py) | Planung und Entwurfspruefung | Python-Standardbibliothek; Schema, Zeilen, Endwoerter und kuratiertes Lexikon | Allgemeine Phonetik, automatische verifizierte Skansion |
| [Promptvorlage](../examples/creative_lyrics/creative_rhyme_architect.md) | Creative Generation oder Rhyme Assistant | Lokales Promptmaterial, nicht aktivierte System-/Profilregel | Agenten-/MCP-Anbindung und kreative Qualitaetsabnahme |

Die neuen Quellen-Tools sind separat im Tool-Menue waehlbar. Bestehende Profile
starten oder installieren sie nicht automatisch. Kein zusaetzlicher Cluster,
Server oder GPU-Dienst fuer den Offline-Pruefer erforderlich.

## 1. Korrekturen am gelieferten Entwurf

Die Zeile `-import torch` ist ungueltiges Python. Ein Paketimport alleine
laedt noch kein Modell, `from_pretrained` kann ohne Offline-Grenzen hingegen
Netzwerkzugriffe und grosse Downloads ausloesen. Llama-Varianten unterliegen
jeweiligen Modellbedingungen; nicht jede offene Gewichtedatei ist unter einer
uneingeschraenkten Open-Source-Lizenz verfuegbar.

Die Regex `(Nacht|Pracht|...)[\s\w,...]+` setzt die Woerter **an den Anfang**,
nicht ans Zeilenende. `\s` schliesst Zeilenumbrueche ein. Ein solches Muster
kann weder genau vier Zeilen noch eine Silbenzahl beweisen. `Gedicht` und
`Licht` koennen sich reimen, obwohl ihre Silbenzahlen verschieden sind.

Am geprueften Outlines-Pin ist der dokumentierte Weg `from_transformers` plus
`outlines.types.Regex` und Modellaufruf. Die alte API `outlines.generate.regex`
wird nicht kopiert. Die konkreten API-Quellen wurden als vollstaendige Dateien
am [festen Commit](https://github.com/dottxt-ai/outlines/tree/c52af8472c6fe8a607a733ec11b709476af77a96)
gelesen; ein nicht erreichbarer alter Dokumentationspfad ist kein Beleg fuer
Kompatibilitaet. Quelle: [Output Types am Pin](https://github.com/dottxt-ai/outlines/blob/c52af8472c6fe8a607a733ec11b709476af77a96/docs/features/core/output_types.md).

## 2. Reim, Silben und Metrum getrennt behandeln

Ein globaler Transformers-LogitsProcessor mit fester Token-ID-Whitelist prueft
ebenfalls keine Reime oder Silben: Subword-Token sind keine Woerter, und die
Maske kennt weder Zeilenposition noch Aussprache. Eine leere oder zum Vokabular
unpassende Liste kann das Decoding blockieren. Der vorhandene Outlines-Adapter
erzwingt daher nur die dokumentierte Struktur; danach folgt die unabhaengige,
begrenzte Lexikonpruefung. Kein weiterer gleichnamiger Generator wird angelegt.

Ein Vollreim wird phonetisch ab dem letzten betonten Vokal beurteilt; gleiche
Schreibendung genuegt nicht. Aussprache, Vokallaenge und Dialekt beruecksichtigen.
Bei mehreren Aussprachen nicht stillschweigend die passendste als sicher waehlen.
Das Beispiellexikon ist eine kleine kuratierte Demonstration, kein vollstaendiges
deutsches Aussprachewoerterbuch und keine wissenschaftliche Referenzdatenbank.

Silben sind keine Token- oder Wortzahl. Elision, Namen, Abkuerzungen und gesungene
Dehnungen erschweren die Zaehlung. Lexikalische Betonung ist nicht automatisch
metrische Hebung/Senkung im Satz. Deshalb bleibt **menschliche Skansion erforderlich**,
auch wenn alle Beispielwoerter und formalen Regeln passen.

Der Pruefer kann AABB, ABAB, ABBA, AAAA oder andere 2-16 Zeichen lange Schemata
mit kuratierten Endwortgruppen planen. Jeder Buchstabe hat eine eigene Reimgruppe;
identische Endwortwiederholungen werden abgelehnt. Verschiedene Gruppen duerfen
nicht denselben kuratierten Reimschluessel haben. Unbekannte Aussprache wird als
offen gemeldet, nicht geraten. Unreine Reime sind standardmaessig verboten;
`allow_slant: true` wird derzeit ausdruecklich als nicht implementiert abgelehnt.

`meter` ist entweder `null` oder ein explizites Muster wie `0101` fuer die vier
Beispielsilben; `0` = hier angenommene Senkung, `1` = Hebung. Benannte Metren wie
"iambic pentameter" werden nicht automatisch umgerechnet. Sonett-, Haiku-,
Verse-/Chorus-/Bridge-Formen muessen getrennt geplant werden: Die CLI deckt
**nur eine Strophe** ab und gibt andere Strukturen nicht als unterstuetzt aus.
Mehrere Strophen einzeln pruefen; Glue-/Wiederholungsregeln sind noch kein Code.

## 3. Offline sofort pruefen

Kein Outlines, Torch, eSpeak, Modell oder Netzwerk fuer diese Befehle erforderlich.
Im Repository mit Python 3 ausfuehren:

```bash
python3 -B scripts/creative/lyric_constraints.py plan \
  --request examples/creative_lyrics/request.json \
  --lexicon examples/creative_lyrics/lexicon.de.json

python3 -B scripts/creative/lyric_constraints.py validate \
  --request examples/creative_lyrics/request.json \
  --lexicon examples/creative_lyrics/lexicon.de.json \
  --lyrics examples/creative_lyrics/sample.txt --format markdown
```

Unter Windows den bekannten funktionierenden Python-Pfad bzw. `& $Python`
statt `python3` verwenden. Keine WSL-Installation fuer den Offline-Test noetig.
Ein abschliessender Dateizeilenumbruch wird toleriert, CRLF normalisiert;
zusaetzliche Leerzeilen und ungewoehnliche Zeilentrenner werden nicht toleriert.

Ausgabeabschnitte: `[Metadata Header]`, `[Lyrics / Poem]`,
`[Rhyme & Cadence Analysis]`. Der JSON-Bericht enthaelt Endwoerter, kuratierte
IPA-/Reimschluessel, Silben, angenommene Betonung und offene Probleme.

| Exit | Bedeutung |
| --- | --- |
| 0 | Angegebene Regeln im kuratierten Beispiellexikon erfuellt; kein poetisches Qualitaets-/Runtime-Zertifikat |
| 1 | Formale Abweichung, Endwortwiederholung oder bekannter Silben-/Betonungsfehler |
| 2 | Ungueltige Konfiguration, nicht unterstuetzter Modus oder unsichere/unlesbare Eingabe |
| 3 | Keine harte Abweichung, aber unbekannte Aussprache/Token-Inhalte; keine vollstaendige Pruefung |

Immer `human_review_required: true`, `runtime_acceptance: false`.
Keine Dateien werden geschrieben, keine Shellbefehle oder Lyrics ausgefuehrt.
JSON-Schluesselduplikate, verlinkte Eingaben, Terminal-Steuer-/Formatzeichen,
unpassende Sprache und grosse
Dateien werden abgelehnt. Eingaben nur aus bewusst freigegebenen Dateien lesen;
keine Secrets oder privaten Texte in oeffentliche Pruefberichte uebernehmen.

## 4. Eingabeprotokoll und Grenzen

[request.json](../examples/creative_lyrics/request.json) zeigt alle Pflichtfelder:
`mode`, `topic`, `genre`, `structure`, `language`, `scheme`,
`syllables_per_line`, `meter`, `allow_slant`, `endings`.
Nicht benoetigte Silben-/Metrikziele auf `null` setzen, nicht weglassen.
`creative` plant einen Entwurf, `assistant` plant/prueft vorhandene Entwuerfe;
die CLI generiert in keinem Modus automatisch Text.

Nur Endwoerter aus dem zur Sprache passenden Lexikon verwenden. Pro Gruppe
genug unterschiedliche Woerter fuer alle Vorkommen angeben, maximal 16.
`Gedicht` hat im Beispiel zwei Silben und kann deshalb ein vier-silbiges
Zeilenziel verletzen, obwohl die Reimgruppe stimmt. Unbekannte Woerter sind
bewusst **kein Erfolg**. Das gesamte Lexikon muss nicht als Prompt gesendet
werden; es bleibt eine getrennte lokale Pruefinstanz.

Eine andere Sprache benoetigt ein eigenes geprueftes Lexikon mit IPA, Reimkern,
Silben und gegebenenfalls kontextabhaengiger Betonung. Die deutschen Daten
nicht als englische, franzoesische oder gesungene Aussprache ausgeben.

## 5. Optionale lokale Outlines-Generierung

`generate_with_outlines(model, request, lexicon, approved=True)` nimmt nur ein
**bereits vom Betreiber eingerichtetes** Outlines-Modell entgegen. Es laedt
keinen Tokenizer und keine Gewichte. Der Aufrufer muss lokale Herkunft,
Modellrechte, Offline-Faehigkeit und Ressourcen pruefen. Kein Remote-/Cloud-
Modellobjekt uebergeben; der allgemeine Python-Callable-Typ kann das nicht
automatisch beweisen. Es gibt keinen automatischen Provider-Fallback.

Die Funktion erstellt nur die Strophe mit `Regex`, prueft danach unabhaengig
und begrenzt Wiederholungen auf hoechstens drei Versuche, Standard zwei.
Maximal 1024 neue Tokens je Versuch, Standard 512. Keine Endlosschleife;
bei unpassendem Tokenizer/Regex oder unmoeglichen Vorgaben Abbruch statt
Umschalten auf unbeschraenktes Decoding. Tokenlimits sind keine RAM-/VRAM-Limits.

Einrichtung erst nach [Modellfreigabe](models/README.md) und nativer
Paket-/Backend-Abnahme. Fuer Transformers beim separaten Laden lokale absolute
Artefaktpfade, `local_files_only=True`, `trust_remote_code=False` und die
Offline-/Telemetrie-Einstellungen des eingesetzten Stacks verwenden. Kein
blindes `from_pretrained("meta-llama/...")`, kein automatisch aufgerufenes
`vllm serve` oder Hub-Login. GPU-Jobs serialisieren und Speicher vorher messen.

Die Outlines-Regex-API wird durch Stubs offline getestet, **kein echter Decoder**.
Modell-/Backend-/Tokenizer-Kompatibilitaet sowie kreative Qualitaet bleiben
offen. Ein lokaler Ollama-Endpunkt ist nicht automatisch ein Drop-in-Ersatz
fuer diesen Outlines-Transformers-Adapter; separaten Backend-Vertrag pruefen.

## 6. Warum kein pauschaler Token-Whitelist-LogitsProcessor?

Token sind oft Teilwoerter, Leerzeichen oder Bytefragmente, keine Silben oder
Phoneme. Dieselbe Endung kann je nach vorangehendem Text anders tokenisiert
sein. Eine globale statische Whitelist kann den ganzen Wortschatz sperren,
EOS verhindern oder alle Scores auf negativ unendlich setzen. Das ist kein
korrekter Reim-/Metrum-Algorithmus. Ein allgemeiner eigener Hard-Mask-Processor
wird deshalb nicht als fertiges Werkzeug registriert.

Verwendete Grammatik/Regex muss zum Backend passen; danach trotzdem phonetisch
und metrisch pruefen. Soft Bias kann Vorschlaege wahrscheinlicher machen,
erzwingt aber keine harte Eigenschaft. Natuerliche Kadenz und Sinn brauchen
zusaetzlich Hoer-/Textreview. Keine reine Buchstabenheuristik als IPA ausgeben.

## 7. Anschluss an KI und Audio-Chain

```text
Nutzerparameter -> Creative-Prompt / vorhandener lokaler Agent
  -> optionales begrenztes Structured Decoding
  -> unabhaengige Offline-Pruefung -> menschliches Text-/Skansionsreview
  -> freigegebene Lyrics + Noten/Timing -> vorhandene Audio-Chain
```

[Qwen / DeepSeek / MiniMax](models/README.md) bleiben Modell-Backends, kein
Reimnachweis. Der Prompt ist keine Freigabe fuer Shell-, MCP-, Cloud- oder
Dateischreibzugriffe. Keine automatische Installation durch einen Agenten.

[OpenUtau / DiffSinger / RVC / UVR5 / FFmpeg](tools/local-audio-chain.md)
verwenden anschliessend freigegebene Texte und musikalische Daten. Eine Strophe
ist kein fertiger Score, kein kompatibles DiffSinger-Projekt und keine
Stimmenmodellfreigabe. Silben muessen noch auf Noten, Phoneme und Gesangs-
Aussprache abgestimmt werden. Keine automatische Uebernahme in laufende Jobs.

Im vorhandenen [AI-Singer-Profil](Profile/AI_Singer.md) sind diese Hilfen als
**optionales Zubehoer dokumentiert**, nicht als automatisch gestartete Tools.
Ein spaeterer MCP-Adapter benoetigt feste Schemas, begrenzte Dateipfade und
separate Freigaben; in diesem Patch wird keiner behauptet oder gestartet.

## 8. Rollback, Ressourcen und Nachweis

Der Offline-Pruefer speichert nichts. Eigene Lyrics, Lexika und Modellartefakte
ausserhalb des Repos versionieren/sichern. Zurueckrollen durch Auswahl des
vorigen freigegebenen Prompt-/Lexikon-/Code-Digests; keine Benutzerverzeichnisse
pauschal entfernen. Quelltools nur ueber ihre besitzgeprueften Uninstaller.

Grenzen: eine Strophe mit 2-16 Zeilen, Lexikon maximal 512 Eintraege,
Konfigurationsdateien maximal 64 KiB, Entwurf maximal 8 KiB und begrenzte
Endwortpools. Regex-Literale werden aus geprueften Woertern escaped; keine
beliebige Regex, kein `eval`, kein Shell- oder Subprocess-Aufruf im Pruefer.
Lexikongruppen sind menschliche Annahmen; gefaelschte Lexikoneintraege wuerden
keine reale Aussprache beweisen. Deshalb auch ein formal gueltiger Bericht
keine allgemeine Phonetik-/Metrik-Garantie.

Tests pruefen Grenzen, Zeilen, Endwoerter, IPA-/Silbenmetadaten, unvollstaendige
Pruefungen, begrenzte Wiederholungen und den Quellen-Lifecycle. Kein echter
Modell-/GPU-/Audio-/Phonetik-Lauf, kein Paketbuild, kein Trainingsnachweis.
Prompt und Validator sind keine automatisierte Fine-Tuning-Datenfreigabe;
[Datenrechte, Qualitaet und Holdouts](models/TRAINING_AND_EVALUATION.md) pruefen.
