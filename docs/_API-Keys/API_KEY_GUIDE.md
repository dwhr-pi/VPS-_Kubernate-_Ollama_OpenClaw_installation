# API-Key Guide, Port-Konfiguration und Sicherheitsmaßnahmen (V11)

Dieser Guide erklärt, welche Zugangsdaten dein Setup benötigt, wo sie konfiguriert werden und wie
lokale Dienste geschützt bleiben. V11 ist die historische Versionsbezeichnung, keine Zusicherung
aktueller Provider- oder Modellversionen. Es werden keine Schlüssel erzeugt oder Dienste aktiviert.

**Alle Anbieter und Schlüsselnamen:** [API-Key-Katalog](PROVIDER_KEY_CATALOG.md). Zur
[API-Key-Übersicht](README.md) und zu [OnlineOnKeyServices](OnlineOnKeyServices/README.md).

## 1. API-Keys beschaffen und konfigurieren

Nur Zugänge für tatsächlich verwendete Integrationen beschaffen. Lokale Modelle benötigen
normalerweise keinen Cloud-Key. Ein Provider-Key kann mehrere Modelle freischalten; Modell-ID,
Kontingent und Berechtigungen bleiben separat zu prüfen. Echte Werte gehören nie in diese
Dokumentation.

### 1.1 Google Gemini API-Key

**Zweck:** Optionaler externer Modellzugang, nicht zwingender Standard. Der im Setup dokumentierte
Bezug erfolgt über Google AI Studio. Dort einen eigenen Schlüssel erstellen, einschränken und ein
Kostenlimit prüfen. Im verwendenden Tool `GEMINI_API_KEY` setzen; einige Google-SDKs erwarten
stattdessen `GOOGLE_API_KEY`. Das ist keine allgemeine Alias-Garantie. Modell-ID im aktuellen Konto
prüfen, keine alte Beispielversion voraussetzen.

### 1.2 Google Kalender API (für gcali Skill)

Kalenderzugriff verwendet OAuth, nicht den Gemini-Key. In der Google Cloud Console Kalender-API,
Einwilligungsdialog und passenden OAuth-Client einrichten. Clienttyp und Redirect-URI müssen zum
tatsächlich eingesetzten Skill passen. Keine historische Callback-URL ungeprüft übernehmen.
Relevante Setup-Felder:

| Feld                        | Bedeutung                                                |
| --------------------------- | -------------------------------------------------------- |
| `GOOGLE_CLIENT_ID`          | OAuth-Clientkennung, kein geheimer API-Key               |
| `GOOGLE_CLIENT_SECRET`      | Clientgeheimnis, sofern dieser Clienttyp eines verwendet |
| `GOOGLE_REDIRECT_URI`       | Exakt registrierte Rücksprungadresse                     |
| OAuth-Refresh-/Access-Token | Separat geschützt im Credential-Speicher des Clients     |

Nur nötige Kalenderrechte erteilen; Widerruf und Token-Ablauf berücksichtigen.

### 1.3 Cloudflare Tunnel Token

Ein Tunnel ersetzt weder Authentifizierung noch eine Zugriffspolitik. Die Hauptvorlage kennt
`CLOUDFLARE_TUNNEL_TOKEN`; die historische OpenClaw-Vorlage kennt `CLOUDFLARE_TUNNEL_ID` und
`CLOUDFLARE_TUNNEL_SECRET`. Diese Betriebsarten nicht vermischen: Tunnel-ID ist keine
Zugangserlaubnis, ein Tunnel-Token kein allgemeiner Cloudflare-API-Key. Maßgeblich ist die
[Cloudflare-Tunnel-Anleitung](../CLOUDFLARE_TUNNEL_GUIDE.md). Keine Admin-Oberfläche ohne
vorgeschaltete Authentifizierung veröffentlichen.

### 1.4 Hurricane Electric Dynamic DNS (DDNS) Key

Ein DDNS-Update-Key ist auf den gewünschten DNS-Record zu begrenzen und getrennt vom Kontopasswort
abzulegen. DDNS aktualisiert Adressen, bietet aber keinen Reverse Proxy oder DDoS-Schutz. Die
[HE-DNS-Anleitung](../HURRICANE_ELECTRIC_DNS_DDOS_GUIDE.md) beschreibt die projektspezifischen
Schritte. Keine URL mit eingebettetem Key protokollieren.

