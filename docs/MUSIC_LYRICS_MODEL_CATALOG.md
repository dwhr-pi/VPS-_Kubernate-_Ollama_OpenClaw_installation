# Musik- und Lyrics-Forschungswerkzeuge: Abdeckung und Grenzen

Stand **11.11.2026**. Alle angefragten Namen sind hier eingeordnet. Ein
Menueeintrag ist weder Gewichtsinstallation noch Musik-/GPU-/Sprachabnahme.
Native GitHub-Quellen bleiben Vorgabe; kein Docker-Fallback und kein
automatischer Dienst-, Modell-, GUI-, API-, Audio- oder Trainingsstart.

| Projekt | Setup-Eintrag | Tatsaechlicher Umfang / offene Grenze |
| --- | --- | --- |
| [YuE](tools/yue.md) | `yue`, vorhanden | YuE-v1-Quellen; keine automatische YuE2- oder GPU-Runtime-Umstellung |
| [LeVo 2](tools/levo-2.md) | `levo_2`, neu | Quellen; Lizenz verbietet kommerzielle und produktive Nutzung |
| [ACE-Step 1.5](tools/ace-step-15.md) | `ace_step_15`, vorhanden | Basispaket, keine vollstaendige Musik-Runtime oder Gewichte |
| [MusicGen / AudioCraft](tools/musicgen-source.md) | `musicgen`, bestehende ID neu verdrahtet | Gepruefte Quellen statt planned-Stubs; Legacy-Skripte/Installationen erhalten |
| [AudioGen](tools/audiogen.md) | `audiogen`, vorhanden | Separater AudioCraft-Basispaketpfad; keine automatische MusicGen-Gewichtsfreigabe |
| [MOSS-Music](tools/moss-music.md) | `moss_music`, neu | Musikverstehen / Lyrics-ASR / Strukturfragen, kein Songgenerator |
| [SongSage](tools/songsage.md) | `songsage`, neu geplant | Offizielle GitHub-Quelle/Lizenz nicht bestaetigt; Installationsguard Exit 3 |
| [PoeLM](tools/poelm.md) | `poelm`, neu | Quellen, Spanisch/Baskisch; Code-Lizenz am Root offen |
| [PoeTone](tools/poetone.md) | `poetone`, neu | Quellen fuer chinesische Songci; kein automatischer Cloud-/Trainingslauf |
| [CoPoet](tools/copoet.md) | `copoet`, neu | MIT-Code fuer instruktionsgesteuerte T5-Poesie; Gewichte/Daten separat |
| [CTGS](tools/ctgs.md) | `ctgs`, neu | MIT-Quellen; GUI/Modell-/FastText-Downloads nicht gestartet |
| [Outlines](tools/outlines.md) | `outlines`, vorhanden | Strukturierte-Ausgabe-Quellen; echter Decoder noch nicht abgenommen |
| Logit Bias / Grammar Decoders | Technik, keine zusaetzliche erfundene Tool-ID | [Begrenzter Reim-Pruefer](CREATIVE_LYRICS.md); keine automatische Phonetik-/Metrikgarantie |
| [Qwen Coder](tools/qwen-coder.md) / [Modell-Backends](models/README.md) | Vorhandene getrennte Quellen-/Runtime-Eintraege | Keine automatische Installation von Llama-/Qwen-Gewichten |

## Auswahl statt alles gleichzeitig starten

Song-/Audioerzeugung (YuE, LeVo, ACE-Step, MusicGen), Musikverstehen (MOSS-Music)
und Text-/Constraint-Werkzeuge haben unterschiedliche Aufgaben. Nicht alle
gleichzeitig auf der Heim-GPU laden. Modellgewichte, Codec, Tokenizer, native
Backends, Betriebssystem und CUDA-Version pro Projekt separat planen.

Die neuen Quellen-Tools nutzen feste GitHub-Commit-Pins und SHA256-Vertraege.
Doctor prueft nur Quellenintegritaet. `source_prepared` ist keine Runtime;
`installed: false` und `runtime_tested: false` verhindern eine falsche
Einsatzbereitschaftsaussage im Quellenhandler. Die zentrale Menue-/Registry-
Aufnahme ist keine Freigabe unbeaufsichtigter Headless-Installation.

Keine neuen Gruppen-/Profil-Autostarts. Im vorhandenen AI-Singer-Profil sind
diese Projekte als bewusst auszuwaehlendes Zubehoer verlinkt. Modelle und
Nutzerdaten ausserhalb des Repos ablegen. RAG-/Trainingsdatenrechte bleiben
getrennt von Code-Lizenzen; Forschungs-Paper sind keine Softwarelizenz.

## Gepruefte Primaerzuordnung

[LeVo](https://github.com/levo-demo/LeVo),
[MOSS-Music](https://github.com/OpenMOSS/MOSS-Music),
[PoeLM](https://github.com/aitorormazabal/poetry_generation),
[PoeTone-Code](https://github.com/ZhanQu945/PoeTone) und
[PoeTone-Paper mit Codezuordnung](https://arxiv.org/html/2508.02515v2),
[CoPoet-Projektseite](https://copoet-emnlp.github.io/) mit
[offiziellem Code](https://github.com/vishakhpk/creative-instructions),
[CTGS](https://github.com/Hellisotherpeople/Constrained-Text-Generation-Studio),
[SongSage-Paper](https://arxiv.org/abs/2601.01153).

README-/Lizenzdateien wurden am jeweiligen Pin vollstaendig gelesen, nicht nur
aus Suchsnippets uebernommen. Pins und SHA256 stehen im gemeinsamen
`scripts/tools/helpers/gap_tools.json`; SongSage hat bewusst keinen erfundenen
Pin. Keine Forschungsskripte aus den recherchierten Repositories ausgefuehrt.
