# Notion-Recherche und lokaler Review-Export

Stand: **22.10.2026**. Repository-Werkzeug ohne Paketinstallation:
[scripts/notion_research.py](../../scripts/notion_research.py), Python >=3.10, nur
Standardbibliothek. Keine Notion-Konten, API-Keys oder Scheduler werden automatisch eingerichtet.

## Was fuer dein KI-Setup interessant ist

| Prioritaet | Thema auf Notion                                    | Nutzen / eigener Pruefpunkt                                                      |
| ---------- | --------------------------------------------------- | -------------------------------------------------------------------------------- |
| Hoch       | Agenten-Runbooks und Human-in-the-Loop-Workflows    | Begrenzte Aufgaben, Abnahme, Fehlerpfade und Rechte statt unbegrenzter Autonomie |
| Hoch       | Prompt-/Skill-Bibliotheken mit Tests                | Prompt, Version, Beispielinput, erwartetes Ergebnis und Lizenz zusammenhalten    |
| Hoch       | Architekturentscheidungen und Betriebs-Runbooks     | CLI-, API-, Backup-, Update- und Recovery-Schritte nachvollziehbar vergleichen   |
| Mittel     | Research-Inbox, Quellen- und Wissensgraph-Templates | Herkunft, Datum, Aktualitaet und Zugriffsrechte statt ungepruefter RAG-Masse     |
| Mittel     | Projekt-/Release-Dashboards                         | GitHub-/n8n-Anbindung als optionale Erweiterung, keine neue Pflichtzentrale      |