### 1.5 Kimi / Moonshot API-Key

`KIMI_API_KEY` ist in der Setup-Vorlage vorgesehen. Benötigt wird er nur für einen bewusst gewählten
externen Kimi-/Moonshot-Zugang. Ein lokales Modell oder ein geklontes Referenzrepository braucht
diesen Cloud-Key nicht. Provider-Region, Clientunterstützung, Endpunkt und Billing vorher prüfen.
Bei Nutzung über OpenRouter gilt dessen Schlüssel statt eines Direkt-Keys.

### 1.6 Hugging Face API Token

`HF_TOKEN` dient optional dem Zugriff auf geschützte oder freigabepflichtige Modelle und Datensätze
sowie autorisierte Hub-Funktionen. Öffentliche Downloads benötigen nicht grundsätzlich einen Token.
Nur erforderliche Leserechte vergeben; Repository-Freigaben und Modelllizenzen gelten zusätzlich.
Token im externen Benutzer-Workspace halten; kein automatischer Modellabruf.

### 1.7 Weitere API-Keys (n8n, Activepieces, Zenbot und andere)

Die vollständige, nach Zwecken gegliederte Liste steht im
[API-Key-Katalog](PROVIDER_KEY_CATALOG.md). n8n und Activepieces verwalten Credentials je
Integration; ein Plattform-Key ersetzt keine Provider-Keys. Börsen-/Wallet-Zugänge getrennt halten,
keine Auszahlungsrechte oder Live-Trades als Standard. Private Wallet-Keys und Seed-Phrases niemals
als LLM-Key verwenden.

### 1.8 Dokumenten-, Recherche- und Rechtsprofile

Lokale PDF-Parser benötigen keinen Modellanbieter-Key. Externe Suche, Zotero-Synchronisation oder
juristische APIs können eigene Credentials benötigen. Personalakten oder vertrauliche
Rechtsdokumente nicht über einen ungeprüften Cloud-Fallback senden. Ein Connector-Eintrag bedeutet
nicht, dass eine Integration bereits implementiert oder getestet ist.

## 2. OpenClaw-Konfiguration

Die [OpenClaw-ENV-Dokumentation](../OPENCLAW_ENV_GUIDE.md) erklärt die
[Setup-Vorlage](../../scripts/config_templates/openclaw/.env.template). Sie enthält auch historische
Kompatibilitätsfelder. Nicht jedes Feld wird von jeder installierten OpenClaw-Version ausgewertet.

### 2.1 Wichtige Einstellungen

| Gruppe          | Felder und Hinweise                                                                      |
| --------------- | ---------------------------------------------------------------------------------------- |
| Lokales Modell  | `OLLAMA_HOST` / `OLLAMA_BASE_URL`, `OLLAMA_MODEL`; Loopback als Standard                 |
| Externe Modelle | Nur benötigte Anbieter-Keys setzen; kein stiller Cloud-Fallback                          |
| Gateway         | `OPENCLAW_GATEWAY_TOKEN`; getrennt vom Modellanbieter-Key                                |
| Legacy-Felder   | `JWT_SECRET`, `ADMIN_PASSWORD`, `DB_CONNECTION_STRING` nur bei tatsächlichem Verbraucher |
| OAuth / Tunnel  | Getrennte Secrets je Integration, keine universelle Zugangskopie                         |
| Domain          | Eigene geprüfte Domain, keine projekthistorische Domain übernehmen                       |

Echte Werte bleiben außerhalb des Repositorys. Der [ENV-Tresor](../ENV_VAULT.md) schützt getrennte
Werte mit einer Masterpassphrase; er ist kein gemeinsamer API-Key. Nur freigegebene Zieldateien
befüllen. [Secrets-Regeln](../SECRETS_AND_KEYS.md) beachten.

## 3. Port-Konfiguration und System-Check

Quelle für die registrierten Zuordnungen ist [config/ports.yml](../../config/ports.yml), ergänzt
durch die aktuelle Tool-Konfiguration. Ein Registry-Eintrag beweist keinen laufenden Dienst.
Historische Upstream-Defaults können von den Setup-Zuordnungen abweichen.

### 3.1 Wichtige Ports

| Dienst           | Offizielle Webseite                                                       | Setup-Port / Referenz        | Hinweis                                                     |
| ---------------- | ------------------------------------------------------------------------- | ---------------------------- | ----------------------------------------------------------- |
| Ollama           | [ollama.com](https://ollama.com/)                                         | 11434                        | Nur lokal                                                   |
| OpenClaw Gateway | [openclaw.ai](https://openclaw.ai/)                                       | 18789 laut Haupt-ENV-Vorlage | Tatsächliche Runtime prüfen; Legacy-Vorlage nennt auch 3000 |
| FreeLLMAPI       | [Offizielles GitHub-Projekt](https://github.com/tashfeenahmed/freellmapi) | 3011                         | Nur Loopback, eigene Client-Authentifizierung               |
| Home Assistant   | [home-assistant.io](https://www.home-assistant.io/)                       | 8123                         | Nicht offen ins Internet                                    |
| n8n              | [n8n.io](https://n8n.io/)                                                 | 5678                         | Credentials und Admin-Zugriff schützen                      |
| Open WebUI       | [openwebui.com](https://openwebui.com/)                                   | 3000                         | Keine öffentliche Standardfreigabe                          |
| Grafana          | [grafana.com](https://grafana.com/)                                       | 3001                         | Nicht mit Upstream-Default verwechseln                      |
| Huginn           | [Offizielles GitHub-Projekt](https://github.com/huginn/huginn)            | 3002                         | Registry-Zuordnung                                          |
| ComfyUI          | [comfy.org](https://comfy.org/)                                           | 8188                         | GPU-/Dateizugriff schützen                                  |

Die Links zeigen Anbieter-/Projektinformationen, nicht deine lokalen Admin-Oberflaechen. Keine Ports
oder externen Freigaben werden dadurch geaendert.

Portkonflikte vor Start prüfen. Keine pauschale Portfreigabe für alle Tools.

### 3.2 Firewall-Konfiguration (UFW)

Admin-, Modell- und Datenbankports standardmäßig nicht öffentlich freigeben. Dienste auf `127.0.0.1`
binden; bei Containern auch Host-Port-Mappings prüfen. Fernzugriff nur bewusst über VPN oder
authentifizierten TLS-Reverse-Proxy. Vor Firewall-Änderungen SSH-Zugang und Wiederherstellung
sichern. Siehe [Security Baseline](../SECURITY_BASELINE.md).

### 3.3 Nginx Rate Limiting

Beispiel für einen bereits abgesicherten Reverse Proxy, keine vollständige Produktionskonfiguration
und kein Schutz gegen volumetrische DDoS-Angriffe. Limits für Streaming, WebSockets und gemeinsame
NAT-Adressen separat testen.

```nginx
# Im http-Block:
limit_req_zone $binary_remote_addr zone=api_per_ip:10m rate=5r/s;

# In der passenden location, zusätzlich zu TLS und Authentifizierung:
limit_req zone=api_per_ip burst=10 nodelay;
limit_req_status 429;
```

Hinter einem vorgeschalteten Proxy nur vertrauenswürdige Proxy-Adressen für Real-IP-Auswertung
zulassen. Konfiguration vor Reload prüfen.

### 3.4 Regelmäßige Updates

Updates bewusst durchführen, Backups und Wiederherstellung testen. Ein Auto-Update ersetzt keine
Prüfung von Migrationen oder lokalen Änderungen.

## 4. DDoS- und Bot-Schutz

[DNS-/DDoS-Guide](../DNS_DDoS_GUIDE.md) und
[HE-/Oracle-Schutzkonzept](../HE_ORACLE_DDOS_PROTECTION.md) beachten. Rate Limits, optional
Fail2ban/CrowdSec und Provider-Schutz ergänzen sich; DNS allein versteckt oder schützt den
Ursprungsserver nicht automatisch.

## 5. Eigene Domain und Callback-URLs

Eigene Domain und DNS-Records passend zur gewählten Architektur einrichten. Bei einem Proxy dessen
Betriebsanleitung befolgen, nicht beliebige Cloudflare-IP-Adressen als A-Record eintragen. Bei
HE-DDNS zeigt der Record auf die konfigurierte Zieladresse. OAuth-Redirects müssen exakt mit dem
registrierten Client übereinstimmen. Keine öffentliche Freigabe ist Pflicht.
