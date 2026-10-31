# Gitleaks: zwei belegte Fehlalarme

Stand: 30.10.2026. Der Scan des Formatierungscommits `73307e5` meldete zwei
Treffer der generischen Regel. Es handelt sich um Beschriftungen, nicht um
Zugangsdaten. Es wurden keine privaten Keys oder Providerkonten abgefragt.

## Nachweise

- `CHANGELOG.md`, Zeile 658: eine deutsche Adjektivfolge zur fehlenden oder
  inkompatiblen Node-Basis. Die gleiche Formulierung ist bereits im Stand
  `6c2ebd4` enthalten. Der Formatter hat den Absatz umgebrochen.
- `scripts/tools/helpers/veo_api_common.sh`, Zeile 285: ein datierter, statischer
  Build-Bezeichner in einer Logausgabe. Die komplette getrimmte Zeile ist mit
  dem Stand `6c2ebd4` identisch. Sie liest keinen Schluessel aus einer Datei
  oder einem Konto; Laufzeitvariablen sind nicht deren statischer Wert.

Belege im [fehlgeschlagenen Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40977373164/job/123808646458).
Es werden bewusst keine vermeintlichen Schluesselwerte aus Scannerlogs kopiert.

## Enger Geltungsbereich

[`.gitleaksignore`](../../.gitleaksignore) enthaelt genau zwei Fingerprints:
vollstaendiger Commit, Datei, Regel und Zeile. Es gibt keine Wildcards, keine
Datei- oder Regel-Whitelist und keine Ausnahme fuer echte Zugangsdaten.
Ein neuer Fund in einem anderen Commit oder an anderer Stelle bleibt ein Fehler.
Die Originalhistorie wird nicht umgeschrieben; die Scan-Gates bleiben aktiv.
Der naechste GitHub-Lauf muss die Einordnung bestaetigen. Andere CI-Befunde
werden durch diese gezielte Ausnahme nicht behoben.
