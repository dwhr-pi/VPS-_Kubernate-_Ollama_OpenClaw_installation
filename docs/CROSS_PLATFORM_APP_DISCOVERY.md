# Dashboard fuer Windows, macOS, Linux, Android und iPhone

Stand: 2026-11-12. **Desktop-Inventarbasis implementiert; Cockpit-/Launcher-/Mobil-Apps noch nicht entwickelt.**
Diese Seite ergaenzt den [Dashboard-Einstieg](TOOL_DASHBOARD_BROWSER_DESKTOP.md) und den
[Launcher-/Installer-Vertrag](DESKTOP_LAUNCHER_AND_METRICS_CONTRACT.md).
Gepinnte Git-Quellen und native Builds bleiben Standard; kein Docker-Fallback und keine automatischen Starts.

## Was ist jetzt vorbereitet oder umgesetzt?

| Baustein | Stand | Grenze |
| --- | --- | --- |
| Gemeinsame Vorschlagsdaten | [JSON-Schema](../config/schemas/app-discovery.schema.json) | Discovery ist keine Startberechtigung |
| Desktop-Scan | [Python-Adapter](../scripts/desktop/app_inventory.py) | Nur nach Zustimmung, lokale Metadaten in ausdruecklich angegebenen Ordnern |
| Bekannte Tool-Namen | [Hinweisliste](../config/desktop_app_hints.json) | Namensgleichheit beweist weder Hersteller noch Kompatibilitaet |
| Nicht erfasste KI-Apps | Namensheuristik oder opt-in ungefilterte Vorschlagsliste | Kein vollstaendiger KI-Klassifikator; manuelle Pruefung noetig |
| Icons | Nur Dateinamenhinweis oder Platzhalter | Keine Icon-Datei wird gelesen, extrahiert, kopiert oder heruntergeladen |
| CI | [Ubuntu/macOS/Windows-Fixture-Matrix](../.github/workflows/desktop-inventory.yml) | Neu vorbereitet; echte Plattform-/App-Abnahme bleibt separat |
| Android und iPhone | Plattformwerte/Plan und untenstehender App-Vertrag | Kein mobiler Inventarscan im Python-Tool |
| Installer-Registrierung, GUI und App-Start | [Ausbauvertrag](DESKTOP_LAUNCHER_AND_METRICS_CONTRACT.md) | Noch nicht implementiert; vorhandene Installer bleiben unveraendert |

Der Scanner registriert keine Tools im Setup und veraendert weder Dashboard- noch Start-Allowlists.
Es wurde hier **kein echter Scan deiner installierten Apps** ausgefuehrt; Tests verwenden nur synthetische Dateien.

## Plattformvergleich

| Betriebssystem | Erkennung jetzt / spaeter | App-Start spaeter | Icons spaeter |
| --- | --- | --- | --- |
| Windows | Jetzt: EXE-Namen in freigegebenen App-Ordnern; Registry/MSIX/Verknuepfungen noch offen | Freigegebenes Artefakt oder gepruefter eigener URI-Handler | Gepruefte Build-Assets oder begrenzte Ressourcenextraktion |
| macOS | Jetzt: `.app/Contents/Info.plist`, inklusive Bundle-ID-/Versionshinweis | Geprueftes Bundle ueber native LaunchServices-Anbindung | Gepruefte Bundle-Assets; Konvertierung und Lizenz separat |
| Linux | Jetzt: `.desktop` mit Name/Type/Hidden/Icon; `Exec` wird nicht ausgewertet | Desktop-ID ueber begrenzte native Anbindung, kein Shell-eval | Gepruefte lokale Assets oder begrenzter Icon-Theme-Adapter |
| Android | Spaeter: PackageManager fuer sichtbare/gezielt deklarierte Apps | Explizite, gepruefte Intents/App Links nach Benutzeraktion | Plattform-Icon fuer sichtbare Packages bzw. Platzhalter |
| iPhone/iPad | Spaeter: bekannte deklarierte URL-Schemata/Integrationen, kein allgemeines App-Inventar | Unterstuetzte Universal Links oder URL-Schemata nach Benutzeraktion | Eigene lizenzierte Assets/Platzhalter, kein allgemeines Auslesen fremder App-Icons |

