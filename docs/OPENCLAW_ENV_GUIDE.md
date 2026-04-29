# OpenClaw .env Dokumentation

Diese Seite erklärt die `.env`-Vorlage unseres Setups, beschreibt die wichtigsten Bereiche verständlich auf Deutsch und dokumentiert zusätzlich die originale OpenClaw-`.env`-Beispielstruktur als Referenz.

## Zweck dieser Datei

Die führende Vorlage für unser Setup liegt hier:

- [scripts/config_templates/openclaw/.env.template](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/scripts/config_templates/openclaw/.env.template:1)

Sie wird vom OpenClaw-Konfigurationsmanager verwendet und verbindet:

- unsere Setup-spezifischen Werte
- die originale OpenClaw-Umgebungsstruktur
- zusätzliche Hinweise für lokale Installationen, WSL2, VPS und Hybrid-Setups

## Wichtige Hinweise

- Nur die Werte ausfüllen, die du wirklich nutzt.
- Echte Geheimnisse niemals in Git speichern.
- API-Schlüssel bitte über die übrige Projekt-Dokumentation beschaffen und eintragen.

Die wichtigsten Begleitseiten dazu sind:

- [docs/API_KEY_GUIDE.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/API_KEY_GUIDE.md:1)
- [docs/CLOUDFLARE_TUNNEL_GUIDE.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/CLOUDFLARE_TUNNEL_GUIDE.md:1)
- [docs/PRIVATE_REPO_GUIDE.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/PRIVATE_REPO_GUIDE.md:1)

## Datei `.env` laden

Dies funktioniert in diesem Fall nur im Verzeichnis von `OpenClaw`, also typischerweise unter `/opt/openclaw`.

```bash
cd /opt/openclaw
nano .env
```

### Nano-Spickzettel

Wichtige Tasten in `nano`:

- Speichern: `Ctrl` + `O`
- Bestätigen des Dateinamens: `Enter`
- Beenden: `Ctrl` + `X`
- Hilfe anzeigen: `Ctrl` + `G`
- Ausschneiden einer Zeile: `Ctrl` + `K`
- Einfügen: `Ctrl` + `U`
- Markierung starten: `Ctrl` + `^`
- Kopieren einer markierten Auswahl: `Alt` + `6`
- Suche starten: `Ctrl` + `W`
- Weitersuchen: `Alt` + `W`
- Suchen und Ersetzen: `Ctrl` + `\\`
- Zu Zeile springen: `Ctrl` + `_`
- Rückgängig: `Alt` + `U`
- Wiederholen: `Alt` + `E`
- Aktuelle Zeile/Spalte anzeigen: `Alt` + `C`
- Zeilenumbruch ein-/ausschalten: `Alt` + `L`
- Dateiinhalt an Cursorposition einfügen: `Ctrl` + `R`

Wichtig:

- `M-6` in Nano bedeutet `Meta + 6`
- auf den meisten Tastaturen ist das `Alt + 6`
- falls `Alt` in deiner Umgebung nicht sauber funktioniert, geht oft auch:
  - erst `Esc`
  - dann `6`

Typischer Ablauf zum Kopieren:

1. `Ctrl` + `^`
2. mit den Pfeiltasten markieren
3. `Alt` + `6`
4. `Ctrl` + `U` zum Einfügen

Typischer Ablauf zum Ausschneiden und Einfügen:

1. Cursor in die gewünschte Zeile stellen
2. `Ctrl` + `K` zum Ausschneiden
3. Cursor an Zielposition bewegen
4. `Ctrl` + `U` zum Einfügen

Typischer Ablauf zum Suchen:

1. `Ctrl` + `W`
2. Suchbegriff eingeben
3. `Enter`
4. `Alt` + `W` für den nächsten Treffer

## 1. Minimal `.env` für localhost

```env
# Security token for gateway access
OPENCLAW_GATEWAY_TOKEN=8c3f7c2c0e2d7a0c0b3a4d3f8e1f9c5a7b2e6f4c1d9a0e5f7b3c2d1a6e9f0c1

# Storage directory for OpenClaw state
OPENCLAW_STATE_DIR=/home/$USER/.openclaw

# Config file location
OPENCLAW_CONFIG_PATH=/home/$USER/.openclaw/openclaw.json

# Home directory
OPENCLAW_HOME=/home/$USER

# Load environment variables from shell
OPENCLAW_LOAD_SHELL_ENV=1

# Timeout for shell env loading
OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000
```