Konkreter offizieller Einstieg:
[Notion Marketplace: AI-Templates](https://www.notion.com/templates/category/ai). Dort sind Vorlagen
und Anbieterangebote, nicht automatisch lokale Open-Source- Tools. Kostenlos, veroeffentlicht und
zur Weiterverwendung lizenziert sind verschiedene Eigenschaften. Notion AI/Cloud-Agents werden durch
einen lokalen Markdown-Export nicht lokal nachgebaut. Einzelne Vorlagen hier nicht als gebaut,
sicher oder fuer dein Setup getestet ausgeben.

Deine [Ruflo-Notion-Quelle](ruflo.md) bleibt ein Recherchekandidat; deren Inhalt war beim letzten
Abruf nicht lesbar. Daraus wird kein API-Zugriff oder gepruefter Inhalt abgeleitet.

## Oeffentliche Suche und freigegebene API-Inhalte trennen

**Die Notion-API ist keine Suchmaschine fuer das gesamte notion.site.** Die Titelsuche findet
Seiten/Datenquellen, die mit der Verbindung geteilt sind:
[offizielle Search-Referenz](https://developers.notion.com/reference/post-search). Ein eigenes
Integration-Token oeffnet nicht automatisch fremde oeffentliche Seiten.

Fuer die spaetere Recherche durch Qwen/Codex deshalb zwei Schritte: Oeffentliche Links ueber normale
Websuche oder Marketplace finden und lesen, danach nur zugaengliche, rechtlich verwendbare Inhalte
bewusst uebernehmen. Kein Login-/Paywall-/Bot-Schutz-Umgehen und kein plattformweites Scraping. Ein
nicht lesbarer Link bleibt als offene Quelle dokumentiert.

Der hier implementierte API-Weg betrifft **explizit freigegebene Inhalte**. Verbindung mit minimalen
Leserechten anlegen und nur gewuenschte Seiten teilen:
[Notion-Autorisierung](https://developers.notion.com/guides/get-started/authorization). Eine
Leseverbindung bleibt Zugang zu Cloud-Daten; der Abruf ist nicht offline.

## Korrekturen des eingefuegten Skripts

Das Beispiel ist nicht direkt lauffaehig: safe_title verwendet einen ungueltigen
String-/Generatorausdruck, und die print-Zeile ist ebenfalls syntaktisch ungueltig. Weitere
Probleme: fehlende Pagination, verschluckte HTTP-Fehler, kein Timeout, feste Dateinamen mit kurzem
ID-Praefix und fehlende Beleg-/Review-Metadaten. Nicht unterstuetzte Bloecke verschwinden lautlos.

Unser Ersatz nutzt die API-Version **2026-03-11** und
[data_sources/query](https://developers.notion.com/reference/query-a-data-source) statt pauschal das
alte databases/query aus 2022:
[API-Versionierung](https://developers.notion.com/reference/versioning). Data-Source-ID und
Database-ID sind nicht dasselbe; keine automatische Umdeutung. Blocklisten werden separat paginiert
und rekursiv gelesen:
[Blockkinder-Referenz](https://developers.notion.com/reference/get-block-children).

## Direkt aus dem Setup verwenden

Die CLI ist im Repository vorhanden, **kein neuer Installer und kein installierter Notion-Agent**.
Vom Setup-Hauptverzeichnis aus starten. Keine requests-Abhaengigkeit und kein pip/apt/npm notwendig.

Ohne Abruffreigabe bleibt sie ein schreibfreier Plan. Beispiel-ID ist eine synthetische UUID, keine
existierende Quelle:

```text
python -B scripts/notion_research.py --page 11111111-1111-4111-8111-111111111111 --dry-run
python -B scripts/notion_research.py --data-source 22222222-2222-4222-8222-222222222222
python -B scripts/notion_research.py --search-title "agent workflow"
```

Echte UUID und Token bewusst bereitstellen. NOTION_TOKEN nur in einer lokalen
Prozessumgebung/geeigneten Secret-Verwaltung setzen, nicht ins Git, in eine Befehlsargumentliste
oder Chat-Ausgabe. Es gibt keinen eingebauten Token und keinen Platzhalter, der als echter Key
versendet wird. Die CLI liest keine .env-Datei automatisch.

Ein **bewusst freizugebender Cloud-Leseabruf**, hier nicht ausgefuehrt:

```text
python -B scripts/notion_research.py --page ECHTE-SEITEN-UUID --fetch
python -B scripts/notion_research.py --data-source ECHTE-DATA-SOURCE-UUID --fetch --max-pages 10
python -B scripts/notion_research.py --search-title "agent workflow" --fetch
```

Die Platzhalter in den ersten beiden Befehlen vor Verwendung durch echte UUIDs ersetzen. Die
Titelsuche betrifft nur geteilte Seiten, nicht Volltext und nicht alle oeffentlichen Notion-Seiten.
--fetch startet keine Modelle und fuehrt keine Inhalte der Seiten aus. Eine normale API-Abfrage
verwendet teils POST, schreibt damit aber keine Notion-Seite.

## Offline mit synthetischem JSON ausprobieren

[Beispielsnapshot](../../examples/notion-research/sample.json):

```text
python -B scripts/notion_research.py --snapshot-json examples/notion-research/sample.json --dry-run
python -B scripts/notion_research.py --snapshot-json examples/notion-research/sample.json
```

Nur der zweite Befehl schreibt einen lokalen Review-Snapshot, ohne Netzwerk oder Token. Das
JSON-Format enthaelt pages mit id, title und blocks; bereits geladene Unterbloecke stehen unter
children. Es ist kein beliebiger Notion-Workspace-Export-/ZIP-Importer.

Standardziel: `~/.openclaw_ultimate_user_data/notion_review/review-<UUID>/`. Alternativ --output mit
einem Ordner **ausserhalb** des Setup-Repositories. Markdown-Dateinamen verwenden vollstaendige IDs
statt frei steuerbarer Titel. Neue Snapshots ersetzen keine vorhandenen Inhalte. Auf Fehlern werden
eigene unvollstaendige Stagingdateien entfernt; kein fertiger Snapshot publiziert. Keine Dateien
ausserhalb des eigenen Stagingordners werden zurueckgerollt.

## Nachweise, Grenzen und Sicherheit

manifest.json enthaelt Quell-URLs, Exportzeit, API-Version, SHA256, Blockwarnungen,
review_required=true und auto_indexed=false. source_mode unterscheidet API-Abrufe von
Offline-Snapshots; fetched_at ist nur beim API-Abruf mit dessen Abschlusszeit gefuellt, offline
bleibt es null. Die Quell-URL ist die kanonische Notion-ID-Adresse, nicht zwingend die
veroeffentlichte notion.site-URL. Der Export ist eine vereinfachte Textansicht:
Listen/Code/Unterbloecke werden beruecksichtigt; Tabellen, Formeln, Relationen, Medien, Anhange und
Layouts nicht vollstaendig reproduziert. Warnungen pruefen, nicht als verlustfreie Datensicherung
verwenden. Kein Bild-/Dateidownload und kein automatisches Verfolgen verlinkter Seiten.

Grenzen: standardmaessig 20 Seiten (maximal 50), 2000 Bloecke gesamt, acht Verschachtelungsebenen,
20 Listenantworten pro Pagination, 60 HTTP- Versuche, 15 Sekunden Timeout je Versuch, 2 MiB je
Antwort und 16 MiB Antwortdaten insgesamt. Bei Limitueberschreitung wird abgebrochen statt einen
vollstaendigen Export zu behaupten. Bis zu zwei 429-Wiederholungen beachten Retry-After bis maximal
60 Sekunden: [Notion-Requestlimits](https://developers.notion.com/reference/request-limits). Das ist
kein Echtzeitdienst und kein hartes Gesamtzeitlimit.

Tokens werden nur an <https://api.notion.com> gesendet; Redirects sind blockiert.
API-Schreibmethoden/-Routen sind nicht freigegeben. Fehlerausgaben geben keine API-Antwortkoerper
oder Tokens aus. Exporte koennen trotzdem sensible Seiteninhalte enthalten: Betriebssystemrechte,
Verschluesselung, Aufbewahrung und Backups selbst passend absichern. POSIX-Dateimodi sind keine
zugesicherte Windows-ACL-Konfiguration.

Externe Texte gelten als **unvertrauenswuerdige Quellen**, nicht als Systemanweisungen. Keine
automatischen Shellbefehle, Skill-Installationen, Masterkey-Synchronisation oder direkte
RAG-Indizierung aus Notion-Inhalten. HTML in Textbloecken wird maskiert; Code bleibt als nicht
ausgefuehrter Codeblock erhalten. Das ist keine Garantie gegen Prompt-Injection bei spaeterem Lesen
durch ein Modell.

## Auftrag fuer spaetere Recherche

```text
Suche oeffentliche Notion-Quellen zu Agenten-Runbooks, Prompt-Evaluation,
lokalen RAG-Workflows und Architekturentscheidungen. Bevorzuge Primaerquellen.
Erfasse URL, Autor soweit belegt, Datum, Thema, Lizenz, Datenfluss und
konkreten Nutzen fuer RTX-5080-Host oder Letsung MiniPC. Markiere Abrufluecken.
Pruefe Befehle gegen offizielle GitHub-/API-Dokumentation.
Liefere Kandidaten und begruendete Vorschlaege, keine automatische Installation,
RAG-Uebernahme, Cloud-Modellanfrage, WSL-Aktion oder GitHub-Veroeffentlichung.
Notion-API nur fuer ausdruecklich geteilte Seiten mit vorhandener Freigabe nutzen.
```

Der Auftrag ist eine wiederverwendbare Vorlage, keine jetzt gestartete Hintergrundautomation. Fuer
Quellenbewertung den bestehenden [Toolauswahl-Skill](../../skills/sprach-infra-tooling/SKILL.md)
verwenden.

## Offline-Pruefung

Die Tests in [test_notion_research.py](../../tests/test_notion_research.py) verwenden simulierte
HTTP-Antworten und temporaere Exportordner. Abgedeckt sind unter anderem Pagination, 429-Retries,
Redirect-Sperre, Groessenlimits, Markdown-Maskierung und die Bereinigung eigener unvollstaendiger
Exporte. Ein echter Workspace-Abruf wurde nicht ausgefuehrt; dafuer werden eine bewusst freigegebene
Quelle und ein eigenes Token benoetigt.

```text
python -B -m unittest discover -s tests -p test_notion_research.py -v
```
