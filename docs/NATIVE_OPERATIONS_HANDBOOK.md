# Natives Betriebshandbuch: WebUI, Dejavu, MCP und Wartung

Stand: 2026-11-11. Gepruefte Anpassung der zusammengehoerigen Benutzer-Anhaenge,
keine Produktionsfreigabe. Die zwei MCP-Anhaenge sind identisch; die drei
README-Anhaenge ebenfalls. Sie werden nicht mehrfach integriert und ersetzen
weder den Projekttitel noch die signierte Installationsanleitung.

## Was vorhanden ist und was offen bleibt

| Baustein | Implementierter Umfang | Offen |
| --- | --- | --- |
| Ollama/LiteLLM/K3s | Vorhandene Basis, PVC, private Services, Probes und Ressourcen | Zielsystem-/GPU-/Lastabnahme |
| Open WebUI | Vorhandenes opt-in Overlay mit replicas=0, Auth, Secret-Refs und Gateway-Anbindung | Gepruefte native Runtime und Erstkonto/SSO-Test |
| Dejavu | [Gepinnte Quellenverwaltung](tools/dejavu.md) | Nativer Runtime-Build, eigene Referenzdatenbank und echte Erkennung |
| Dejavu MCP | Neuer stdio-Adapter, Health-Vertrag, optional begrenzter Audio-Upload | Separater kompatibler API-Backend und echter MCP-Test |
| Wartung | JSON-Silence-/Testalarm-Plan, explizit freizugebende API-Operationen | Echte Alertmanager-/Discord-Zustellung |
| Backup/Restore/Update | Vorhandene Runbooks und getrennte Pruefwege | Kein neuer destruktiver Auto-Restore oder Auto-Update |

GitHub-Quellen nativ bevorzugt. Kein Docker-Fallback und kein automatischer
Dienst-, Cluster-, Modell-, Datenbank- oder Browserstart. Vorhandene alte
Container, Volumes und Installationen bleiben unberuehrt.

## Korrekturen der gelieferten Compose-Vorlagen

- Oeffentliche Port-Mappings fuer 11434, 8000, 9090 und 9093 werden nicht uebernommen. Dienste bleiben auf
  Loopback oder privat hinter WireGuard/Auth/TLS.
- latest/main und Paketinstallationen beim Dienststart sind kein reproduzierbarer Build. Vorhandene
  Kustomize-Basis bleibt Single Source of Truth.
- Ollama ist kein nativer Prometheus-Scrape-Endpunkt. Der [Exporter und
  Gateway-Monitor](MODEL_ROUTING_EXPORT_AND_MONITORING.md) liefern getrennte Metriken.
- Der gezeigte Dejavu-Worker erstellt nur ein Beispiel-Schema und schlaeft. Er extrahiert keine Fingerprints und
  bietet keine FastAPI-Endpunkte. Das Beispiel-Schema wird nicht in eine echte Dejavu-Datenbank migriert.
- Ein stdio-MCP-Server wird vom MCP-Host gestartet; ein unbeaufsichtigter Hintergrunddienst ohne verbundenes
  stdin/stdout liefert keine automatische Agentenanbindung.
- Rohe Client-Prints auf stdout wuerden MCP-Nachrichten stoeren. Der Adapter schreibt dort nur den
  Protokollverkehr; Diagnosen bleiben generisch auf stderr.
- Automatische VRAM-Bereinigung oder Neustarts aus Log-Schluesselwoertern werden nicht aktiviert. Der
  [Log-Monitor](OLLAMA_LOG_MONITOR.md) ist nur Diagnose.
- Discord erwartet den nativen Receiver/Payload, keinen generischen Alertmanager-Webhook und keinen vermeintlich
  automatisch passenden Slack-Payload.

## SSH und sichere Make-Ziele