Für `localhost` reicht das komplett aus, nutzt aber noch kein Ollama.

## 2. Sicheres Gateway-Token erzeugen

Unter Linux, WSL oder Ubuntu:

```bash
openssl rand -hex 32
```

Beispiel:

```text
8c3f7c2c0e2d7a0c0b3a4d3f8e1f9c5a7b2e6f4c1d9a0e5f7b3c2d1a6e9f0c1
```

Das trägst du dann hier ein:

```env
OPENCLAW_GATEWAY_TOKEN=
```

Dieses Token ist das gemeinsame Authentifizierungs-Token zwischen OpenClaw-Client und Gateway.

Im Webinterface oder Client gibt es meist ein Feld wie `Gateway Token` oder `API Token`.

Genau dort trägst du diesen Wert ebenfalls mit ein.

Beim Verbinden gilt:

- Client sendet Token
- Gateway prüft Token
- nur wenn beide identisch sind, wird der Zugriff erlaubt

## 3. Token oder Passwort?

Du solltest nur eines von beiden verwenden.

`Token (empfohlen)`

```env
OPENCLAW_GATEWAY_TOKEN=
```

Vorteile:

- besser für APIs
- sicherer
- ideal für Automatisierung

`Passwort (Alternative)`

```env
OPENCLAW_GATEWAY_PASSWORD=meinSuperPasswort
```

Nicht gleichzeitig mit Token verwenden.

## 4. Verzeichnisstruktur

Nach dem ersten Start erstellt OpenClaw meist:

```text
~/.openclaw/
 ├── openclaw.json
 ├── state/
 ├── logs/
 └── cache/
```

Wenn du mehrere Instanzen oder Projekte planst, zum Beispiel für ein größeres KI-Projekt mit Ollama, kannst du auch etwas wie `~/ai/openclaw/` nutzen. Gegenwärtig ist das in unserem Setup aber nicht der Standardfall.

## 5. Wichtig für Ollama-Integration

Wenn du Ollama mit OpenClaw kombinierst, solltest du mindestens das hier ergänzen:

```env
OLLAMA_HOST=http://127.0.0.1:11434
```

Dann kann OpenClaw direkt dein lokales LLM ansprechen.

### Besonderheit unseres Setups: Primäranbieter und Fallbacks

Unser Setup unterstützt zwei typische Hybrid-Richtungen:

`Gemini primär, Ollama als Fallback`

```env
PRIMÄRES_LLM_ANBIETER=GEMINI
FALLBACK_TO_OLLAMA=true
```

Das ist in unserem Projekt die klassische und am besten vorbereitete Richtung.

`Ollama primär, Gemini als Fallback`

```env
PRIMÄRES_LLM_ANBIETER=OLLAMA
FALLBACK_TO_GEMINI=true
```

Das ist eine Besonderheit unseres Setups und dient dazu, lokal zuerst Ollama zu verwenden und nur bei Bedarf auf Gemini auszuweichen.

Wichtig:

- beide Provider müssen dafür sauber konfiguriert sein
- also sowohl `OLLAMA_HOST` als auch `GEMINI_API_KEY`
- im Chatfenster ist das nicht automatisch als frei sichtbarer Modellwähler garantiert
- die Auswahl wird in unserem Setup daher primär über `.env` und `config.json` gesteuert

Wenn du also im Alltag spontan zwischen Modellen wechseln willst, ist das in unserem Setup eher eine Konfigurationsentscheidung als eine reine Chat-UI-Auswahl.

## 6. Beispiel einer vollständigen lokalen `.env`

```env
OPENCLAW_GATEWAY_TOKEN=8c3f7c2c0e2d7a0c0b3a4d3f8e1f9c5a7b2e6f4c1d9a0e5f7b3c2d1a6e9f0c1

OPENCLAW_STATE_DIR=/home/BENUTZERNAME/.openclaw
OPENCLAW_CONFIG_PATH=/home/BENUTZERNAME/.openclaw/openclaw.json
OPENCLAW_HOME=/home/BENUTZERNAME

OPENCLAW_LOAD_SHELL_ENV=1
OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000

OLLAMA_HOST=http://127.0.0.1:11434
FALLBACK_TO_GEMINI=false
```

## 7. Datei speichern und starten

Speicherort im Projekt:

```text
openclaw/.env
```

oder global:

```text
~/.env
```

Danach starten:

```bash
openclaw start
```

oder:

```bash
npm start
```

Je nach Installationsmethode.

## Gateway auth + paths

Die Gateway-Authentifizierung + Pfade.

Dieser Bereich ist die Sicherheits- und Systemkonfiguration von OpenClaw. Hier geht es weniger um externe Anbieter und mehr darum, wie dein eigener Dienst abgesichert und gestartet wird.

### `OPENCLAW_GATEWAY_TOKEN`

```env
OPENCLAW_GATEWAY_TOKEN=change-me-to-a-long-random-token
```

Sehr wichtig, wenn dein Gateway:

- nicht nur auf `localhost`
- sondern auf `0.0.0.0`
- oder auf einem Server oder VPS
- oder in einem Docker-Container öffentlich erreichbar ist

Dann brauchst du einen starken Token.

Token erzeugen:

```bash
openssl rand -hex 32
```

Beispiel:

```text
9f3c2e8b7a4d6c1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7
```

Empfehlung: Immer setzen, sobald du nicht rein lokal arbeitest.

### `OPENCLAW_GATEWAY_PASSWORD`

```env
OPENCLAW_GATEWAY_PASSWORD=change-me-to-a-strong-password
```

Du kannst entweder Token oder Passwort verwenden, nicht beides.

Unterschied:

- Token: besser für API und automatisierte Clients
- Passwort: einfacher für manuelle Nutzung

Empfehlung: Token nutzen.

### `OPENCLAW_STATE_DIR`

```env
OPENCLAW_STATE_DIR=~/.openclaw
```

Hier speichert OpenClaw:

- Sessions
- Logs
- temporäre Daten
- Cache

Nur ändern, wenn du Docker-Volumes nutzt, mehrere Instanzen betreibst oder Daten getrennt speichern willst.

### `OPENCLAW_CONFIG_PATH`

```env
OPENCLAW_CONFIG_PATH=~/.openclaw/openclaw.json
```

Das ist die Haupt-Konfigurationsdatei.

Nur ändern, wenn du mehrere Konfigurationen parallel fahren willst oder ein spezielles Deployment-Setup hast.

### `OPENCLAW_HOME`

```env
OPENCLAW_HOME=~
```

Das definiert das Home-Verzeichnis für interne Pfade.

Normalerweise nicht nötig zu ändern. Relevanter bei Docker, CI/CD oder Service-Usern ohne echtes Home-Verzeichnis.

### `OPENCLAW_LOAD_SHELL_ENV`

```env
OPENCLAW_LOAD_SHELL_ENV=1
```

Das sagt OpenClaw:

`Lade Umgebungsvariablen aus meinem Login-Shell-Profil`

Also zum Beispiel aus:

- `.bashrc`
- `.zshrc`
- `.profile`

Praktisch, wenn du API-Keys dort gespeichert hast.

### `OPENCLAW_SHELL_ENV_TIMEOUT_MS`

```env
OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000
```

Timeout in Millisekunden, wie lange OpenClaw wartet, bis Shell-Variablen geladen wurden.

Standard: 15 Sekunden

Nur relevant, wenn dein Server langsam ist oder dein Shell-Profil sehr komplex ist.

### Typische Szenarien

`Lokal nur für dich`

Minimal:

```env
OPENCLAW_GATEWAY_TOKEN=<random>
```

`VPS / Public Server`

Unbedingt:

```env
OPENCLAW_GATEWAY_TOKEN=<sehr lang>
```

Optional zusätzlich:

- Reverse Proxy
- HTTPS
- Firewall

`Docker Setup`

Wichtig:

- `OPENCLAW_STATE_DIR` auf Volume mappen
- Gateway-Token setzen
- keine Secrets ins Image packen

### Sicherheitsrealität

Wenn du `0.0.0.0` bindest und keinen Token setzt, kann jeder auf dein Gateway zugreifen.

## API-Schlüssel des Modellanbieters (mindestens einen festlegen)

API-Schlüssel des Modellanbieters, mindestens einen festlegen.

Das ist das Herzstück für die eigentlichen LLM-Provider.

Wichtig:

- du brauchst meistens nur einen Anbieter
- mehrere Anbieter lohnen sich für Fallbacks oder Rotation
- bei einem Tippfehler im Schlüssel wirkt es oft so, als sei das Limit erreicht oder der Key gesperrt

