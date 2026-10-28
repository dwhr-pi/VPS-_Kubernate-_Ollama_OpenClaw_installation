# OpenAPI Servers fuer Open WebUI

Stand: 28.10.2026. **Installation und Open-WebUI-End-to-End-Test ungeprueft.**

## Zweck und Umfang

[open-webui/openapi-servers](https://github.com/open-webui/openapi-servers) bietet
Referenzimplementierungen einzelner HTTP-Toolserver. Ein geeignetes Modell kann
damit etwa Zeitberechnungen ausfuehren oder gezielt externe Daten abfragen.
Das ist kein LLM-Provider, kein OpenAI-Modellendpunkt und kein einzelner Server
fuer alle Werkzeuge. OpenAPI beschreibt die API; es garantiert keine sichere
Implementierung. Die MIT-Lizenz gilt fuer diesen Quellbestand, nicht automatisch
fuer alle Abhaengigkeiten.

Das Setup bietet **`OpenAPI_Servers`** im alphabetischen Tools-Menue nach der
Trennlinie. Es richtet eine private Python-Umgebung fuer **ausschliesslich den
Zeitserver** ein, ohne Docker. Die anderen Beispielserver liegen als Quellen
vor, werden aber nicht importiert, eingerichtet oder gestartet. MCPO bleibt ein
separates Werkzeug: Eine bereits vorhandene OpenAPI-API benoetigt keinen
MCP-zu-OpenAPI-Proxy.

Pin: `df86ff8ae5a1962f2c405bd888bf0a426f4e9e24`.
[Gepruefter Quellstand](https://github.com/open-webui/openapi-servers/tree/df86ff8ae5a1962f2c405bd888bf0a426f4e9e24),
[Zeitserver](https://github.com/open-webui/openapi-servers/blob/df86ff8ae5a1962f2c405bd888bf0a426f4e9e24/servers/time/main.py),
[Lizenz](https://github.com/open-webui/openapi-servers/blob/df86ff8ae5a1962f2c405bd888bf0a426f4e9e24/LICENSE).

## Einrichtung unter Ubuntu und WSL

Voraussetzungen: vorhandenes Python >=3.10 mit SSL, Git, 2 GiB freier Zielspeicher
und unter WSL ausreichend freier Windows-Host-Speicher. uv >=0.13.5 wird bevorzugt
wiederverwendet; falls es fehlt, ist sein privater SHA256-gepruefter GitHub-
Download nur nach Zustimmung erlaubt (zusaetzlich 256 MiB Reserve).
Kein System-Python-Wechsel, kein globaler PATH-Umbau, kein Python-Download.
Natives Windows ist fuer diese Laufzeit nicht implementiert; dort WSL verwenden.

Nur den Plan ansehen:

```bash
bash scripts/tools/openapi_servers_install.sh --dry-run
bash scripts/tools/openapi_servers_configure.sh plan
```

Im Tools-Menue `OpenAPI_Servers` waehlen oder bewusst installieren:

```bash
bash scripts/tools/openapi_servers_install.sh
# Nur falls die private uv-Basis bewusst freigegeben werden soll:
bash scripts/tools/openapi_servers_install.sh --install-build-deps
bash scripts/tools/openapi_servers_doctor.sh
```

Der Installer laedt gepinnte GitHub-Quellen und nur die Python-Abhaengigkeiten
von `servers/time/requirements.txt`. Diese sind upstream nicht versioniert:
der Installer erzeugt lokal `time-requirements.lock` mit Wheel-Hashes und
installiert daraus ohne Source-Paketbuilds. Das dokumentiert die lokale
Aufloesung, ist aber kein upstream reproduzierbar gepinnter Gesamtbestand.
[uv-Lock-/Sync-Optionen](https://docs.astral.sh/uv/reference/cli/#uv-pip-compile).

**Installation startet noch keinen Dienst und erzeugt keinen Schluessel.**
Die private Umgebung liegt unter:

```text
~/.openclaw_ultimate_user_data/tools/openapi_servers/runtime/
```

Einrichtung und Vordergrundstart erfolgen getrennt:

```bash
bash scripts/tools/openapi_servers_configure.sh configure
# Zeigt den lokalen Toolserver-Key nur auf ausdruecklichen Aufruf an:
bash scripts/tools/openapi_servers_configure.sh show-key
# In einem eigenen Terminal starten; mit Strg+C beenden:
bash scripts/tools/openapi_servers_start.sh
```

`configure` legt `config/time.json` neben `runtime/` mit einem zufaelligen
Bearer-Key an, unter Linux mit Rechten 0600. Ein vorhandener Bestand wird nicht
ueberschrieben. Das ist ein lokaler Toolserver-Key, kein OpenAI-/Open-WebUI-Key.
Nicht in Git, Screenshots, Supportlogs oder Chats kopieren. Der Schluessel wird
beim Start nicht als Kommandozeilenargument oder in einer URL uebergeben.

Standard ist **`127.0.0.1:8021`**. Kein `--reload`, kein Autostart, keine
Firewallfreigabe, keine systemd-Registrierung und keine automatische Aenderung
der Open-WebUI-Datenbank. Fuer einen anderen freien Port beim ersten Einrichten:

```bash
bash scripts/tools/openapi_servers_configure.sh configure --port 8022
```

Der konfigurierte Port muss bei Clients und gegebenenfalls in der zentralen
Portplanung ebenfalls angepasst werden. Es wird kein belegter Prozess beendet.

## Open WebUI verbinden

Bevorzugter Einstieg: Open WebUI und Zeitserver laufen nativ auf demselben Host.
Dann unter **Einstellungen -> Admin -> Integrationen -> Externe Toolserver**
einen Eintrag anlegen (Bezeichnungen variieren je Version):

| Feld | Wert |
| --- | --- |
| Name | Lokale Zeitwerkzeuge |
| Typ | OpenAPI, nicht MCP |
| Basis-URL | `http://127.0.0.1:8021` |
| Spezifikationspfad | `openapi.json` |
| Authentifizierung | Bearer |
| Schluessel | Wert aus dem ausdruecklichen `show-key`-Aufruf |

Verbindung pruefen, angezeigte Operationen kontrollieren und speichern. Danach
die Werkzeuge im jeweiligen Chat aktivieren und ein Modell mit zuverlaessigem
Tool Calling verwenden. Ein einfacher Testauftrag ist eine Umrechnung von
UTC nach Europe/Berlin. Die Verbindung allein beweist noch keine korrekte
Werkzeugnutzung durch das Modell.
[Offizielle WebUI-Anleitung](https://docs.openwebui.com/features/extensibility/plugin/tools/openapi-servers/open-webui/).

Wichtig ist, **wer die HTTP-Verbindung aufbaut**. Globale Admin-Toolserver werden
vom WebUI-Backend aufgerufen; `127.0.0.1` meint dessen eigenen Netzwerkraum.
Bei WebUI in Kubernetes/Containern ist das nicht der Windows-/WSL-Host. Keine
pauschale Umstellung auf `0.0.0.0`: erst einen ausdruecklich abgesicherten
privaten Verbindungsweg planen. Dieser Installer richtet ihn nicht automatisch
ein und verwendet weder Docker noch Kubernetes.
[Verbindungs- und CORS-Hinweise](https://docs.openwebui.com/features/extensibility/plugin/tools/openapi-servers/faq/).

Benutzerbezogene direkte Integrationen werden dagegen im Browser aufgerufen.
Sie brauchen passende Freigaben in Open WebUI und eine exakte CORS-Origin:

```bash
# Nur bei erstmaliger Konfiguration fuer die konkrete lokale WebUI-Origin:
bash scripts/tools/openapi_servers_configure.sh configure --origin http://127.0.0.1:3000
```

Ein vorhandenes `time.json` wird dadurch nicht umgeschrieben. Herkunft, Port und
Token bei Bedarf bewusst in der geschuetzten Datei bearbeiten und neu starten.
`localhost` und `127.0.0.1` sind unterschiedliche Origins. Bei HTTPS-WebUI
HTTP-Mixed-Content und Browserregeln beachten; der lokale Installer stellt kein
TLS-Zertifikat aus. Fuer den Einstieg deshalb die backendseitige Integration
auf demselben Host bevorzugen. Kein WebUI-Sessiontoken an fremde Dienste senden.

## Schutzumfang und Grenzen

Unser lokaler Adapter ersetzt die offene CORS-Konfiguration des Zeitbeispiels:
Bearer-Pflicht auch fuer `/openapi.json` und `/docs`, feste Loopback-Bindung,
Host-Pruefung und nur ausdruecklich erlaubte Browser-Origins. Keine Wildcards,
kein Vertrauen in Proxy-Header und keine HTTP-Zugriffslogs mit Nutzereingaben.
Das ist keine Sandbox oder vollstaendige Produktionsabnahme. Uvicorn begrenzt
hier Parallelitaet, ersetzt aber keine per-Nutzer-Autorisierung, Rate Limits
oder TLS an einem absichtlich netzwerkweit erreichbaren Dienst.

Die weiteren Upstream-Beispiele bleiben **deaktiviert**:

| Beispiele | Vor einer eigenen Integration erforderlich |
| --- | --- |
| Filesystem | Eigene Sandbox, kanonische Pfadgrenzen, schreibgeschuetzte Freigaben und Freigabe kritischer Aktionen |
| Git | Getrennte Test-Repositories; Schreib-/Pushrechte separat |
| Memory | Gesicherter Datenpfad, Backup und Konkurrenzzugriffe pruefen; kein Ersatz fuer Qdrant |
| SQL | Eigener Read-only-Datenbanknutzer und Abfragegrenzen; kein Produktions-Adminzugang |
| Wetter / Slack / RAG | API-Kosten, Datenweitergabe, Berechtigungen und externe Endpunkte pruefen |
| OAuth-/Cookie-/Token-Beispiele | Besonders sensibel; keine vorhandenen Browserprofile oder Tokens importieren |

Im gepinnten Filesystem-Beispiel verwendet `normalize_path` einen
Gross-/Kleinschreibung ignorierenden String-Praefixtest statt einer echten
Verzeichnisgrenze. Das ist kein verlaesslicher Sandboxnachweis. Der Code wird
hier weder gestartet noch als sichere Dateifreigabe angeboten.
[Referenzcode](https://github.com/open-webui/openapi-servers/blob/df86ff8ae5a1962f2c405bd888bf0a426f4e9e24/servers/filesystem/main.py).

## Betrieb, Fehler und Entfernung

`doctor` prueft den inventarisierten Bestand offline, nicht einen laufenden Port
oder eine Modellantwort. `status` bedeutet vorbereitete Zeitserver-Umgebung,
nicht laufender Dienst oder eingerichtete WebUI-Verbindung. Update prueft den
gleichen GitHub-Pin; kein stiller Wechsel auf `main`. Fehlgeschlagene neue
Installationen erhalten keinen Erfolgsmarker.

Bei 401: lokalen Bearer-Key pruefen. Bei 403: Host/Origin und Netzwerkraum
pruefen. Bei Verbindungsfehler: expliziten Start, Port und Ort des WebUI-Backends
pruefen. Nicht als schnelle Loesung Authentifizierung oder Loopback entfernen.

Vor Entfernung zuerst den Vordergrundprozess mit Strg+C beenden und den
WebUI-Eintrag deaktivieren. Danach:

```bash
bash scripts/tools/openapi_servers_uninstall.sh
```

Nur unveraenderte inventarisierte Runtime-Dateien werden entfernt. Geaenderter
Bestand blockiert die Entfernung. `config/time.json` mit dem Key, Logs und
private Basiswerkzeuge bleiben erhalten. Diese Konfiguration bei Bedarf separat
verschluesselt sichern; kein unverschluesselter Mail-/Git-Export.

Weiter: [Tools-Katalog](../TOOLS_CATALOG.md),
[Registry](../../config/tools.yml), [Ports](../../config/ports.yml).
