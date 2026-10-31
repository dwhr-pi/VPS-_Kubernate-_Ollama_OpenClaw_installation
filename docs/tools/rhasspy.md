# Rhasspy 2: Legacy-Integration noch blockiert

Rhasspy 2 ist ein lokaler Sprachassistent mit MQTT-/Hermes-Anbindung und auswaehlbaren Komponenten
fuer Mikrofon, Wake Word, Spracherkennung, Absichtserkennung und Sprachausgabe. Ein
Quellcode-Checkout allein liefert deshalb noch keinen funktionsfaehigen Sprachassistenten.

**Dringlichkeit und beide Wege:**
[Optionen mit Prioritaeten und Bausteinvergleich](rhasspy-options.md). Datenschutz, Profilsicherung
und isolierte Buildpruefung haben Vorrang vor einer schnellen Installationsfreigabe. Die gewaehlte
Legacy-Pruefung bleibt bestehen; ein moderner Stack wird nicht automatisch als Ersatz installiert.

## Was das Installationslog bedeutet

Das Log vom 24.10.2026 um 01:14 zeigt eine **bewusste Installersperre**, keinen Speicher-, Netzwerk-
oder Compilerfehler. Der Eintrag ist sichtbar, aber weiterhin `planned` /
`native-migration-blocked`. Es gibt in unserem Setup noch kein abgenommenes natives
Rhasspy-2-Buildrezept fuer Ubuntu 24.04. Das ist eine offene Implementierung, keine erfolgreich
abgeschlossene GitHub-Umstellung. Die Installationsmeldung nennt jetzt die konkreten Gruende.

Auch das Log vom **24.10.2026 um 05:09** zeigt denselben offenen Stand. Es ist kein neuer Fehler
durch die Caddy-/Go-Reparaturen. Der Installer hat weder den Rhasspy-Build gestartet noch einen
fehlenden Compiler oder ein unpassendes Python nachgewiesen. Die rund 5,2 GiB auf C: sind knapp,
aber nicht die Ursache dieses konkreten Abbruchs. Ein erneuter Klick auf Installieren oder
`--install-build-deps` kann das fehlende Buildrezept nicht ersetzen. Die
Source-only-Inventarisierung ist keine fertige Installation.

Kein Download, apt/pip, Docker-Fallback, Modellstart oder Erfolgsmarker wird durch diesen
blockierten Weg ausgefuehrt. Alte Container, `/opt/rhasspy`, Profile, Volumes, Secrets und Logs
bleiben unangetastet. Der blockierte Uninstall-Pfad loescht auch keine Altinstallation.

## Offizielle Quellen und ihre Grenzen

Geprueft am 24.10.2026:

- Das [offizielle Repository](https://github.com/rhasspy/rhasspy) wurde am 06.10.2025 archiviert und
  ist schreibgeschuetzt.
- Die [offizielle Installationsanleitung](https://rhasspy.readthedocs.io/en/latest/installation/)
  beschreibt **auch einen nativen GitHub-/venv-Build**, nicht ausschliesslich Docker. Der
  WSL-Abschnitt nennt Ubuntu 20.04/WSL2 als getestete Umgebung. Das belegt keine Abnahme fuer Ubuntu
  24.04.
- Der
  [untersuchte Altstand](https://github.com/rhasspy/rhasspy/tree/083721a92a9a12396c794003a7f9ebcdd8dffa60)
  nennt in
  [.python-version](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/.python-version)
  Python 3.7.7. Das ist eine historische Entwicklungsangabe, kein Beweis, dass jede neuere
  Python-Version ausgeschlossen ist.
- Die
  [Requirements](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/requirements.txt)
  enthalten unter anderem DeepSpeech 0.9.3, SciPy 1.5.1 und PyAudio 0.2.11. Deren Installation und
  Zusammenspiel mit aktuellen Compilern, Python und Audiobibliotheken muessen separat geprueft
  werden.
- Die
  [Buildkonfiguration](https://github.com/rhasspy/rhasspy/blob/083721a92a9a12396c794003a7f9ebcdd8dffa60/configure.ac)
  aktiviert zahlreiche Sprachkomponenten je nach Architektur. Ein einfaches `pip install` oder das
  Entfernen nicht aufloesbarer Requirements ist kein gleichwertiger Ersatz fuer diesen Gesamtstack.

Die ebenfalls beschriebenen fertigen Debian-Pakete sind ein anderer Installationsweg als der
angefragte Source-Build. Sie werden hier nicht ungeprueft mit Rootrechten installiert. Historische
WSL-Audio-Anweisungen nicht unveraendert uebernehmen, insbesondere keine anonym erreichbare
PulseAudio-Netzwerkschnittstelle einrichten.

## Moegliche Fortsetzung: isoliertes Legacy-Projekt

Am 24.10.2026 wurde die getrennte Legacy-Pruefung ausdruecklich gewaehlt. Die
[laufende Buildpruefung mit Quelleninventar](../legacy/rhasspy2/BUILD_REVIEW.md) haelt Hauptcommit,
35 Gitlinks und konkrete Download-/Venv-Hindernisse fest. Es wird kein anderer Sprachstack
automatisch als Ersatz installiert.

Fuer eine echte GitHub-basierte Rhasspy-2-Integration sind noch erforderlich:

1. Einen verbindlichen Quellstand samt Submodul-Commits und Build-Downloads festlegen.
2. Nur eine separat verwaltete, geeignete Python-/Buildumgebung verwenden; System-Python nicht
   ersetzen.
3. Die tatsaechlich benoetigten STT-, TTS-, Wake- und Audio-Komponenten begrenzen und ihre
   Downloads/Lizenzen pruefen.
4. Build, Import, Prozesse, MQTT und Audio in einer Wegwerf-Umgebung testen, anschliessend
   Ubuntu-/WSL-Abnahme.
5. Authentifizierung, localhost-/VPN-Bindung, Profile, Datensicherung und Restore separat pruefen.

Erst danach darf ein Buildrezept einen Installationsmarker erzeugen. Eine fehlende
Ubuntu-24.04-Abnahme bedeutet nicht, dass native Installation prinzipiell unmoeglich ist. Sie
bedeutet, dass unser Installer sie derzeit nicht zuverlaessig leisten kann.

## Alternative: neuer lokaler Sprachstack

Ein neuer Stack mit STT, TTS und optional Wake Word ist eine **getrennte Integration**, kein
heimlicher Rhasspy-Ersatz. Im Katalog existieren unter anderem faster-whisper und Piper sowie
geplante Eintraege fuer Wyoming und openWakeWord. Die vorhandenen Eintraege belegen noch keinen
fertig orchestrierten, getesteten Sprachassistenten. Auch diese Komponenten brauchen eigene
Quellen-, Modell-, Audio- und Datenschutzpruefungen.

## Nur Plan und Status ansehen

```bash
bash scripts/tools/rhasspy_install.sh --dry-run
bash scripts/tools/rhasspy_status.sh
bash scripts/tools/rhasspy_doctor.sh
```

Nach Uebernahme der aktualisierten Dateien liefert **Doctor** zusaetzlich `legacy_review` mit der
Einstufung `implementation-blocked`, dem bereits erfassten Quellcommit, der Anzahl inventarisierter
Submodule und den noch offenen Abnahmeschritten. Fuer einige Buildwerkzeuge wird nur geprueft, ob
sie im PATH vorhanden sind; sie werden nicht ausgefuehrt. Die angezeigte Python-Version gehoert zum
Setup-Interpreter und ist kein Rhasspy-Test. Selbst wenn alle Werkzeuge vorhanden sind, bleiben
`installation_enabled` und `runtime_verified` ausdruecklich **false**.

Der Doctor liest nur lokale Metadaten. Kein Download, Build, Profilzugriff, Mikrofon-/USB-/MQTT-Test
oder Schreibzugriff auf Userdaten wird ausgefuehrt. Exitcode **1** bedeutet hier weiterhin: keine
freigegebene Runtime vorhanden, nicht: die Diagnose habe etwas installiert oder repariert.

Ein ausdruecklicher Installationsversuch bleibt mit dem konkreten Blocker fehlgeschlagen; es wird
kein Erfolg vorgetaeuscht. Mehr Speicher, cmake, Go oder `--install-build-deps` heben diese
Implementierungssperre nicht auf. Siehe [Migrationsuebersicht](../DOCKER_TO_GITHUB.md).
