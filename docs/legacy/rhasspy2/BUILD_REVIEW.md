# Rhasspy 2: getrennte Legacy-Pruefung

Nutzerentscheidung vom 24.10.2026: **Rhasspy 2 separat als Legacy-Projekt weiter pruefen**, nicht
durch einen anderen Sprachstack ersetzen. Kein Docker, kein Eingriff in die normale
Ubuntu-24.04-/WSL-Installation und keine Freigabe eines noch ungetesteten Installers.

[Dringlichkeit und Vergleich der zwei Wege](../../tools/rhasspy-options.md): P0 fuer
Profilsicherung/Isolation, P1 fuer reproduzierbare Build- und Funktionsabnahme; moderner Sprachstack
nur als separat freizugebende Option.

## Bereits geprueft

Das [Quelleninventar](source-inventory.json) enthaelt den festen Hauptcommit
`083721a92a9a12396c794003a7f9ebcdd8dffa60`, die SHA256-Werte von sechs gelesenen
Build-/Metadatendateien und **35 oberste Submodule** mit ihren Gitlink-Commits und offiziellen
GitHub-URLs. Die Gitlinks stammen aus dem GitHub-Git-Tree dieses Hauptcommits, nicht aus den
heutigen master-Staenden.

Das ist ein statischer Quellenbefund. Es wurden keine rekursiven Submodule, Buildarchive, Wheels,
Sprachmodelle oder Runtime-Pakete installiert. Die Inventar-Hashes beziehen sich auf die gelesenen
UTF-8-Quelldateien; sie sind keine Signaturpruefung und keine Pruefsummen freigegebener
Buildarchive.

## Konkrete Build-Hindernisse

| Befund                                                                                                        | Quelle                                                                                                                                                                                                                           | Konsequenz fuer einen eigenen Build                                                                   |
| ------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Python-Hinweis 3.7.7, Paketklassifikatoren 3.7/3.8                                                            | [.python-version](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/.python-version), [setup.py.in](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/setup.py.in) | Eine historische Vergleichsumgebung pruefen; nicht Ubuntu 24.04 auf altes System-Python umbauen.      |
| Virtuelle Umgebung wird mit --clear erstellt; pip <=20.2.4, setuptools/cython nicht vollstaendig gepinnt      | [Makefile.in](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/Makefile.in)                                                                                                                      | Nur neue, eindeutig eigene Venv-Pfade; vor Ausfuehrung einen getesteten Buildwerkzeug-Lock erstellen. |
| In-place bezieht Rhasspy-Module aus den Submodulen; sonst Versionsbereiche bzw. aktuelle Pakete aus PyPI      | [setup.py.in](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/setup.py.in)                                                                                                                      | Haupt- und Submodul-Pins allein sperren noch nicht alle transitiven Abhaengigkeiten.                  |
| Archivsources teilweise per HTTP oder raw/master; voreingestellter curl-Befehl prueft keine SHA256            | [Makefile.in](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/Makefile.in)                                                                                                                      | HTTP nicht ausfuehren; Quellen durch gepruefte feste HTTPS-Artefakte ersetzen und Hashes festhalten.  |
| --disable-precompiled-binaries waehlt weitere historische Source-Archive, nicht automatisch gepruefte Commits | [Installationsanleitung](https://rhasspy.readthedocs.io/en/latest/installation/) und Makefile                                                                                                                                    | Source-Build ist nicht automatisch reproduzierbar oder nur auf GitHub beschraenkt.                    |
| Viele Engines werden architekturabhaengig aktiviert                                                           | [configure.ac](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/configure.ac)                                                                                                                    | Erst eine klar beschraenkte Komponentenkombination pruefen statt alle STT-/Wake-Engines gleichzeitig. |

Die Downloadvorlagen und ihre Fundzeilen stehen im Inventar. `sha256: null` bedeutet **noch nicht
geprueft und nicht freigegeben**. Die Dateinamenvariable DOCKER_ARCH im historischen Makefile ist
allein kein Docker-Aufruf; das native Make-Verfahren muss dennoch separat auf Nebenwirkungen
geprueft werden.

## Abnahmestufen

1. Quellenaufnahme: Hauptcommit, 35 Gitlinks und sechs Builddateien erfasst. Weitere Submodule,
   transitive Python-Pakete und Archive noch offen.
2. Reproduzierbarer Lock: passende private Python-/Buildwerkzeuge und nur benoetigte Abhaengigkeiten
   mit Hashes festlegen; keine unkontrollierten Netzwerkdownloads waehrend des Builds.
3. Historische Vergleichsumgebung: abgeschottete Wegwerf-VM mit der dokumentierten
   Ubuntu-20.04-/Python-3.8-Generation als Testbasis pruefen, nicht als neue Produktionsfreigabe
   behandeln.
4. Minimaler Rhasspy-Kern: Web-/MQTT-/Intent-Verhalten ohne Mikrofonzugriff, Cloud, Modell- oder
   Hardwarestart testen. Ein Kernpaket allein zaehlt noch nicht als voller Sprachassistent.
5. Eine lokale Sprachpipeline: genau eine STT-/TTS-/Audio-Kombination hinzufuegen und mit
   freigegebenen Testdateien Ende-zu-Ende pruefen; Wake Word erst separat.
6. Zielabnahme Ubuntu 24.04/WSL: entweder isolierte private Legacy-Umgebung verifizieren oder
   inkompatible Punkte explizit ausweisen. Erst dann einen eigenen, klar benannten experimentellen
   Installer anbieten.

Die alte OS-/Python-Generation und das archivierte Projekt benoetigen eine eigene
Sicherheitsbewertung. Kein oeffentlicher Dienst, keine echten Tokens, kein Zugriff auf
Produktivprofile. Modellgroessen und Speicherbedarf sind noch nicht gemessen; die jetzige
4-GiB-Menue-Vorpruefung ist keine Freigabe fuer einen vollstaendigen Legacy-Build auf dem knappen
Windows-Laufwerk.

## Aktueller Status

Nur Quellenanalyse und Buildplanung abgeschlossen. **Kein erfolgreicher Legacy-Build, keine
Import-/Audio-Abnahme und kein neuer Installationsmarker.** Der vorhandene Rhasspy-Menueeintrag
bleibt sichtbar und blockiert. Update, Deinstallation oder eine geplante Legacy-Pruefung duerfen
vorhandene Profile und Container nicht stillschweigend veraendern.

Zurueck: [Rhasspy-Status im Setup](../../tools/rhasspy.md).
