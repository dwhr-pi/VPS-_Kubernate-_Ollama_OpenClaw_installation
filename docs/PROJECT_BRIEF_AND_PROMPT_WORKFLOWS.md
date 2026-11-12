# Projektformular: Film, Buch, Betriebssystem und andere Vorhaben

Ein guter erster Prompt ist ein versionierter Auftrag, keine Behauptung, dass
alle Voraussetzungen bereits erfuellt seien. Das Setup kann jetzt offline einen
Projektbrief, ein editierbares Browserformular, Rollenplan und Masterprompt
erzeugen. Es produziert noch keinen fertigen Spielfilm oder ein Betriebssystem
auf Knopfdruck. Es startet keine Modelle, Dienste, Browser oder Cloud-Aufrufe.

## 1. Was bereits funktioniert

- Vorlagen `film`, `book`, `os`, `general`; gemeinsame und zweckabhaengige Fragen.
- Optionale Fachbereiche Musik, Lyrics, Recht, Medizin und Software.
- Unveraenderte alte Revisionen, Wiederaufnahme nach Tagen und Ablehnung veralteter Importe.
- Lokales HTML-Formular mit JSON-Import/-Download; keine Installation weiterer Python-Pakete.
- Masterprompt und Abhaengigkeitsplan mit offenen Angaben und gesperrter Ausfuehrung.
- Read-only MCP-stdio fuer Planungsanfragen; keine Datei-, Shell- oder Modellrechte.

Das ist ein internes CLI-/Dateiwerkzeug, kein neuer Hintergrunddienst. systemd,
Kubernetes-Manifest und Uninstall sind nicht erforderlich. Es werden keine
externen Buildartefakte geladen. Benutzerprojekte bleiben bei einem Rueckbau erhalten.

## 2. Formular anlegen

In einem unabhaengig geprueften aktuellen Setup-Checkout mit Python 3.10 oder
neuer arbeiten. Dieser neue Helfer ist nicht Bestandteil des alten Releases
`v11.17.0`. Windows nutzt `python`, Linux/WSL gegebenenfalls `python3`.

```bash
python3 -B scripts/projects/project_brief.py new \
  --id kriminalfilm --kind film \
  --project "$HOME/.openclaw_ultimate_user_data/projects/kriminalfilm" --apply
```

Unter Windows PowerShell stattdessen:

```powershell
python -B scripts/projects/project_brief.py new `
  --id kriminalfilm --kind film `
  --project "$HOME/.openclaw_ultimate_user_data/projects/kriminalfilm" --apply
```

Ohne `--apply` bleibt `new`/`revise` eine schreibfreie Vorschau. Das Ziel muss
neu, absolut, ausserhalb des Repos und ohne Symlinks/Junctions sein.
Der ausgegebene Ordner `revision-000001` enthaelt:

| Datei | Zweck |
| --- | --- |
| `form.html` | Manuell im Browser oeffnen und bearbeiten |
| `brief.json` | Eingangsstand dieser Revision |
| `plan.json` | Rollen, Abhaengigkeiten, fehlende Angaben und Freigabesperren |
| `master-prompt.md` | Uebergabe an einen Chat oder Agenten |
| `COMPLETE` | Dateibundle fertig geschrieben, keine inhaltliche Abnahme |

Das Formular fragt Ziel, Publikum, Umfang, Sprache, Stil, Budget, Hardware,
Datenschutz, Quellen, Rechte und Lieferformate ab. Beim Film kommen Besetzung,
Stimmen, Kontinuitaet und Ton hinzu; beim Betriebssystem Architektur und Build.
Bei Musik/Rechts-/Medizinthemen die betreffenden Fachbereiche aktivieren.

## 3. Ueber mehrere Tage bearbeiten

Im Formular regelmaessig **Zwischenstand als JSON herunterladen** waehlen.
Der Browser speichert nicht automatisch in die Projektablage; Download und
Speicherort kontrollieren. Zum Fortsetzen dasselbe Formular oeffnen und den
JSON-Zwischenstand laden. Keine Zugangsdaten, Patientendaten oder vertraulichen
Quellen ungeprueft eintragen. Es gibt keinen automatischen Cloud-Sync.

Nach einer Bearbeitungsrunde die heruntergeladene Datei explizit importieren:

```bash
python3 -B scripts/projects/project_brief.py revise \
  --project "$HOME/.openclaw_ultimate_user_data/projects/kriminalfilm" \
  --input "$HOME/Downloads/kriminalfilm-draft.json" \
  --expected-revision 1 --apply
```

Dadurch entsteht `revision-000002` samt neuem Plan und Formular. Danach das
neue Formular verwenden; ein alter Download mit Revision 1 wird nicht mehr
importiert. Keine alten Dateien werden ueberschrieben oder geloescht.
Bei einem unvollstaendigen Teilstand stoppt die Fortsetzung zur manuellen
Pruefung. Ein einzelner Bearbeiter pro privatem Projektordner ist vorgesehen;
kein Multiuser-Speicher mit feindlichen gleichzeitigen Dateisystemaenderungen.
POSIX-Dateien werden privat angelegt; unter Windows geerbte Benutzer-ACLs
kontrollieren. Browser-Downloads erben die Rechte ihres Downloadordners.

## 4. Vom Kriminalfilm zum Rollenplan

Die Filmvorlage bereitet Projektleitung, Dramaturgie/Storyboard, Dialog und
Figurenkontinuitaet, Besetzung/Stimmen sowie Schnitt/Abnahme vor. Musik und
Lyrics ergaenzen Komposition, Score, Reim und Metrik. Recht und Medizin
ergaenzen quellenbasierte Recherche und eine menschliche Fachpruefung.