Eine native App muss fuer ihr Zielsystem gebaut und signiert werden. Eine Windows-EXE wird nicht dadurch zu einer
macOS-/Linux-/Android-/iOS-App. Webbasierte Grafana-/Kubernetes-Ansichten sind davon getrennt auch mobil nutzbar,
wenn VPN, TLS und Authentifizierung passen. Ein Browser allein darf keine installierten Apps inventarisieren.

## Desktop-Scan sicher ausprobieren

Voraussetzung: gepruefter Setup-Checkout und natives Python ab 3.10. Keine Pakete werden nachinstalliert.
Standardmaessig nur den Plan anzeigen, ohne App-Verzeichnisse oder Registry zu lesen:

```bash
python3 -I -B scripts/desktop/app_inventory.py
python3 -I -B scripts/desktop/app_inventory.py --platform android
python3 -I -B scripts/desktop/app_inventory.py --platform ios
```

`--platform` macht ein Desktop-System nicht zum Smartphone. Ein echter Scan muss zum ausfuehrenden OS passen;
Android/iOS werden beim Scan ausdruecklich verweigert. Der Plan liest auch die Erkennungshinweisliste noch nicht.

**Bewusster Scan auf Linux**, nur fuer diesen Anwendungs-Metadatenordner:

```bash
python3 -I -B scripts/desktop/app_inventory.py --scan --approve-local-inventory \
  --root /usr/share/applications --max-depth 0 --device-id linux-workstation
```

Alternativ einen vorhandenen benutzerspezifischen Ordner ausdruecklich waehlen,
etwa `"$HOME/.local/share/applications"`. Keine pauschale Suche im Home-Verzeichnis.

**Bewusster Scan auf macOS**, nur fuer App-Bundles in `/Applications`:

```bash
python3 -I -B scripts/desktop/app_inventory.py --scan --approve-local-inventory \
  --root /Applications --max-depth 0 --device-id mac-workstation
```

**Bewusster Scan unter Windows**, im nativen PowerShell-Terminal und mit einem konkreten vorhandenen App-Ordner:

```powershell
py -3 -I -B scripts/desktop/app_inventory.py --scan --approve-local-inventory `
  --root 'C:\GEPRUEFTER-APP-ORDNER' --max-depth 1 --device-id windows-workstation