### `OPENAI_API_KEY`

```env
OPENAI_API_KEY=sk-...
```

So bekommst du ihn:

- [platform.openai.com](https://platform.openai.com/)
- Login
- `API Keys`
- `Create new secret key`

Der Schlüssel beginnt mit `sk-...`.

### `ANTHROPIC_API_KEY`

```env
ANTHROPIC_API_KEY=sk-ant-...
```

So bekommst du ihn:

- [console.anthropic.com](https://console.anthropic.com/)
- `API Keys`
- `Create Key`

Beginnt mit `sk-ant-...`.

### `GEMINI_API_KEY`

```env
GEMINI_API_KEY=...
```

So bekommst du ihn:

- [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
- `Create API Key`
- Projekt auswählen

### `OPENROUTER_API_KEY`

```env
OPENROUTER_API_KEY=sk-or-...
```

OpenRouter ist praktisch, wenn du:

- viele Modelle testen willst
- mehrere Anbieter über eine API nutzen willst

Bezug:

- [openrouter.ai](https://openrouter.ai/)
- Account anlegen
- `API Keys`

### `OPENCLAW_LIVE_*`

```env
OPENCLAW_LIVE_OPENAI_KEY=...
OPENCLAW_LIVE_ANTHROPIC_KEY=...
OPENCLAW_LIVE_GEMINI_KEY=...
```

Das sind separate Schlüssel für Live-, Streaming- oder Realtime-Szenarien.

Du kannst denselben Schlüssel wie oben verwenden oder eigene Keys, wenn du Limits trennen willst.

### Mehrere API-Keys / Rotation

```env
OPENAI_API_KEYS=sk-1,sk-2
ANTHROPIC_API_KEYS=sk-ant-1,sk-ant-2
GEMINI_API_KEYS=key-1,key-2
```

Das ist nützlich für:

- höhere Last
- Ratenlimits
- Rotation

Wichtig:

- keine Leerzeichen
- per Komma trennen

Beispiel:

```env
OPENAI_API_KEYS=sk-abc123,sk-def456
```

### `GOOGLE_API_KEY`

```env
GOOGLE_API_KEY=...
```

Wird teils zusätzlich genutzt für:

- Google Services
- Vertex AI
- spezielle Gemini-Endpunkte

Bezug über die Google Cloud Console unter `APIs & Services` und `Credentials`.

### Weitere optionale Provider

Nur wenn du sie explizit nutzen willst:

- `ZAI_API_KEY`
- `AI_GATEWAY_API_KEY`
- `MINIMAX_API_KEY`
- `SYNTHETIC_API_KEY`

Für die meisten Setups sind diese nicht nötig. Der Grund ist in unserem Projekt ganz schlicht:

- das Standard-Setup läuft bereits mit `Ollama`, `OpenAI`, `Anthropic`, `Gemini` oder `OpenRouter`
- die vier folgenden Schlüssel sind eher Zusatzfälle für spezielle Provider, Routing oder Experimente
- sie sind also nicht deshalb unnötig, weil einige davon aus China kommen, sondern weil sie im Standardszenario nicht gebraucht werden

Wichtig vorweg:

- anonyme Nutzung ist bei diesen Diensten in der Praxis normalerweise nicht vorgesehen
- fast immer brauchst du mindestens ein Benutzerkonto
- ob zusätzlich Guthaben, Kreditkarte oder andere Zahlungsdaten nötig sind, hängt vom jeweiligen Anbieter und Tarif ab
- Preise und Bedingungen ändern sich; deshalb immer kurz auf der offiziellen Preisseite gegenprüfen

### `ZAI_API_KEY`

`Z.AI` ist der Entwicklerzugang zur GLM-/Zhipu-Welt. Das ist nach meiner Einordnung ein chinesischer Anbieter beziehungsweise ein international auftretender Ableger von Zhipu.

Warum meist nicht nötig:

- unser Setup funktioniert schon ohne Z.AI direkt mit OpenAI, Anthropic, Gemini, OpenRouter oder lokalem Ollama
- Z.AI ist daher eher eine Zusatzoption, wenn du bewusst GLM-Modelle nutzen willst

Zugang und Kosten:

- nicht anonym
- Registrierung/Login erforderlich
- laut offizieller Quick-Start-Doku muss man bei Bedarf die Billing-Seite aufladen
- laut offizieller Pricing-Seite gibt es aktuell auch kostenlose Modelle beziehungsweise zeitweise kostenlose Varianten, etwa `GLM-4.7-Flash` oder `GLM-4.5-Flash`
- kostenpflichtige Modelle werden tokenbasiert abgerechnet; die offene Pricing-Seite zeigt je nach Modell ungefähr Preise vom sehr kleinen Cent-Bereich pro 1M Tokens bis in den mehrstelligen Dollarbereich

Zahlungsweg:

- in den von mir geprüften offiziellen Quellen ist ein Billing-/Top-up-Prozess dokumentiert
- ich habe dort aber keine belastbare offizielle Aussage zu PayPal, KYC oder konkreten Kartenarten gesehen

### `AI_GATEWAY_API_KEY`

Die Bezeichnung passt sehr wahrscheinlich zu `Vercel AI Gateway`. Falls du einen anderen Gateway-Anbieter meinst, muss man das separat prüfen.

Warum meist nicht nötig:

- du brauchst einen AI-Gateway nur, wenn du Provider bündeln, Requests routen, zentrale Abrechnung, Caching oder Monitoring über mehrere Modelle hinweg willst
- für einen normalen OpenClaw-Start mit lokalem Ollama oder einem einzelnen Provider ist das nicht erforderlich

Zugang und Kosten:

- nicht anonym
- Vercel-Konto erforderlich
- laut offizieller Vercel-Doku gibt es aktuell eine Free Tier mit `$5` monatlichem AI-Gateway-Credit
- darüber hinaus Pay-as-you-go ohne Aufschlag auf die gelisteten Modellpreise

Zahlungsweg:

- für die kostenlose Stufe reicht der Account
- für kostenpflichtige Nutzung verweist Vercel auf hinterlegte Zahlungsmethoden beziehungsweise Kartenabrechnung
- in den geprüften offiziellen Vercel-Quellen habe ich keine belastbare PayPal- oder KYC-Aussage für AI Gateway selbst gefunden

Hinweis:

- Falls du stattdessen `Cloudflare AI Gateway` meinst: Dort sind die Kernfunktionen laut offizieller Cloudflare-Doku aktuell grundsätzlich kostenlos mit Cloudflare-Account nutzbar, aber das ist sehr wahrscheinlich nicht die API-Key-Bezeichnung, die hier gemeint ist

### `MINIMAX_API_KEY`

`MiniMax` ist nach meiner Einordnung ebenfalls ein chinesisch geprägter beziehungsweise chinesisch gegründeter Anbieter mit internationaler Ausrichtung.

Warum meist nicht nötig:

- unser Setup braucht MiniMax nicht als Pflichtbestandteil
- sinnvoll wird es nur, wenn du gezielt MiniMax-Modelle für Text, Audio, Video oder Musik testen willst

Zugang und Kosten:

- nicht anonym
- Registrierung/Login erforderlich
- laut offizieller Doku gibt es kostenlose Startmöglichkeiten beziehungsweise freie Registrierung mit kostenlosem Kontingent
- zusätzlich gibt es kostenpflichtige Token-, Abo- und Pay-as-you-go-Modelle
- die öffentliche Pricing-Kommunikation zeigt kleine Entwicklerpläne ungefähr ab `¥29/Monat`; je nach API-Bereich können die Preise aber stark schwanken

Zahlungsweg:

- Billing-/Aufladung ist offiziell vorgesehen
- ich habe in den geprüften offiziellen Quellen keine saubere Bestätigung zu PayPal, KYC oder konkreten Kartenpflichten gefunden

### `SYNTHETIC_API_KEY`

`Synthetic` wirkt in diesem Kontext weniger wie ein einzelnes Grundmodell, sondern eher wie ein Zugangsdienst beziehungsweise Modell-Gateway mit Anthropic-kompatibler API.

Warum meist nicht nötig:

- wenn du bereits direkte Provider nutzt, brauchst du Synthetic nicht zwingend
- interessant ist es eher, wenn du bewusst dessen Modellzugang, Flatrate-Ansatz oder kompatible API nutzen willst

Zugang und Kosten:

- nicht anonym
- Account/Login erforderlich
- laut offizieller Synthetic-Doku gibt es Subscription-Packs und zusätzlich usage-based pricing
- die offene Pricing-Seite zeigt aktuell etwa `$1/Tag` beziehungsweise `$30/Monat` für ein Subscription-Pack
- die Seite beschreibt außerdem usage-based pricing, ohne auf der Übersichtsseite jede Einzelbedingung im Detail auszuschreiben

Zahlungsweg:

- die offizielle Pricing-Seite nennt Sign-up/Login, aber ich habe dort keine belastbare Bestätigung zu PayPal, KYC oder genauen Zahlungsmittelarten gesehen

### Minimal-Setup Empfehlung

Wenn du es einfach halten willst:

```env
OPENAI_API_KEY=sk-...
```

oder:

```env
ANTHROPIC_API_KEY=sk-ant-...
```

Das reicht jeweils komplett.

### Sicherheit

- niemals in GitHub pushen
- `.env` in `.gitignore`
- keine Screenshots posten
- nicht in Chats oder Discord teilen

## Kanäle (nur die aktivierten Kanäle festlegen)

Hier die Kanäle. Nur die Kanäle setzen, die du wirklich nutzt.

Wenn du zum Beispiel nur Telegram nutzen willst, kannst du Discord oder Slack komplett ignorieren.

### `TELEGRAM_BOT_TOKEN`

```env
TELEGRAM_BOT_TOKEN=...
```

So bekommst du ihn:

- Telegram öffnen
- `@BotFather` suchen
- `/newbot`
- Namen vergeben
- Username festlegen, der auf `bot` endet

Danach bekommst du einen Token wie:

```text
123456789:ABCDEF....
```

Plugin aktivieren:

```bash
openclaw plugins enable telegram
```

Dann neu starten:

```bash
openclaw stop
openclaw start
```

Oder unter WSL meist besser:

```bash
openclaw gateway restart
```

### `DISCORD_BOT_TOKEN`

```env
DISCORD_BOT_TOKEN=...
```

So bekommst du ihn:

- [discord.com/developers/applications](https://discord.com/developers/applications)
- `New Application`
- links `Bot`
- `Add Bot`
- `Reset Token`

Wichtig:

`Message Content Intent` und andere nötige `Privileged Gateway Intents` aktivieren.

Plugin aktivieren:

```bash
openclaw plugins enable discord
```

Dann neu starten:

```bash
openclaw stop
openclaw start
```

Oder unter WSL oft besser:

```bash
openclaw gateway restart
```

### `SLACK_BOT_TOKEN` und `SLACK_APP_TOKEN`

```env
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
```

So bekommst du sie:

- [api.slack.com/apps](https://api.slack.com/apps)
- `Create New App`
- `OAuth & Permissions`
- Bot-Scopes setzen
- `Install to Workspace`

Danach erhältst du:

- `xoxb-...` für den Bot-Token
- `xapp-...` für den App-Level-Token

### `OPENCLAW_TWITCH_ACCESS_TOKEN`

```env
OPENCLAW_TWITCH_ACCESS_TOKEN=oauth:...
```

So bekommst du ihn:

- [dev.twitch.tv/console/apps](https://dev.twitch.tv/console/apps)
- neue App anlegen
- Client ID und Secret
- Access-Token per OAuth erzeugen

## Tools + voice/media (optional)

Ab hier kommen die Werkzeuge plus Sprach- und Medienfelder. Diese sind optional.

### `BRAVE_API_KEY`

Für Websuche via Brave:

- [api.search.brave.com](https://api.search.brave.com/)
- Account anlegen
- API-Key generieren

Dann:

```env
BRAVE_API_KEY=...
```

### `PERPLEXITY_API_KEY`

Von Perplexity:

- [www.perplexity.ai/settings/api](https://www.perplexity.ai/settings/api)
- API-Key erzeugen

Beginnt meist mit:

```text
pplx-...
```

### `FIRECRAWL_API_KEY`

Von Firecrawl:

- [firecrawl.dev](https://firecrawl.dev)
- Account anlegen
- API-Key erstellen

### `ELEVENLABS_API_KEY`

Von ElevenLabs:

- [elevenlabs.io](https://elevenlabs.io)
- Profil öffnen
- API-Key erzeugen

Dann:

```env
ELEVENLABS_API_KEY=...
```

`XI_API_KEY` ist nur ein Alias. Du kannst denselben Schlüssel verwenden.

### `DEEPGRAM_API_KEY`

Von Deepgram:

- [console.deepgram.com](https://console.deepgram.com)
- API-Key erstellen

## Wichtig zum Eintragen

In deiner `.env`:

- das `#` bei einem wirklich genutzten Eintrag entfernen
- nur die Dienste eintragen, die du fertig eingerichtet hast
- schrittweise arbeiten, weil die Einrichtung etwas Zeit braucht

Der beste Weg ist, die `.env` mit der Zeit in einem Editor zu pflegen. Speichere dir diese `.env` lokal, zum Beispiel auf deinem PC, und füge sie später per Copy und Paste in den Editor unseres Setups mit ein. Niemals auf GitHub hochladen!

Beispiel:

```env
TELEGRAM_BOT_TOKEN=123456:ABCDEF
BRAVE_API_KEY=abc123
```

## Originale OpenClaw `.env` Referenz

Nachfolgend ist die originale OpenClaw-`.env`-Beispielstruktur dokumentiert, die du mir gegeben hast.

```dotenv
# OpenClaw .env example
#
# Quick start:
# 1) Copy this file to `.env` (for local runs from this repo), OR to `~/.openclaw/.env` (for launchd/systemd daemons).
# 2) Fill only the values you use.
# 3) Keep real secrets out of git.
#
# Env-source precedence for environment variables (highest -> lowest):
# process env, ./.env, ~/.openclaw/.env, then openclaw.json `env` block.
# Existing non-empty process env vars are not overridden by dotenv/config env loading.
# Note: direct config keys (for example `gateway.auth.token` or channel tokens in openclaw.json)
# are resolved separately from env loading and often take precedence over env fallbacks.

# -----------------------------------------------------------------------------
# Gateway auth + paths
# -----------------------------------------------------------------------------
# Recommended if the gateway binds beyond loopback.
OPENCLAW_GATEWAY_TOKEN=change-me-to-a-long-random-token
# Example generator: openssl rand -hex 32

# Optional alternative auth mode (use token OR password).
# OPENCLAW_GATEWAY_PASSWORD=change-me-to-a-strong-password

# Optional path overrides (defaults shown for reference).
# OPENCLAW_STATE_DIR=~/.openclaw
# OPENCLAW_CONFIG_PATH=~/.openclaw/openclaw.json
# OPENCLAW_HOME=~

# Optional: import missing keys from your login shell profile.
# OPENCLAW_LOAD_SHELL_ENV=1
# OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000

# -----------------------------------------------------------------------------
# Model provider API keys (set at least one)
# -----------------------------------------------------------------------------
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
# GEMINI_API_KEY=...
# OPENROUTER_API_KEY=sk-or-...
# OPENCLAW_LIVE_OPENAI_KEY=sk-...
# OPENCLAW_LIVE_ANTHROPIC_KEY=sk-ant-...
# OPENCLAW_LIVE_GEMINI_KEY=...
# OPENAI_API_KEY_1=...
# ANTHROPIC_API_KEY_1=...
# GEMINI_API_KEY_1=...
# GOOGLE_API_KEY=...
# OPENAI_API_KEYS=sk-1,sk-2
# ANTHROPIC_API_KEYS=sk-ant-1,sk-ant-2
# GEMINI_API_KEYS=key-1,key-2

# Optional additional providers
# ZAI_API_KEY=...
# AI_GATEWAY_API_KEY=...
# MINIMAX_API_KEY=...
# SYNTHETIC_API_KEY=...

# -----------------------------------------------------------------------------
# Channels (only set what you enable)
# -----------------------------------------------------------------------------
# TELEGRAM_BOT_TOKEN=123456:ABCDEF...
# DISCORD_BOT_TOKEN=...
# SLACK_BOT_TOKEN=xoxb-...
# SLACK_APP_TOKEN=xapp-...

# Optional channel env fallbacks
# MATTERMOST_BOT_TOKEN=...
# MATTERMOST_URL=https://chat.example.com
# ZALO_BOT_TOKEN=...
# OPENCLAW_TWITCH_ACCESS_TOKEN=oauth:...

# -----------------------------------------------------------------------------
# Tools + voice/media (optional)
# -----------------------------------------------------------------------------
# BRAVE_API_KEY=...
# PERPLEXITY_API_KEY=pplx-...
# FIRECRAWL_API_KEY=...

# ELEVENLABS_API_KEY=...
# XI_API_KEY=...  # alias for ElevenLabs
# DEEPGRAM_API_KEY=...
```
