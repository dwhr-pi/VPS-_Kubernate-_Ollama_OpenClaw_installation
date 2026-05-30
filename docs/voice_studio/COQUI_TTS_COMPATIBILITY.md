# Coqui TTS Kompatibilitaet

## Kurzfassung

Coqui TTS / XTTS ist optional und experimental. Auf Ubuntu 24.04 ist die Standardinstallation meist nicht moeglich, weil Ubuntu 24.04 `python3` als Python 3.12 liefert.

Das PyPI-Paket `TTS==0.22.0` benoetigt:

```text
Python >=3.9,<3.12
```

Erlaubt sind also:

- Python 3.9
- Python 3.10
- Python 3.11

Nicht passend:

- Python 3.12

## Erwartete Fehlermeldung

Wenn nur Python 3.12 vorhanden ist, soll der Installer abbrechen:

```text
Fehler: Kein kompatibles Python fuer Coqui_TTS gefunden.
Erforderlich: Python 3.9, 3.10 oder 3.11 mit venv-Modul.
Coqui_TTS bleibt deshalb optional/experimental. Stabilerer lokaler TTS-Pfad: Piper.
```

Das ist ein Schutzmechanismus. Der Installer verhindert damit einen langen, aber vorhersehbar scheiternden `pip install`.

## Systempruefung vor der Installation

`scripts/tools/coqui_tts_install.sh` prueft vor dem Start:

- kompatibles Python: `python3.9`, `python3.10`, `python3.11`
- `venv`-Modul
- freien Linux-/WSL-Speicher
- freien Windows-Host-Speicher auf `C:` bei WSL
- vorhandene inkompatible Coqui-venv

## Empfohlener Pfad

1. Fuer lokale Sprachausgabe zuerst Piper nutzen.
2. Coqui nur testen, wenn Python 3.9-3.11 sauber vorhanden ist.
3. Voice-Cloning nur mit eigener Stimme oder dokumentierter Einwilligung.
4. Modelle und Rohdaten unter `~/.openclaw_ultimate_user_data/voice_studio/` speichern, nicht im Repo.

## Pruefbefehle

```bash
python3 --version
python3.11 --version
python3.11 -m venv --help
```

Wenn `python3.11` fehlt, ist Piper der sichere Weg. Ein manuelles Python-Setup sollte erst dokumentiert und getestet werden, bevor es ins Installationsmenue aufgenommen wird.