```

Der Windows-Pfad ist ein Platzhalter, kein vorhandener Installationsort. Nicht in WSL ausfuehren.
Keine Registry-Schluessel, Startmenue-Links, Paketmanager oder `--version`-Befehle werden dabei abgefragt.
EXE-Namen werden nicht als ausfuehrbare Artefakte oder bereits installierte Produkte verifiziert.
Erkannte Setup-/Uninstall-/Updater-Namen werden herausgefiltert; andere Fehlklassifikationen bleiben moeglich.

## Umfang, Datenschutz und Grenzen

- Maximal acht ausdrueckliche Ordner, 2.000 betrachtete Eintraege und drei Unterordnerebenen; Standardtiefe eins.
- Best-effort Zeitbudget fuenf Sekunden fuer die Traversierung. Einzelne blockierte Dateisystemzugriffe
  lassen sich dadurch nicht hart abbrechen; nur lokale, erreichbare Dateisysteme freigeben.
- UNC-/offensichtliche Netzwerkpfade, Laufwerks-/Home-Wurzel und sensible/verborgene Unterordner werden verweigert.
  Eingehangene Netzlaufwerke lassen sich nicht allein am Pfad zuverlaessig erkennen: sie nicht als Scanwurzel waehlen.
- Symlinks/Junctions werden nicht verfolgt. Metadaten-Dateien sind auf 128 KiB begrenzt, Hardlinks werden verweigert.
- Es werden keine Programme, Shells, `.lnk`-Dateien, `Exec`-Eintraege oder Credential-Plugins ausgefuehrt.
- Icons werden nicht geladen, auch wenn ein Metadateneintrag eine entfernte URL oder einen Dateipfad enthaelt.
- Lokale Pfade bleiben standardmaessig verborgen. `--include-local-paths` ist eine separate private Exportfreigabe.
- Auch App-Namen und pseudonyme IDs sind private Inventardaten; keine automatische Uebertragung an Cloud/Boardroom.
- `--device-id` ist ein frei gewaehlter Geraetealias, kein automatisch ausgelesener Hostname.
  Fuer mehrere Geraete unterschiedliche, nicht sensible Aliase vergeben; `local` ist kein global eindeutiger Alias.
- Kandidaten-IDs sind abgeleitete Kennungen, keine Anonymisierung und kein kryptografischer Identitaetsnachweis.

Der Report geht ausschliesslich nach stdout. Wenn du ihn aufbewahrst, ein neues privates Ziel ausserhalb des Repos
waehlen und bestehende Inventare nicht ueberschreiben. Kein Upload oder periodischer Scan wird eingerichtet.

Exitcodes: **0** = gewaehlt begrenzten Umfang ohne gemeldete Fehler gelesen; **3** = Umfang abgebrochen/teilweise
oder Metadatenfehler; **1** = Versuch verweigert; **2** = ungueltiger CLI-Aufruf/fehlende Freigabe.
Auch Exit 0 bedeutet niemals vollstaendige OS-Inventur, Kompatibilitaet oder Laufzeitfreigabe.

Nicht erfasst sind u. a. beliebige CLI-/PATH-Installationen, portable Apps ausserhalb der erlaubten Ordner,
Windows-MSIX-/Registry-Details, macOS-LaunchServices-Datenbank und vollstaendige Linux-XDG-/Flatpak-/Snap-Aufloesung.
Mehrere Linux-Wurzeln werden nicht als komplette XDG-Prioritaets-/Hidden-Override-Semantik aufgeloest.
macOS-Signaturen/Gatekeeper und EXE-Signaturen werden hier nicht geprueft. Keine Schutzfunktionen abschalten.

## Weitere und unbekannte KI-Apps vorschlagen

Die aktuelle Hinweisliste enthaelt Qwen Desktop, Gemini Desktop und Ollama. Sie verweist auf vorhandene Registry-IDs,
behauptet aber nicht, alle Varianten unterscheiden zu koennen. Eine gefaelschte App kann denselben Namen verwenden.
Mehrere IDs bei einem Gemini-/Qwen-Namen sind deshalb eine **mehrdeutige Zuordnung**, keine automatische Auswahl.

Andere Namen mit KI-Begriffen werden als `ai-name-heuristic` ohne Registry-Zuordnung vorgeschlagen.
Das kann harmlose Nicht-KI-Programme treffen und KI-Programme mit unauffaelligen Namen uebersehen.
Mit `--include-unclassified` koennen nach eigener Freigabe auch die uebrigen gefundenen Anwendungsmetadaten
zur manuellen Sichtung ausgegeben werden. Dabei werden mehr persoenliche App-Namen offengelegt.

Spaeterer Dashboard-Ablauf:

```text
Lokaler Scan mit Zustimmung
  -> Vorschlaege: bekannt / mehrdeutig / bisher nicht zugeordnet
  -> Benutzer bestaetigt Zuordnung oder lehnt sie ab
  -> Hersteller, Source/Signatur, Lizenz, Version, Startpfad und Icon separat pruefen
  -> privater lokaler App-Katalog
  -> eigene Startfreigabe, sichtbare Bestaetigung pro Start
