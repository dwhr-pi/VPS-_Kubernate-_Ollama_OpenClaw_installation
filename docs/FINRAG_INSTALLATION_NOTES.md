# FinRAG Installation Notes

## Fehlerbild

Unter Ubuntu 24.04/Noble kann FinRAG mit dem Standard-Python fehlschlagen:

```text
ERROR: Package 'finrag' requires a different Python: 3.12.3 not in '<3.12,>=3.10'
```

Das bedeutet: FinRAG erlaubt aktuell Python `>=3.10` und `<3.12`. Ubuntu 24.04 bringt standardmaessig Python `3.12` mit, was fuer dieses Paket zu neu ist.

## Sicherer Installationspfad

Das Setup ersetzt kein System-Python. Stattdessen prueft der Installer zuerst auf kompatible Python-Versionen:

1. `FINRAG_PYTHON_BIN`, falls gesetzt
2. `python3.11`
3. `python3.10`

Wenn nichts davon vorhanden ist, baut der Installer ein isoliertes CPython 3.11 aus GitHub:

```text
Quelle: https://github.com/python/cpython.git
Tag:    v3.11.9
Ziel:   /opt/openclaw-python/python-3.11.9
Binary: /opt/openclaw-python/python-3.11.9/bin/python3.11
```

Dieses Python wird nur fuer die FinRAG-Venv genutzt. `/usr/bin/python3` bleibt unveraendert.

## Sudo-Pruefung vor langem Build

Der CPython-Build kann einige Minuten dauern. Der Installer prueft deshalb
`sudo` jetzt direkt vor dem Build mit `sudo -v`. Wenn das Passwort falsch
eingegeben wird, etwa durch CapsLock oder Tastaturlayout, bricht der Installer
sofort ab und nicht erst nach `make`.

Nach dem Anlegen und Uebergeben von `/opt/openclaw-python` an den aktuellen
Benutzer laeuft `make altinstall` ohne spaetes `sudo`. Dadurch bleibt der
isolierte Python-Pfad sicher vom System-Python getrennt, aber der Build scheitert
nicht mehr erst ganz am Ende an einer abgelaufenen sudo-Sitzung.

Beispiel:

```bash
FINRAG_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/finrag_install.sh
```

Version und Ziel koennen bewusst angepasst werden:

```bash
FINRAG_CPYTHON_VERSION=3.11.9 \
FINRAG_CPYTHON_BASE_DIR=/opt/openclaw-python \
bash scripts/tools/finrag_install.sh
```

## Vorabpruefung

```bash
bash scripts/tools/finrag_install.sh --check
bash scripts/tools/finrag_install.sh --dry-run
```

## Ressourcenbedarf

| Bereich | Empfehlung |
| --- | --- |
| Python | 3.10 oder 3.11 |
| RAM | 4 GB Minimum, 8 GB+ empfohlen |
| Speicher | 4 GB+ fuer CPython-Build, Quelle, Venv und Abhaengigkeiten |
| Ports | keine Standardports |
| WSL2 | geeignet, wenn Python 3.10/3.11 vorhanden ist |

## Warum kein automatisches Python-Downgrade?

Python ist Teil des Ubuntu-Basissystems. Ein Ersetzen oder Downgrade von `python3` kann Paketverwaltung und Systemtools beschaedigen. Deshalb baut das Setup bei Bedarf ein separates Python unter `/opt/openclaw-python` und verwendet es nur fuer FinRAG.