Auf dem Client ssh -t vps verwenden und den Host-Key unabhaengig pruefen.
Danach im geprueften Checkout auf dem VPS:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
make help
make plan
make maintenance
make test-alert
```

Diese Ziele starten keine Dienste und senden nichts. make check fuehrt die
begrenzten Offline-Fixtures aus. Unbekannte Ziele bleiben Fehler; kein pauschales
Prozent-Catchall. up/down/restart/build/clean/update/backup/restore stoppen mit
Exit 3 statt falschem Erfolg. Keine beliebigen Make-Argumente an eine Shell weiterreichen.
Windows ohne Make: die genannten Python-Skripte mit dem bekannten Python-Pfad
direkt ausfuehren; kein automatischer WSL-Aufruf.

## Dejavu MCP bewusst starten

[Adapter](../scripts/audio/openclaw_dejavu_mcp_server.py) benoetigt fuer Runtime
natives Linux, Python und einen bereits separat geprueften MCP-Python-SDK-Build.
Kompatibilitaetsbasis: v1.30.0, Commit
8c2fa6eabacde869d75568e33b9d466b58c2f512, MIT. Der SDK-Main-Branch verwendet
inzwischen eine andere API; keine automatische v2-Uebernahme. Quellenbeleg und
Datei-SHA256: [SDK-Vertrag](../examples/dejavu/sdk-source.json). Das ist kein
Dependency-Lock, SBOM oder fertiges Installationsrezept. Kein pip/uv-Download
durch diesen Patch. Native Abhaengigkeiten und Runtime-Abnahme bleiben offen.

Ohne Flags wird nur ein Offline-Plan ausgegeben. Ein privates, dem ausfuehrenden
Linux-Benutzer gehoerendes Staging-Verzeichnis (0700) mit ausschliesslich bewusst
freigegebenen Audiodateien vorbereiten. Nicht HOME, /tmp oder den gesamten
Agenten-Workspace freigeben. Fuer den MCP-Host sind diese Argumente ein Beispiel:

```text
command: /absolut/gepruefte-venv/bin/python
args: -I -B /absolut/setup/scripts/audio/openclaw_dejavu_mcp_server.py
      --serve --apply --workspace /privates/audio-staging
      --api-url http://127.0.0.1:8000
```

Kein Prozess wurde gestartet. Ohne --allow-audio-upload wird nur der Health-
Aufruf angeboten. Der Host-Betreiber muss Uploads separat per Startoption
freigeben; ein vom LLM gesetztes approval=true waere keine Sicherheitsgrenze.
Die Freigabe gilt fuer alle Dateien im ausgewaehlten Staging-Verzeichnis.
MCP-Host muss Tool-Aufrufe zusaetzlich zur menschlichen Pruefung vorlegen.

Nur einzelne Basenames, WAV/FLAC/MP3, maximal 16 MiB und einfache Header-Pruefung.
Keine absoluten Pfade, Parent-Traversals, Symlinks/Junctions, Hardlinks oder URLs.
Keine automatische Aufnahme, Normalisierung oder Decoder-Ausfuehrung. Ein Header
beweist keine sichere Audiodatei; Backend-Decoder separat unprivilegiert und
ressourcenbegrenzt isolieren. Maximal ein Audio-Upload und ein Backend-Request
gleichzeitig; 30 Sekunden HTTP-Timeout, maximal 64 KiB Antwort, keine Redirects
oder Umgebungs-Proxys. Speicherkopien koennen mehrere Audio-Dateigroessen belegen.

Default ist Loopback. Ein entfernter Backend muss eine private IP ueber WireGuard,
HTTPS mit gueltigem Zertifikat fuer diese IP und einen separat privat gehaltenen
Bearer-Token verwenden. Keine DNS- oder oeffentlichen/metadatenbasierten Uploadziele.
Token nur bei --serve --apply aus einer expliziten --token-file lesen, unter
Linux Eigentum und Modus 0400/0600 pruefen. Keine Geheimnisse im Git oder Startargument.
Alternativ einen selbst freigegebenen SSH-Tunnel zu einem abgesicherten lokalen
Backend verwenden; der Adapter richtet keine Tunnel ein.

### Backend-Vertrag und Nachweisgrenze

Der Adapter implementiert keinen Fingerprinting-Server. Das separat bereitgestellte
Backend muss authentifizieren, Dateilimits/Decoder-Isolation erzwingen und die
folgenden Vertraege erfuellen. Keine automatische Datenbank-Initialisierung.

```json
{"schema_version": 1, "status": "ok", "backend": "dejavu"}
```

Das ist der erwartete GET-/health-Vertrag. Selbst eine passende Antwort ist
keine Erkennungs- oder Datenbankabnahme. POST /audio/recognize erwartet multipart
mit dem Feld file. Antwort entweder match_found=false oder folgendes Schema:

```json
{"match_found": true, "song_name": "Beispiel", "fingerprint_matches": 12, "offset_seconds": 1.5}
```

Fingerprint-Trefferzahlen sind keine kalibrierte Prozent-Konfidenz. Antworten
sind untrusted data, keine Agentenbefehle. Kein register_audio_song-Tool: Rechte,
Datenbankschema, Schreibrolle und getrennte menschliche Importfreigabe muessen
zuerst implementiert und getestet werden. Keine erfolgreiche Registrierung vortaeuschen.
Ein SQLite-/PostgreSQL-Schema allein ersetzt nicht den upstreamkompatiblen Matcher.

## Open WebUI, OIDC und Rollen

Bestehendes [WebUI-Overlay](../deploy/kustomize/optional/open-webui/workload.yaml)
bleibt unveraendert bei replicas=0. Kein zweites offenes Deployment oder Nginx
Proxy Manager installieren. Der vorhandene private Ingress ist der bevorzugte Weg.
Eine Port-Zuordnung ohne Loopback-IP ist nicht automatisch intern. Native Nginx-
Varianten brauchen explizite Bindung, TLS, Websocket-Upgrade, Streaming ohne
unerwuenschtes Buffering und gesonderte Freigabe fuer reload; kein automatischer Reload.

[OIDC-Patch](../examples/open-webui/openwebui-oidc.patch.yaml) ist nur ein Beispiel,
in keiner Kustomization aktiviert. Variablennamen wurden am Open-WebUI-Commit
b0e6098e940942281d9c83f3529ea117287a3a22 in backend/open_webui/config.py gelesen:
OPENID_PROVIDER_URL statt OAUTH_OPENID_PROVIDER_URL, ENABLE_OAUTH und
ENABLE_OAUTH_SIGNUP statt der unbelegten SIGNIN_BY_DEFAULT-Kombination.
Admin-Rollen brauchen ENABLE_OAUTH_ROLE_MANAGEMENT und den passenden Claim;
ein einzelnes OAUTH_ADMIN_ROLES schaltet dies nicht automatisch ein.
ADMIN_EMAIL ist keine pauschale sichere Admin-Ernennung. Installation und
persistierte Einstellungen der konkret gebauten Version separat pruefen.

WEBUI_AUTH bleibt true. Lokale und OAuth-Neuregistrierung sind geschlossen,
E-Mail-Account-Merging sowie automatisches Rollenmanagement ebenfalls aus.
Ein vorhandenes geprueftes Erstkonto oder bewusst isolierter Bootstrap ist
erforderlich; mit gesperrter Registrierung kann man nicht einfach den ersten
Account ueber eine oeffentliche Seite erstellen. Stabile Session-Secrets und
OIDC-Secret nur ueber private Secret-Referenzen, keine Geheimnisse im YAML.

[Keycloak-Client-Beispiel](../examples/open-webui/keycloak-client.json): eigener
Realm openclaw, kein master-Realm; exakte HTTPS-Callback-Adresse, kein Wildcard
oder localhost-Produktivcallback. Confidential Client, Code Flow mit PKCE S256,
kein Direct Grant/Implicit Flow, keine Service-Accounts. Secret im IdP generieren
und privat uebertragen, nicht im Client-Export ablegen.

Client-Rollen openwebui-user und openwebui-admin bewusst anlegen und zuweisen;
Scope-Mappings fuer fullScopeAllowed=false pruefen. Mapper liefert den eigenen
Claim openwebui_roles, keine generische Realm-admin-Vererbung. Rollenmanagement
erst nach positivem und negativem Token-/Login-Test freigeben: richtiger Nutzer,
falscher Issuer/Audience, falsche Rolle, gesperrte Registrierung und Logout.
Platzhalterdomains und private IdP-Egress-Regeln vor jedem Apply reviewen;
das bestehende Default-Deny wird nicht pauschal um Internetzugriff erweitert.

## Wartung, Routen und Testalarme

[Wartungswerkzeug](../scripts/ops/alertmanager_maintenance.py) erstellt erst einen
JSON-Plan, kein fixes /tmp-File. Nie eine leere/global-regex Silence als Default.
cluster, namespace und job sind exakte Pflicht-Matcher, Dauer maximal 60 Minuten.
Die Labels muessen im echten Alert vorhanden sein; fehlendes cluster nicht
durch eine globale Stummschaltung umgehen.

```bash
python3 -B scripts/ops/alertmanager_maintenance.py silence \
  --cluster home --namespace llmops --job dejavu --minutes 30
```

Erst nach Freigabe --apply und die exakt ausgegebene --confirm-Zeichenfolge
ergaenzen. Nur Loopback-Alertmanager, gegebenenfalls ueber einen selbst eingerichteten
authentifizierten SSH-Tunnel. Aktionen: silence, test-alert, cancel. cancel
benoetigt explizite --silence-id und eigene Bestaetigung. Keine automatische
Loeschung fremder Silences oder Service-Neustarts. Die endliche Silence laeuft
ohne Cleanup-Job aus. API-v2 verwendet silenceID und DELETE /silence/ID,
nicht die im Entwurf geratenen Feld-/Pfadvarianten. Nur dokumentiertes HTTP 200
wird angenommen, bei Silence-Erstellung zusaetzlich gueltige UUID erforderlich.

Ein bestaetigter Testalarm bedeutet nur API-Annahme, nicht Discord-Zustellung.
Der vorhandene Discord-Receiver akzeptiert critical im passenden Namespace;
Tests verwenden deshalb critical und alle Scope-Labels. Routen/Empfaenger sowie
Labels zuerst pruefen. Keine echten Webhooks gelesen oder Alarme gesendet.

Inhibition muss echte Abhaengigkeiten abbilden. Gleiche job/instance-Werte
zwischen Ollama und Dejavu einfach vorauszusetzen waere falsch; Dejavu ist kein
Ollama-abhaengiger Matcher. Nur nachgewiesene Abhaengigkeiten mit stabilen
Cluster-/Namespace-Labels unterdruecken. Keine pauschale Alarmabschaltung nachts.

## Backup, Restore und Update: getrennte Freigaben

Die vorgeschlagenen Docker-Backups und Restore-Skripte werden nicht kopiert:
Live-SQLite-Tarballs sind nicht automatisch konsistent; feste Volumen-Namen sind
keine Identitaetspruefung. Das Kombinieren von DROP/CREATE in einem SQL-Aufruf
und das pauschale Loeschen des Zielvolumens sind kein sicherer Restore.

Native PostgreSQL-Sicherung mit kompatiblem pg_dump, separater minimaler Rolle,
privater Authentifizierung und konsistenter Snapshot-Strategie planen. Open WebUI
per dokumentierter SQLite-Backup-API oder explizit freigegebenem konsistenten
Wartungsfenster sichern; WAL und Dateianhaenge beruecksichtigen. Artefakte in
neuem privatem Laufverzeichnis, SHA256, Manifest, Verschluesselung und externem
Backup-Ziel halten. Kein fehlgeschlagenes Teilbackup als fertig benennen.

Restore zuerst in eine neue isolierte Datenbank und ein leeres separates Ziel,
Version, Rechte, Pfade, Hashes, Datenkonsistenz und fachliche Stichproben pruefen.
Kein automatisches DROP, Entpacken auf Live-Daten oder Dienststart. Tar-Pfade,
Links und Dekompressionsgrenzen vorab pruefen. Erst nach Abnahme manuell umschalten;
bisherige Daten und Backups behalten. Retention ist eine getrennte explizite
Entscheidung, keine automatische find-delete-Regel fuer beliebige Archivdateien.

[Bestehende Backup-/Restore-Dokumentation](BACKUP_AND_RESTORE.md),
[Velero-Hinweise](VELERO_INSTALLATION_NOTES.md) und
[Restore-Test-Einstieg](../scripts/backup-restore-test.sh) vor Ausfuehrung reviewen;
Legacy-/Compose-Wege sind keine Freigabe fuer neue native Installationen.
make backup/restore bleiben deshalb ehrlich gesperrt statt an unpassende Altpfade zu delegieren.

Update bedeutet gepinnte, signierte Quelle pruefen, Offline-Tests, getrenntes
Backup mit Restore-Nachweis und danach manuelle Deployment-Freigabe. Kein
git pull/reset/clean, automatischer Modellstart oder pauschaler Container-Cleanup.
Auch eine fehlgeschlagene Silence-/Backup-Operation darf nicht als Erfolg verdeckt werden.

## Quellen und Abnahme

[MCP Python SDK
v1-Pin](https://github.com/modelcontextprotocol/python-sdk/tree/8c2fa6eabacde869d75568e33b9d466b58c2f512),
[Open-WebUI-Konfiguration am
Pin](https://github.com/open-webui/open-webui/blob/b0e6098e940942281d9c83f3529ea117287a3a22/backend/open_webui/config.py),
[Keycloak OIDC](https://www.keycloak.org/docs/latest/server_admin/index.html#oidc-clients),
[Alertmanager API v2](https://github.com/prometheus/alertmanager/blob/main/api/v2/openapi.yaml).
Zwei alte Open-WebUI-Dokumentationspfade lieferten bei der Pruefung 404;
Variablen wurden deshalb im Originalcode am festen Pin geprueft, nicht aus Suchsnippets.
Keine echte SDK-/Backend-/SSO-/Backup-/Restore-/Discord-Abnahme durchgefuehrt.