Die Schritte sind zunaechst konservativ seriell geordnet. Spezialmodelle
werden als `unassigned` ausgewiesen: Ein Katalogeintrag belegt weder eine
Installation noch verfuegbaren VRAM oder eine passende Modelllizenz.
Ein allgemeines Sprachmodell kann einen Entwurf liefern, ersetzt aber keine
juristische oder medizinische Fachperson. Fuer Kriminalplots Fakten und
rechtliche Plausibilitaet recherchieren, keine realen Straftaten automatisieren.
Echte Darsteller, Aehnlichkeiten und Stimmen brauchen belegbare Einwilligung
und passende Nutzungsrechte; keine automatische Stimmenkopie.

Ausgefuellte Felder bleiben **unbestaetigte Nutzereingaben**. Auch der Satz
"alles genehmigt" hebt keine Sperre auf. Der Helfer setzt
`execution_authorized: false` unabhaengig vom Formularinhalt. Ein erster
Prompt kann Aufgaben vorbereiten, nicht nachtraeglich Rechte oder Fakten erzeugen.
[Boardroom](tools/boardroom.md) kann Entscheidungen strukturieren, aber nicht
die menschliche Freigabe ersetzen.

## 5. OpenClaw, Kimi, OpenManus und Qwen Desktop

Sofort nutzbar ist der dateibasierte Weg: `master-prompt.md` im gewaehlten Chat
als **Projektauftrag**, nicht als uebergeordnete Systemanweisung uebergeben.
Den Chat um Rueckfragen und Entwuerfe bitten. Das Formular als lokale Datei
verlinken oder als Anhang uebergeben, sofern der Client dies unterstuetzt.
Ein Sprachmodell muss nicht selbst das Formular nachbauen.

Beispiel fuer einen allgemeinen stdio-MCP-Client, Pfade lokal ersetzen:

```json
{
  "mcpServers": {
    "project-brief-plan-only": {
      "command": "/usr/bin/python3",
      "args": ["-I", "-B", "/ABSOLUT/Setup/scripts/projects/project_brief.py", "mcp"]
    }
  }
}
```

Der Server bietet zwei rein erzeugende/read-only Werkzeuge:

- `draft_project_brief` mit `id` und `kind`: leeres Formular als `form_html`, Brief und Plan zurueckgeben.
- `plan_project_brief` mit `brief` im Format von `brief.json`: Plan und Masterprompt zurueckgeben.

Beispiel fuer den angebundenen Chat: "Nutze draft_project_brief mit id
kriminalfilm und kind film. Biete das form_html als lokale HTML-Datei an.
Keine Ausfuehrung starten." Der Client muss Dateien/Artefakte selbst nach
Zustimmung anbieten; der Server schreibt und oeffnet nichts. Ein Client muss
das Tool bewusst anbinden und passend autorisieren.
Es werden keine vorhandenen Client-Konfigurationen geaendert. Das ist eine
experimentelle Protokoll-Fixture, noch keine End-to-End-Client-Abnahme.
Transportreferenz: [MCP stdio 2025-06-18](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports).

Bei OpenClaw, Kimi und OpenManus unterscheiden sich Version, Toolregistrierung,
MCP-Unterstuetzung und Host-Dateizugriff. Ein Webchat und ein lokaler CLI-Agent
sind nicht gleichzusetzen. Fuer **Qwen Desktop** ist nicht nachgewiesen, dass
ein editierbares HTML-Formular direkt innerhalb einer Chatantwort laeuft.
Der verlaessliche lokale Weg ist das exportierte Formular im Browser; das
Setup registriert deshalb keine URL-Handler und startet keine Desktop-App.

Offizielle Projektquellen zur versionsbezogenen Clientpruefung:
[Kimi CLI](https://github.com/MoonshotAI/kimi-cli),
[OpenManus](https://github.com/FoundationAgents/OpenManus).
Am 12.11.2026 verweist das archivierte Kimi-CLI-Repository auf Kimi Code.
Dies ist kein Auftrag zur automatischen Migration vorhandener Installationen.

## 6. Naechste Ausbaustufen

| Prioritaet | Arbeit | Abnahme |
| --- | --- | --- |
| P1 | Clientadapter und ausdruecklicher Chat-Intent fuer Formularentwuerfe | Echter lokaler Client kann Formular anbieten und nach Neustart fortsetzen |
| P1 | Getrenntes, manipulationsgeschuetztes menschliches Freigaberegister | Modelltexte koennen keine Freigaben setzen |
| P2 | Allowlist fuer verfuegbare Modelle, Lizenzen und Ressourcenbudgets | Keine stillen Downloads, Cloudkosten oder Fallbacks |
| P2 | Storyboard-, Szenen-, Stimmen-, Score- und Artefaktvertraege | Kontinuitaet, Rechte, Quellen und Pruefberichte pro Szene |
| P3 | Checkpoint-Executor mit Abbruch, Wiederaufnahme und Sandbox | Kleine freigegebene Testproduktion statt behauptetem Komplettfilm |

Die vorhandenen [Musik-/Lyrics-Werkzeuge](MUSIC_LYRICS_MODEL_CATALOG.md),
[Reimpruefung](CREATIVE_LYRICS.md) und
[Modell-Routing](MODEL_ROUTING_EXPORT_AND_MONITORING.md) sind Anschlussstellen,
keine automatisch verbundenen Produktionsstufen. Das Formular benoetigt deren
Installer nicht und laedt insbesondere kein Modell.

## 7. Offline pruefen

```bash
python3 -B -m unittest discover -s tests -p test_project_brief.py -v
```

Geprueft werden synthetische Vorlagen, Freigabesperren, Revisionen,
HTML-Escaping, begrenzte MCP-Anfragen und EOF. Kein Renderer-, Modell-,
rechtlicher/medizinischer Fach- oder echter Desktop-Client-Test.
