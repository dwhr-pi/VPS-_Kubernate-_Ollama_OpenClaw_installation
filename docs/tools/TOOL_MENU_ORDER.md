# Reihenfolge der Tools

Stand: 02.11.2026, Katalogbasis vom 01.11.2026. Gilt fuer das Tool-Management in `setup_ultimate.sh`, nicht
fuer Profilreihenfolge, Installationsstatus oder die alphabetischen Registry-Matrizen.

## Bestehender Katalog

Ollama, OpenClaw und Ruflo bleiben im festen Bereich vor der Trennlinie.
Alle zum jetzigen Stand vorhandenen weiteren Menueeintraege werden danach
ohne Beachtung der Gross-/Kleinschreibung nach A-Z sortiert (ASCII-Faltung,
entsprechend `LC_ALL=C sort -f -s`). Die kleine Offline-Implementierung liegt in
`scripts/helpers/tool_menu_order.py`; Bash uebernimmt erst das vollstaendige Ergebnis.
Vorhandenes Python 3 ist erforderlich; es wird nicht automatisch nachinstalliert.
Auch GitOps_Bootstrap, Kubeseal und Traefik stehen wieder an ihrer alphabetischen
Position; ihre bisherige Sonderbehandlung als Anhang ist aufgehoben.

Die [Sortierbasis](../../config/tool_menu_sorted_baseline.txt) enthaelt die 352
aktuellen Nicht-Core-Menueschluessel, einschliesslich der dynamisch registrierten
nativen Tools. Zusammen mit den drei festen Eintraegen sind das 355 Menueschluessel.
Die Registry umfasst mehr Metadatenzeilen; daraus werden nicht automatisch weitere
Programme installiert oder als neue Menuepunkte erfunden.

## Neue Tools hinter Z

Kuenftige neue Menueschluessel, die noch nicht in der Sortierbasis stehen, werden
nach dem letzten alphabetischen Eintrag (derzeit Zotero) angehaengt. Ihre
Registrierungsreihenfolge bleibt erhalten, auch beim erneuten Oeffnen des Menues.
Ein neues Tool mit A am Anfang wird also nicht unbemerkt zwischen alte Eintraege
geschoben. Installation, Quellenpruefung und Reifegrad bleiben davon getrennt.

Fuer neue Tools wie bisher `TOOL_KEYS`, Beschreibung und Script-Zuordnung bzw.
die vorhandene native Registrierung pflegen. **Die Sortierbasis dabei nicht
automatisch erweitern.** Erst auf ausdruecklichen Wunsch zur erneuten gesamten
A-Z-Sortierung die dann vorhandenen Schluessel in die Basis aufnehmen.
Keine automatische Dateiaenderung beim Menueaufruf und keine private Statusdatei.

## Fehler und Nachweise

Bei fehlender, leerer, doppelter oder ungueltiger Basis sowie fehlgeschlagenem
Pruefhelfer oder doppelten Menueschluesseln bleibt `TOOL_KEYS` unveraendert. Das Menue bricht vor seiner
weiteren Statusverarbeitung ab, statt eine verkuerzte Auswahl darzustellen.
CRLF und eine fehlende letzte Leerzeile sind erlaubt. Die Datei wird nur als
Liste gelesen, nicht als Shell-Code geladen.

`tests/test_tool_menu_order.py` prueft den kompletten statischen und nativen
Katalog, die festen Eintraege, A-Z, Verlustfreiheit, echte kuenftige Eintraege,
Idempotenz sowie fehlende/defekte Basis und Sortierfehler. Die bestehende
Trennlinien-/Auswahllogik wird weiterhin durch
`tests/test_webinar_platform_menu.py` geprueft. Kein Installer oder Dienststart.

[Lokale Abnahme und offene Grenzen](../quality/2026-11-02-openclaw-menu-acceptance.md).

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py list
```

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
