# FinRobot Installation Notes

## Fehlerbild

Unter Ubuntu 24.04/Noble kann FinRobot mit dem Standard-Python fehlschlagen:

```text
ERROR: Package 'finrobot' requires a different Python: 3.12.3 not in '<3.12,>=3.10'
```

FinRobot erlaubt aktuell Python `>=3.10` und `<3.12`. Ubuntu 24.04 bringt standardmaessig Python `3.12` mit, was fuer dieses Paket zu neu ist.

## Sicherer Installationspfad

Der Installer prueft zuerst auf kompatible Python-Versionen:

1. `FINROBOT_PYTHON_BIN`, falls gesetzt
2. `python3.11`
3. `python3.10`

Beispiel:

```bash
FINROBOT_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/finrobot_install.sh
```

## Vorabpruefung

```bash
bash scripts/tools/finrobot_install.sh --check
bash scripts/tools/finrobot_install.sh --dry-run
```

## Ressourcenbedarf

| Bereich | Empfehlung |
| --- | --- |
| Python | 3.10 oder 3.11 |
| RAM | 4 GB Minimum, 8 GB+ empfohlen |
| Speicher | 2 GB+ fuer Quelle, Venv und Abhaengigkeiten |
| Ports | keine Standardports |
| WSL2 | geeignet, wenn Python 3.10/3.11 vorhanden ist |

## Warum kein automatisches Python-Downgrade?

Python ist Teil des Ubuntu-Basissystems. Ein automatisches Ersetzen oder Downgrade von `python3` kann Paketverwaltung und Systemtools beschaedigen. Deshalb bleibt FinRobot optional und installiert nur mit explizit kompatiblem Python.

