# Medien-Tools fehlen in der Installiert-Liste

## Ursache und Korrektur

Einige Medieninstaller schreiben ihren Erfolgsmarker, waehrend die speziellen Erfolgsmeldungen im
Menue die Textliste `installed_tools.txt` nicht ergaenzten. Gruppenansichten lasen ebenfalls nur
diese Liste. Deshalb konnten korrekt vorbereitete Tools fehlen und wurden nicht zur Deaktivierung
angeboten.

Das Menue gleicht jetzt die bekannten privaten Erfolgsmarker ab: beim Oeffnen der
Gesamt-/Gruppenauswahl, vor Gruppenaktionen und unmittelbar nach erfolgreicher Installation. Beide
Statusdateien werden aktualisiert. Auch direkt gestartete Installer werden so beim naechsten
Menueaufruf erkannt.

Abgedeckt: ChatTTS, AudioLDM2, AudioGen, Moshi, MOSS_TTS, YuE, ACE_Step_15, WhisperX, Aegisub,
Basic_Pitch, Sfizz, AIDA_X, Kiwi_Edit, VOID_Model und Just_Dub_It; ausserdem Stable_Audio_Open,
ProPainter, Alexandria_Audiobook, Qwen3_TTS sowie die bereits unterstuetzten privaten
Basisinstaller.

`MoshiTTS` ist kein eigener Registryname: `Moshi` und `MOSS_TTS` sind zwei verschiedene Projekte und
werden getrennt erfasst. Eine Lizenzannahme fuer Just_Dub_It ist kein Installationsnachweis; erst
der Erfolgsmarker registriert die vorbereiteten Basispakete. Fehlgeschlagene/partielle
Installationen ohne Marker werden nicht faelschlich als erfolgreich bezeichnet.

## Bedienung

Nach Uebernahme der Korrektur Tools-Auswahl bzw. Gruppe erneut oeffnen. Tools mit vorhandenem
Erfolgsmarker erscheinen ausgewaehlt und koennen abgewaehlt werden. Dabei wird der jeweilige
bestehende Uninstaller aufgerufen. Viele experimentelle Installer deaktivieren nur ihre Marker und
behalten Quellen, venv, Modelle, Medien und Logs. Das ist keine Vollbereinigung. Nach Entfernung des
Markers verschwindet der Eintrag auch dann, wenn der Quellordner erhalten bleibt. Die Registry
prueft dafuer ebenfalls den Marker statt bloss die Existenz eines Ordners.

Der Status bestaetigt nur den dokumentierten Installationsumfang (z. B. Quellcode/Basispaket), nicht
Inferenz, Modelle, Audiohardware oder GPU. Fuer Integritaets-/Runtime-Pruefungen den jeweiligen
Doctor gezielt starten.

## Aufwand und Grenzen

Der schnelle Abgleich liest nur lokale Marker und Statusdateien. Keine Git-, pip-, Netzwerk-,
Docker-, Modell- oder Dienstpruefungen. Ein gemeinsamer Durchlauf schreibt hoechstens beide
Statusdateien einmal, unveraenderte Dateien werden nicht ersetzt. Keine Quellen oder Nutzdaten
werden geloescht. Alte /opt-/Docker-Installationen werden nicht als private GitHub-Installation
ausgegeben. Fehlende Marker oder fremde Pfade manuell mit dem Doctor pruefen, nicht durch blindes
Anlegen eines Markers umgehen.
