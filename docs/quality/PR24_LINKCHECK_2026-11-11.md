# PR 24: Quellen-Nachpruefung am 11.11.2026

Basis: `ca91555c3f6ab5b5af79622f8b1ede8fc7cd7a4c`.
Keine Installation, Anmeldung, Provider-Inferenz oder Rechtsfreigabe.
Der Linkchecker, Erfolgsstatus und Ignore-Regeln werden nicht geaendert.

## CI-Nachweise

- Erster Push-/PR-Versuch: ScamAdviser zu token8341.com lieferte HTTP 522.
  Der separate anonyme GET vom 11.11. lieferte anschliessend HTTP 200.
  Die URL bleibt ein aktiver Link, kein globaler Ausfall wird behauptet.
- [PR-Versuch 2, Job 130423315111](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup/actions/runs/42985239758/job/130423315111?pr=24):
  zwei Godot-Webseiten HTTP 429; vier amtliche EU-Metadatenseiten
  Transportstatus 0 bzw. HTTP 502.
- [Erster Push-Lauf](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup/actions/runs/42985169456)
  und [PR-Lauf](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup/actions/runs/42985239758?pr=24)
  bleiben als Originalprotokolle erhalten. Wiederholungen koennen andere
  externe Abruffehler liefern; dies ist kein Buildfehler der Plattform.
- Der direkte anonyme GET auf jede der vier EU-Metadatenseiten lieferte
  ebenfalls HTTP 502. Keine der Seiten wird deshalb frisch inhaltsverifiziert.
- Auch Push-Versuch 2, Job `130429822865`, scheiterte ausschliesslich an
  denselben vier EU-Metadatenseiten mit HTTP 502 bzw. HTTP 504.
  ScamAdviser war in diesem Versuch kein fehlgeschlagener Link.

## Godot: gleicher Inhalt aus offizieller Quelle

Die beiden RST-Dateien wurden im offiziellen Repository am festen Commit
`6d86d7c7f3b8f4f56c71e113022d72fe80b2c84d` gelesen:
Linux-/BSD-Buildvoraussetzungen und XR-Initialisierung samt Fehlergrenzen.
Keine Ausfuehrung von Befehlen aus den Dokumenten.

| Urspruengliche Webadresse | Gepruefte offizielle Dokumentationsquelle |
| --- | --- |
| `https://docs.godotengine.org/en/stable/engine_details/development/compiling/compiling_for_linuxbsd.html` | [Linux/BSD am Pin](https://github.com/godotengine/godot-docs/blob/6d86d7c7f3b8f4f56c71e113022d72fe80b2c84d/engine_details/development/compiling/compiling_for_linuxbsd.rst) |
| `https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html` | [XR am Pin](https://github.com/godotengine/godot-docs/blob/6d86d7c7f3b8f4f56c71e113022d72fe80b2c84d/tutorials/xr/setting_up_xr.rst) |

Die Originaladressen bleiben auch im urspruenglichen Leitfaden erhalten.
Der Dokumentationspin bestaetigt weder den lokalen Build noch die GPU-/XR-Runtime.

## EU-Metadaten: historischer Nachweis, aktuell nicht verifiziert

Die am 30.10.2026 zugeordneten Metadatensaetze bleiben mit exakter Adresse
und Dokumentidentitaet erhalten. Es wird kein beliebiger Ersatzlink und keine
private Gesetzessammlung als amtlicher Volltext ausgegeben.
Der damalige Titel-/CELEX-Abgleich wird nicht nachtraeglich geloescht,
aber auch nicht als neue Inhaltspruefung am 11.11. dargestellt.
Die ELI-/CELEX-Originaladressen bleiben in den bisherigen Dokumenten erhalten.

### DSGVO

Originaler Metadatensatz zur Verordnung 2016/679:
`https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de`.
CI: Transportstatus 0; separate Nachpruefung: HTTP 502.
Der getestete englische ELI-PDF-Pfad lieferte HTTP 202/Bot-Pruefung,
nicht den verifizierten Volltext.

### AI Act

Originaler Metadatensatz zur Verordnung 2024/1689:
`https://op.europa.eu/en/publication-detail/-/publication/dc8116a1-3fe6-11ef-865a-01aa75ed71a1/language-de`.
CI: Transportstatus 0 und HTTP 502; separate Nachpruefung: HTTP 502.
Getestete deutsche und englische Volltextwege zeigten eine Bot-Pruefung.

### DSM

Originaler Metadatensatz zur Richtlinie 2019/790:
`https://op.europa.eu/en/publication-detail/-/publication/214471fe-786e-11e9-9f05-01aa75ed71a1/language-de`.
CI und separate Nachpruefung: HTTP 502.
Das Recherchewerkzeug konnte eine deutsche Amtsblatt-PDF-Fassung anzeigen;
der separate englische ELI-PDF-GET lieferte hingegen HTTP 202.
Daraus folgt kein zuverlaessiger neuer CI-/Volltextpfad.

### NIS-2

Originaler Metadatensatz zur Richtlinie 2022/2555:
`https://op.europa.eu/en/publication-detail/-/publication/9b84d482-85bd-11ed-9887-01aa75ed71a1/language-de`.
CI: Transportstatus 0; separate Nachpruefung: HTTP 502.
Getestete Volltextwege zeigten eine Bot-Pruefung statt verlaesslichem Inhalt.

Diese vier Metadatenseiten sind deshalb einzeln als **unverifizierte
Originalreferenzen** dokumentiert, nicht als aktive frische Inhaltsbelege.
Das ist keine Ausnahme fuer die Domain oder HTTP-Fehler.
Es ist keine Aussage, dass die Gesetze ungueltig oder die Portale dauerhaft
ausgefallen seien. Aktueller konsolidierter Text, Anwendbarkeit und nationale
Umsetzung bleiben separat zu pruefen.

## Grenzen und Regression

Separat getestete englische ELI-PDF-Adressen, jeweils HTTP 202 am 11.11.2026:

- `https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng/pdf`
- `https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng/pdf`
- `https://eur-lex.europa.eu/eli/dir/2019/790/oj/eng/pdf`
- `https://eur-lex.europa.eu/eli/dir/2022/2555/oj/eng/pdf`

Die Dokumentkorrektur erhaelt Originale und ihre Abrufgrenzen. Offline-Tests
pruefen die vier exakten Metadatenadressen, die zwei Godot-Ersatzquellen
und unveraenderte Fail-Closed-Regeln. HTTP 202, 403, 429, 502 und 522 werden
nicht zu Erfolgen umgedeutet. Kein Test ersetzt den naechsten GitHub-Lauf.

Lokal ausgefuehrt: 20 Link-Policy-, 11 Online-Doku-, 29 RAG-/Quellen- und
9 Inventar-Fixtures sowie 7 unveraenderte Node-Retry-Tests: **76 bestanden**.
Die zwei neuen Godot-Repository-Links lieferten beim separaten anonymen GET HTTP 200.
Keine Aussage ueber erfolgreiche gesamte GitHub-CI aus diesen Einzeltests.
