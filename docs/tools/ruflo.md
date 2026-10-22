# Ruflo: Agentenkoordination und die Nutzerquellen aus Instagram/Notion

Weiter: [Notion-Recherche, API-Grenzen und Review-Export](notion-research.md).
Ein eigenes Token eroeffnet keinen automatischen Zugriff auf diese fremde Notion-Seite.

Stand: **22.10.2026**. Anlass sind die beiden vom Nutzer gelieferten Links.

## Sinn und Zweck

Ruflo ist eine Orchestrierungs-/Werkzeugschicht fuer Agentenarbeit, nicht
ein neues Sprachmodell. Der Nutzen fuer unser Setup liegt beispielsweise
darin, Entwicklungsaufgaben in Planung, Umsetzung, Test und Review zu
gliedern. Die im Notion-URL-Titel enthaltene Formulierung "aus Claude eine
Firma" ist ein Bild fuer organisierte Zusammenarbeit, kein Nachweis
zuverlaessiger autonomer Geschaeftsfuehrung oder wirtschaftlichen Erfolgs.

Das offizielle [Repository ruvnet/ruflo](https://github.com/ruvnet/ruflo)
beschreibt Agentenkoordination, Gedaechtnis, Workflows und MCP-/Client-
Anbindungen. Die [Projektlizenz](https://github.com/ruvnet/ruflo/blob/main/LICENSE)
ist MIT; Client, Modelle, Plugins und externe Dienste separat pruefen.
Das macht [Claude Code](claude-code.md) nicht Open Source.

## Nutzerquellen und Abrufstatus

| Quelle | Link | Pruefstand |
|---|---|---|
| Instagram-Reel | [DeRCVWllVC2](https://www.instagram.com/reel/DeRCVWllVC2/) | Abruf gedrosselt; Video, Ton, Beschreibung und gezeigte Befehle nicht ausgewertet |
| Notion-Anleitung | [Ruflo: der Befehl, mit dem aus Claude eine Firma wird](https://scientific-calcium-e74.notion.site/Ruflo-der-Befehl-mit-dem-aus-Claude-eine-Firma-wird-3fbc501ffd45811f8738c955cdeb6f94) | Webabruf nicht zugaenglich; Browserversuch ohne verwertbaren Seiteninhalt |
| Primaerquelle | [ruvnet/ruflo](https://github.com/ruvnet/ruflo) | README und Lizenz erreichbar; kein Build-/Funktionsnachweis auf unserem Host |

Der Instagram-Trackingparameter mdxt wurde aus dem dokumentierten Link
entfernt; die Reel-ID bleibt unveraendert. Ein gescheiterter Abruf beweist
weder, dass die Quelle geloescht wurde, noch dass die Aussagen darin falsch
sind. Fuer eine genaue Inhaltspruefung werden Notion-Text, Screenshots oder
ein Transkript benoetigt. Hier werden keine angeblich aus dem Reel gelesenen
Schritte erfunden und keine Zugangsbeschraenkungen umgangen.

## Was Upstream tatsaechlich unterscheidet

Das README trennt eine Plugin-Installation fuer einzelne Funktionen von
einem umfangreicheren CLI-/Projekt-Setup. Die Wege haben unterschiedliche
Nebenwirkungen: Vollinitialisierung kann Projektdateien, Hooks und
MCP-Konfiguration anlegen. Beim Pluginweg kann bereits das Core-Plugin
einen MCP-Server registrieren; "Plugin" bedeutet nicht nebenwirkungsfrei.
Quelle: [Upstream Quick Start](https://github.com/ruvnet/ruflo#quick-start).

Diese Upstream-Anleitung ist kein neuer Installationsauftrag. Gleitende
npx/latest-Aufrufe, Download-Pipes und Marketplace-Registrierung werden
hier nicht ausgefuehrt. Das README beschreibt zahlreiche Funktionen und
Benchmarks; daraus werden keine eigenen Erfolgsquoten oder Leistungswerte
fuer RTX 5080, Letsung MiniPC oder Windows/WSL abgeleitet.

## Bereits im Ultimate KI Setup vorhanden

| Bestandteil | Tatsaechlicher Stand im Repository |
|---|---|
| Tool-ID | ruflo, Anzeigename Ruflo |
| Tools-Menue-Wrapper | [scripts/tools/ruflo_install.sh](../../scripts/tools/ruflo_install.sh) ruft den Hauptinstaller auf |
| GitHub-Installer | [scripts/ruflo_install.sh](../../scripts/ruflo_install.sh), Quellbuild nach /opt/ruflo |
| Quellenwahl | RUFLO_REPO_URL-Override, dann ruvnet/ruflo, danach dwhr-pi/ruflo als Fallback |
| CLI | Bei vorhandener bin/cli.js Verlinkung von ruflo und claude-flow vorgesehen |
| Status in der Registry | Pfadpruefung /opt/ruflo, kein Nachweis einer funktionsfaehigen Agentenlaufzeit |
| Deinstallation | [scripts/tools/ruflo_uninstall.sh](../../scripts/tools/ruflo_uninstall.sh); gemeinsame Laufzeiten/Caches bleiben laut Skript erhalten |

**GitHub-Quellbuild ist hier nicht gleich isolierte oder gepinnte Installation.**
Der vorhandene aeltere Installer verwendet apt, kann Node ueber NodeSource
einrichten und Corepack/pnpm global vorbereiten. Er verwendet pnpm@latest,
pnpm install --no-frozen-lockfile und bei vorhandenem Checkout git pull.
Ein Fork-Fallback ist nicht automatisch identisch mit Upstream.
Diese Punkte wurden aus dem Skript gelesen, nicht durch Installation getestet.

Deshalb nicht behaupten, der bestehende Weg veraendere nur einen privaten
Workspace oder sei vollstaendig reproduzierbar. Auch ein vorhandener
/opt/ruflo-Ordner kann einen abgebrochenen Build enthalten. Gezielte
pnpm-Buildfreigaben sind Codeausfuehrungsentscheidungen; eine bekannte
Paketbezeichnung ersetzt keine Pruefung von Herkunft und Version.

Die Skripte und Registry bleiben in dieser Ergaenzung unveraendert.
Kein Installationsstatus wird neu gesetzt. Fuer einen spaeteren Build
muessen Quelle/Commit, Laufzeiten, Speicherbudget und erlaubte
Systemaenderungen konkret festgelegt werden.

## Sinnvoller Einsatz ohne unbegrenzte Autonomie

Ein begrenzter Pilot waere eine Aufgabe in einer Testkopie: Plan erstellen,
kleinen Patch vorschlagen, freigegebene Tests ausfuehren und Ergebnis
reviewen. Rollen wie Planer, Entwickler und Reviewer sind Arbeitsteilung,
nicht automatisch voneinander unabhaengige oder fehlerfreie Instanzen.

Fuer unseren lokalen Schwerpunkt einen Job gleichzeitig und ein klares
Ende nach hoechstens drei Korrekturrunden vorsehen. Diese Vorgabe ist hier
eine Betriebsregel, keine behauptete bereits implementierte Ruflo-Sperre.
Mehrere Agenten koennen RAM, Kontext und API-Ausgaben vervielfachen.
Kein automatischer Zugriff auf Wallets, Produktion, Cloud-Budgets oder
GitHub-Push; Werkzeuge und Datenzugriff auf den konkreten Auftrag begrenzen.

Claude-Code-Anbindung und die Wahl eines lokalen Modells bleiben getrennte
Pruefpunkte. Fuer Qwen Desktop siehe den
[Windows-Leitfaden fuer getrennte Clients und Ollama](../tutorials/qwen-desktop-claude-local.md).
Eine angegebene Clientintegration ersetzt keinen Test von Toolaufrufen,
Rechten, Kontextfenster und Fehlerbehandlung.

## Pruefgrenzen

Nutzerquellen dokumentiert, Upstream-Dokumentation und lokale Skripte
abgeglichen. Kein Reel angesehen, keine Notion-Inhaltsanalyse behauptet.
Keine Installation, Modellanfrage, Hook-/MCP-Aktivierung, WSL-Aktion,
globale Laufzeitaenderung, Agentenstart, Commit oder Push ausgefuehrt.

Pruefung: fuenf neue Ruflo-Tests und 70 bestehende Interview-Regressionstests
bestanden. Quellenverweise, lokale Links, Tabellen und Registry-/Wrapper-
Zuordnung offline geprueft; Diff-Pruefung ohne Fehler. Kein Livebuild-Test.