```

Alle aktuellen Vorschlaege tragen `installation_status=unverified` und `launch_enabled=false`.
Ein importierter Report darf diese Sperre nicht aufheben. Kein fremder Report darf lokale Programme freischalten.
Das Dashboard muss Namen als Text rendern, darf Icon-Hinweise nicht als freie Pfade oeffnen und muss alte Reports
als veraltet kennzeichnen. Frontend, Import/Review und Persistenz sind noch zu entwickeln.

## Android und iPhone: Vertrag fuer die spaetere App

### Android

Android filtert abhaengig von Ziel-SDK und Plattform die Sichtbarkeit anderer Apps.
Die spaetere App soll nur gezielt deklarierte Packages bzw. benoetigte Intent-Integrationen ueber `<queries>` pruefen.
Kein pauschales `QUERY_ALL_PACKAGES` als Standard: dessen Nutzung unterliegt auch Store-Regeln.
Nicht sichtbare Apps als `unbekannt/nicht pruefbar` anzeigen, nicht sicher als deinstalliert.
Package-Signatur, aufgeloeste Activity und freigegebene Zielparameter vor einem nativen Start gesondert pruefen.
Icons nur ueber erlaubte Plattform-APIs fuer sichtbare Packages beziehen, nicht aus fremden App-Datenverzeichnissen.

### iPhone und iPad

Eine normale sandboxed App kann nicht allgemein alle installierten Apps und deren private Daten auflisten.
Vorbereitbar ist eine kuratierte Integrationsliste unterstuetzter Universal Links/URL-Schemata und manuelle Ergaenzung.
`canOpenURL` prueft bekannte deklarierte Schemata, nicht die Echtheit einer bestimmten Hersteller-App.
Deklarations-/SDK-Limits gegen die fuer den spaeteren Build verwendete Apple-Dokumentation pruefen.
Keine erfundenen Gemini-/Qwen-Schemata verwenden und keine privaten APIs/Jailbreaks als Fallback vorsehen.
Fremde App-Icons sind nicht allgemein auslesbar; lizenzierte gebuendelte Icons oder Platzhalter verwenden.
Ein Safari-/PWA-Dashboard hat diese Inventarrechte ebenfalls nicht.

Beide mobilen Apps benoetigen eigene Build-, Signatur-, Store-/Verteilungs- und Datenschutzpruefungen.
Die Android-/iOS-Plattformwerte sind im gemeinsamen Schema reserviert; der aktuelle v1-Report beschreibt
Desktop-Dateisystem-Metadaten. Ein mobiler Provider muss vor Implementierung einen passenden Scope-/Schema-Vertrag
erhalten, statt Dateisystem-Scans oder Vollstaendigkeit vorzutaueschen. Die Python-CLI ist keine mobile App.

## Prometheus und Icons auf allen Plattformen

Die private Grafana-Ansicht kann vom Desktop oder mobil nach VPN/TLS-/Auth-Freigabe geoeffnet werden.
Sie misst damit die angeschlossenen Hosts/Pods, nicht automatisch das gerade betrachtende Telefon.
Systemweite Smartphone-/Fremdprozessmetriken sind nicht pauschal fuer normale Apps verfuegbar.
Kein Root/Jailbreak und keine offenen Prometheus-Ports fuer diesen Zweck.
Quellen, Grenzen und Icon-Abnahme stehen im [Launcher-/Metrikvertrag](DESKTOP_LAUNCHER_AND_METRICS_CONTRACT.md).

## Tests und naechste Schritte

```bash
python3 -B -m unittest discover -s tests -p 'test_app_inventory.py' -v
```

Die Tests lesen nur temporaere Linux-/Windows-/macOS-Fixtures, keine echten App-Ordner.
Die CI-Matrix fuehrt dieselben Tests auf Ubuntu 24.04, macOS und Windows aus.
POSIX-Linktests sind dabei plattformabhaengig.
Ein erfolgreicher Fixture-Test ist kein Nachweis einer nativen macOS-/Linux-/Mobil-Installation.

- [x] Desktop-Metadatenadapter, Plan ohne Scan, Zustimmungspruefung und Ressourcenbegrenzungen implementiert.
- [x] Unbekannte/mehrdeutige Kandidaten, lokale Pfad-Redaktion und deaktivierte Startrechte vorbereitet.
- [x] JSON-Schema, synthetische Tests und plattformuebergreifende CI-Matrix hinzugefuegt.
- [ ] Native Tests auf echten freigegebenen App-Ordnern aller drei Desktop-Systeme durchfuehren.
- [ ] Schema-validierenden Import/Review und benutzergeschuetzten lokalen Katalog implementieren.
- [ ] Den [opt-in Installer-Registrierungsadapter](DESKTOP_LAUNCHER_AND_METRICS_CONTRACT.md) anschliessen.
- [ ] Icons nach Lizenz-/Format-/Integritaetspruefung uebernehmen; Launcher separat abnehmen.
- [ ] Android-/iOS-App mit begrenzten nativen Discovery-/Link-Adaptern entwickeln und separat testen.

## Primaerquellen

- [Android: Package Visibility](https://developer.android.com/training/package-visibility)
- [Apple: bekannte URL-Schemata pruefen][apple-canopen]
- [Apple: Bundle-Identifier][apple-bundle]
- [Linux: Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry/latest/)

[apple-canopen]: https://developer.apple.com/documentation/uikit/uiapplication/canopenurl(_:)
[apple-bundle]: https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleidentifier
