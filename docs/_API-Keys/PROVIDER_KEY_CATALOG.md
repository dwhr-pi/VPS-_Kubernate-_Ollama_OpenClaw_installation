# API-Key-Katalog des Ultimate KI Setups

**Zweck:** Alle im Repository dokumentierten Modellanbieter- und Dienstzugänge
an einer Stelle finden. Ein Anbieter-Key kann mehrere Modelle freischalten;
es gibt normalerweise keinen eigenen Key je Modell. Lokal geladene Modelle
brauchen nicht automatisch einen Cloud-Key.

Stand: Repository-Bestandsaufnahme vom 20.10.2026. **Keine echten Schlüssel,
keine Prüfung privater ENV-Dateien und keine Aktivierung externer Dienste.**
Die Auflistung beschreibt deklarierte Variablen und Credential-Arten, nicht
lokal vorhandene Konten oder nachgewiesen funktionierende Integrationen.

## Quellen und Verbindlichkeit

- [OpenClaw-Vorlage](../../scripts/config_templates/openclaw/.env.template)
  und [ENV-Erklärung](../OPENCLAW_ENV_GUIDE.md): deklarierte Felder, teilweise Legacy.
- [Haupt-ENV-Vorlage](../../.env.example): lokale Gateway-/Infrastrukturzugänge.
- [Tool-Skripte](../../scripts/tools/): zusätzliche Connector-Vorlagen;
  ein Scaffold ist noch keine fertige API-Anbindung.
- [WebsiteFactory-Vorlage](../../tools/websitefactory/.env.example): eigene
  Variablennamen, nicht automatisch identisch mit OpenClaw.
- [FreeLLMAPI](../tools/freellmapi.md): Upstream-Keys im Router, separater
  Unified Key beim Client. Keine automatische Übernahme sämtlicher Secrets.

Variablen sind **toolabhängig**, keine universellen SDK-Aliase. Eine Tabelle
registriert keinen neuen Provider. Aktuelle Modell-IDs, Preise, Kontorechte
und Endpunkte vor Nutzung beim gewählten Anbieter prüfen.

## 1. Modellanbieter und Modellzugänge

| Anbieter / Zugang | Im Setup deklarierter Schlüssel | Zweck und Grenze |
|---|---|---|
| OpenAI | `OPENAI_API_KEY` | Direkter externer Modellzugang; nicht mit einem fremden OpenAI-kompatiblen Dienst verwechseln |
| Anthropic / Claude | `ANTHROPIC_API_KEY` | Direkter Claude-API-Zugang; ein Claude-Chat-Abo ist kein allgemeiner API-Key |
| WebsiteFactory / Claude | `CLAUDE_API_KEY` | Eigener Vorlagenname dieses Tools, kein garantierter SDK-Alias |
| Google Gemini | `GEMINI_API_KEY`, optional `GOOGLE_API_KEY` | Je Client passenden Namen verwenden; nicht Kalender-OAuth |
| Kimi / Moonshot | `KIMI_API_KEY` | Projektspezifisches Vorlagenfeld; tatsächlichen API-Client prüfen |
| Z.AI / GLM | `ZAI_API_KEY` | Optionales Provider-Feld der OpenClaw-Vorlage |
| MiniMax | `MINIMAX_API_KEY` | Optionaler externer Zugang, Modell-/Produktfreigabe prüfen |
| Synthetic | `SYNTHETIC_API_KEY` | Optionaler Provider-/Gateway-Zugang |
| EULLM | `EULLM_API_KEY` plus `EULLM_BASE_URL` | Juristischer Connector-Platzhalter; kein eindeutig festgelegter Anbieter und kein Funktionsnachweis |
| Hugging Face | `HF_TOKEN` | Hub, geschützte Modelle/Datensätze oder Inferenz nach Berechtigung; kein Pflicht-Key für alle öffentlichen Downloads |

Die OpenClaw-Vorlage enthält außerdem `OPENAI_API_KEY_1`,
`ANTHROPIC_API_KEY_1`, `GEMINI_API_KEY_1` sowie `OPENAI_API_KEYS`,
`ANTHROPIC_API_KEYS`, `GEMINI_API_KEYS` als Rotations-/Mehrschlüsselfelder.
Die tatsächliche Clientunterstützung prüfen; mehrere Werte nicht blind in ein
Einzelschlüsselfeld kopieren. Live-Modus-Felder sind
`OPENCLAW_LIVE_OPENAI_KEY`, `OPENCLAW_LIVE_ANTHROPIC_KEY` und
`OPENCLAW_LIVE_GEMINI_KEY`; sie aktivieren sich nicht durch Dokumentation.

## 2. Ein Schlüssel für mehrere Anbieter / lokale Router

| Dienst | Schlüssel / Credential | Einordnung |
|---|---|---|
| [OpenRouter](OnlineOnKeyServices/openrouter.md) | `OPENROUTER_API_KEY` | Externer Aggregator; eigener Key, Modell-ID und Budget |
| [token8341](OnlineOnKeyServices/token8341.md) | `TOKEN8341_API_KEY` | Dokumentierter Integrationsname; Endpunktwidersprüche vor Nutzung klären |
| AI Gateway | `AI_GATEWAY_API_KEY` | Optionales, nicht eindeutig an einen Betreiber gebundenes Feld; Anbieter und Client explizit festlegen |
| FreeLLMAPI | `FREELLMAPI_API_KEY` | In der Client-Konfiguration lokaler Unified Key, kein Ersatz für Router-Upstream-Keys |
| LiteLLM / LocalAI / Open WebUI | Eigene dienst-/versionsabhängige Tokens | Kein einheitlicher Schlüsselname durch diesen Katalog zugesichert |

Die [OnlineOnKeyServices-Übersicht](OnlineOnKeyServices/README.md) beschreibt
das Aggregator-Prinzip. Ein Aggregator-Key ist kein Gratiszugang zu allen
Modellen. DeepSeek, Qwen, Mistral, GLM, Kimi oder MiniMax können je nach
freigegebenem Katalog über einen Router erreichbar sein; ein zusätzlicher
Direkt-Key ist dann nicht automatisch erforderlich. Lokale Varianten bleiben
davon unabhängig. Für nicht deklarierte Direkt-Provider werden hier bewusst
keine vermeintlich unterstützten ENV-Namen erfunden.

## 3. Recherche, Sprache, Audio und Video

| Dienst | Deklarierter Name | Zweck / Statusgrenze |
|---|---|---|
| Brave Search | `BRAVE_API_KEY` | Externe Websuche |
| Perplexity | `PERPLEXITY_API_KEY` | Externe Recherche-/Modell-API |
| Firecrawl | `FIRECRAWL_API_KEY` | Externer Crawl-/Extraktionszugang; lokale Variante separat prüfen |
| ElevenLabs | `ELEVENLABS_API_KEY`, `XI_API_KEY` | Voice-Zugang; Alias nur verwenden, wenn der Client ihn unterstützt |
| Deepgram | `DEEPGRAM_API_KEY` | Externe Speech-API |
| Runway | `RUNWAY_API_KEY` | API-Connector-Vorlage, keine lokale Videomodellinstallation |
| Suno | `SUNO_API_KEY` | Connector-Feld; offizielle API-Verfügbarkeit und Nutzungsrechte separat prüfen |
| Udio | `UDIO_API_KEY` | Connector-Feld; kein Nachweis einer offiziellen öffentlichen API |
| fal / Veo | Vom gewählten SDK unterstützte Credentials | Basis-SDK-Installation erzeugt weder Key noch Cloud-Freigabe; siehe [Fal Client](../tools/fal-client.md) und [Veo API](../tools/veo-api.md) |
| Weights & Biases | `WANDB_API_KEY` | Optionales externes Trainingstracking; nicht für lokalen Modellbetrieb nötig |

## 4. Business-, Marketing- und Dokumenten-Connectoren

| Integration | Deklarierter Name / Zugang | Hinweis |
|---|---|---|
| Ahrefs | `AHREFS_API_KEY` | Connector, Konto-/API-Berechtigung erforderlich |
| Semrush | `SEMRUSH_API_KEY` | Connector-Vorlage |
| Airtable | `AIRTABLE_API_KEY` | Historischer Connector-Name; aktuelle Credential-Art und Clientunterstützung prüfen |
| Notion | `NOTION_API_KEY` | Integrationstoken, nur freigegebene Seiten |
| HubSpot | `HUBSPOT_ACCESS_TOKEN` | Zugriff auf explizit freigegebene CRM-Daten |
| Buffer | `BUFFER_ACCESS_TOKEN` | Social-Connector; keine automatische Veröffentlichung |
| TikTok Ads | `TIKTOK_ADS_ACCESS_TOKEN` | Werbekonto-Rechte und Budget separat freigeben |
| Paperless-ngx | Persönlicher API-Token; `PAPERLESS_SECRET_KEY` ist dagegen ein App-Secret | Nicht verwechseln; Zugriff auf Personalakten streng begrenzen |
| Zotero | Bibliotheksbezogener API-Key nach Integration | Lokale Literaturverwaltung benötigt keinen API-Key |
| n8n / Activepieces | Eigene Plattform-Tokens plus Credentials je Verbindung | Plattform-Key ersetzt weder Modell-Key noch OAuth |

## 5. Bots, OAuth und Infrastruktur

| Integration | Schlüssel / Feld | Abgrenzung |
|---|---|---|
| Telegram | `TELEGRAM_BOT_TOKEN` | Botzugang |
| Discord | `DISCORD_BOT_TOKEN` | Botzugang, minimale Serverrechte |
| Slack | `SLACK_BOT_TOKEN`, `SLACK_APP_TOKEN` | Unterschiedliche Tokenrollen |
| Mattermost / Zalo | `MATTERMOST_BOT_TOKEN`, `ZALO_BOT_TOKEN` | Channel-Credentials |
| Twitch | `OPENCLAW_TWITCH_ACCESS_TOKEN` | OAuth-Token, Ablauf und Scopes beachten |
| Google Kalender | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, OAuth-Tokens | Client-ID ist nicht geheim; OAuth ist kein Gemini-Key |
| OpenClaw Gateway | `OPENCLAW_GATEWAY_TOKEN`, optional `OPENCLAW_GATEWAY_PASSWORD` | Lokale Runtime-Authentifizierung, kein Modellanbieter |
| Cloudflare | `CLOUDFLARE_TUNNEL_TOKEN` oder passende Tunnel-Credentials | Legacy: `CLOUDFLARE_TUNNEL_ID`, `CLOUDFLARE_TUNNEL_SECRET`; ID ist kein Secret |
| Tailscale | `TAILSCALE_AUTHKEY` | Geräteaufnahme, kein Inferenzzugang |
| Hurricane Electric DDNS | Record-Update-Key | Kein globaler Provider-Key; nicht in Request-Logs offenlegen |
| Home Assistant | Langzeit-Zugriffstoken nach Integration | Lokale Smart-Home-Rechte, keine Cloud-Pflicht |
| GitHub | PAT / OAuth / GitHub-App-Token nach Client | Öffentliche GitHub-Quellcode-Clones brauchen normalerweise keinen Key |
| OIDC | `OIDC_CLIENT_SECRET` | Identitätsprovider, kein Modellanbieter |
| Authentik / Penpot | `AUTHENTIK_SECRET_KEY`, `PENPOT_SECRET_KEY` | Anwendungsgeheimnisse, keine Benutzer-API-Tokens |
| Legacy-OpenClaw / Datenbanken | `JWT_SECRET`, `ADMIN_PASSWORD`, `DB_CONNECTION_STRING` | App-/Admin-/DB-Zugang, kann Secrets enthalten; nur bei tatsächlichem Verbraucher |
| Börsen / Automaton / Web3 | Börsen-Credentials, Wallet-Private-Key / Seed | Kein LLM-Key; keine Übergabe an Modellrouter, keine Live-Trades als Standard |

## 6. Was braucht keinen externen Anbieter-Key?

Lokales Ollama, heruntergeladene GGUF-Modelle über llama.cpp, lokale
ComfyUI-Workflows und lokal ausgeführte Voice-/Videomodelle benötigen für
die Inferenz normalerweise keinen Cloud-Key. Downloadrechte, Modelllizenzen
und eine eventuell vorgeschaltete lokale Authentifizierung bleiben separat.
Qwen Code, Claude Code und Gemini CLI sind Clients: Login, OAuth oder API-Key
hängen vom gewählten Backend und dessen unterstützter Authentifizierung ab.
Eine Quellcodeinstallation beweist noch keine Anmeldung oder Inferenzbereitschaft.

## 7. Sicher konfigurieren

Nur nötige Keys beschaffen, je Dienst trennen, Rechte und Kosten begrenzen.
Echte Werte ausschließlich im externen User-Workspace oder
[ENV-Tresor](../ENV_VAULT.md) speichern. Keine Wallet-Seeds in allgemeine
Router-ENV-Dateien kopieren. Kein Cloud-Fallback ohne Freigabe, keine Secrets
in Logs oder Git. [Secrets-Regeln](../SECRETS_AND_KEYS.md) beachten.

Zur [Übersicht](README.md) und zum [API-Key Guide](API_KEY_GUIDE.md).
