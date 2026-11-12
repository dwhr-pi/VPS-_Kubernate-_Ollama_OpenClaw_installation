# Hybride und fortgeschrittene KI-Infrastruktur

Cloud-Integration, grosse Open-Weight-Modelle und MCP-Gateways.
Gezielte Quellenpruefung: **11.11.2026**. Status: **documentation-first,
nicht installiert, Runtime nicht verifiziert**. Ergaenzt sind optionale
Registry-Eintraege fuer Quellenverwaltung, keine fertigen Runtime-Installationen.
Keine Downloads, Konten, Zahlungen, Provider-Tests oder Dienste durch dieses Kapitel.
Native GitHub-Source-Builds bleiben bevorzugt; **kein Docker-Fallback**.
Kubernetes mit eigener CRI ist keine Docker-Installationsfreigabe.

## Rollen im Hybrid-Setup

Tool-Anleitungen: [MiniMax-M3](tools/minimax-m3.md), [Obot](tools/obot.md),
[DeepSeek-R1](tools/deepseek-r1.md) und [vorhandenes LTX Video](tools/ltx-video.md).
Die APIs stehen separat unter [MiniMax](_API-Keys/OnlineOnKeyServices/minimax.md),
[Together](_API-Keys/OnlineOnKeyServices/together.md),
[DeepSeek](_API-Keys/OnlineOnKeyServices/deepseek.md) und
[LTX / Lightricks](_API-Keys/OnlineOnKeyServices/ltx.md).

VPS koordiniert, WireGuard verbindet, der Pi weckt und die Heim-GPU rechnet.
Cloud ist eine separat freizugebende Alternative, kein automatischer Ersatz
bei abgeschalteter RTX oder vollem VRAM.

```text
Agent / Open WebUI
  |
  +-- Modellaufrufe --> vorhandenes Inference-Gateway
  |                       +--> lokales Ollama auf der Heim-GPU (Standard)
  |                       +--> Together API (nur nach Daten-/Kostenfreigabe)
  |
  +-- Tool-Aufrufe ----> freigegebener MCP-Client / Tool-Layer
                          +--> optionales Obot-MCP-Gateway (zuerst evaluieren)
                                  +--> einzelne erlaubte MCP-Server
```

Modell-Gateway und MCP-Gateway sind unterschiedliche Rollen. Obots weitere
LLM-Funktionen sind kein Auftrag, den vorhandenen Modellrouter zu ersetzen
oder zwei Quota-/Fallback-Systeme ungeprueft hintereinanderzuschalten.

## 1. MiniMax-M3: grosse Gewichte, langer Kontext

Die offizielle Modellkarte beschreibt rund **428 Milliarden Gesamtparameter**,
etwa **23 Milliarden aktive Parameter je Token**, native Multimodalitaet und
bis zu **1 Million Kontexttoken** mit MiniMax Sparse Attention (MSA).
Die Dateiansicht rundet die gespeicherte Modellgroesse auf 427B; daher kein
Versprechen einer exakt identischen Parameterzahl oder Dateigroesse.
[Modellkarte](https://huggingface.co/MiniMaxAI/MiniMax-M3).

Der Hersteller nennt Code-/Agentenaufgaben und lange Kontexte als Einsatzfelder.
Das sind keine hier gemessenen Geschwindigkeits-, Qualitaets- oder Hardwaregarantien.
[Herstellerankuendigung](https://www.minimax.io/blog/minimax-m3).

Die Modellkarte verweist auf vLLM, SGLang, Transformers und KTransformers.
Das belegt Upstream-Anleitungen, nicht kompatible Versionen oder einen
fertigen Adapter dieses Setups. Auch ein Framework-Source-Build ersetzt keinen
geprueften Modell- und GPU-Vertrag.

### Lizenz und Speicher

**Open Weight ist nicht automatisch uneingeschraenkt Open Source.**
Die MiniMax Community License enthaelt eigene Bedingungen: unter anderem
Kennzeichnung und Mitteilung bei kommerzieller Nutzung sowie vorherige
Genehmigung oberhalb der dort genannten Umsatzgrenze. Einsatzbeschraenkungen
und vollstaendigen Lizenztext vor Nutzung separat pruefen; die Apache-2.0-Lizenz
dieses Repositories uebertraegt sich nicht auf die Gewichte.
[Original-Lizenz](https://huggingface.co/MiniMaxAI/MiniMax-M3/blob/main/LICENSE).

Eigene Untergrenzenrechnung fuer 428 Milliarden Parameter:
`428e9 * 4 / 8 / 2**30 = rund 199 GiB` reine Rohgewichte bei 4 Bit.
Quantisierungsmetadaten, KV-Cache, Aktivierungen und Runtime fehlen darin.
Die 23B aktiven Parameter bedeuten nicht, dass nur 23B Gewichte gespeichert
werden muessen. MSA-Effizienz beseitigt diese Gewichtsanforderung nicht.

Damit ist M3 **kein freigegebener Voll-GPU-Standard fuer eine einzelne RTX 5080**.
CPU-Offloading oder mehrere Beschleuniger brauchen eigene RAM-/VRAM-, Bandbreiten-
und Latenzmessungen. 1M Kontext ist keine Default-Einstellung fuer kleine VPS.
Vor einem Versuch: Modellrevision, Lizenz, SHA256 jeder Datei und Framework-Pin
festlegen; verfuegbaren Speicher und Cache-Wachstum pruefen.
Kein automatischer Hub-Download und kein ungeprueftes `trust_remote_code=True`.

## 2. Obot MCP Gateway Platform: Kandidat, kein fertiger Installer

Obot stellt Funktionen fuer MCP-Verwaltung und AI-Governance bereit; der
gelesene Quellstand `251f96eb1ddae99d61e78a15b7a96115fc45630b` steht unter MIT.
[Offizielles Repository am Stand](https://github.com/obot-platform/obot/tree/251f96eb1ddae99d61e78a15b7a96115fc45630b),
[Lizenz](https://github.com/obot-platform/obot/blob/251f96eb1ddae99d61e78a15b7a96115fc45630b/LICENSE).

OAuth-/Authentifizierungsfunktionen sind **keine OAuth-Zertifizierung**
und kein Nachweis lueckenloser Protokollierung. OAuth kontrolliert allein
weder Tool-Berechtigungen noch Datenabfluss, Prompt-Injection oder Shell-Rechte.
Vor Betrieb: Server-Allowlist, Benutzer-/Mandantenzuordnung, eng begrenzte
Scopes, Tool-Freigaben, Egress und redigierte Audit-Logs einzeln abnehmen.

### Kosten, Offline-Grenzen und Betriebsweg

Die gelesene Editionsdokumentation nennt die kostenlose Community-Edition
mit **bis zu 100 Nutzern und 100 verwalteten Geraeten**. Registrierung,
weitere Auth-Provider und Enterprise sind gesondert zu bewerten.
Registrierung uebermittelt Angaben an den Anbieter; konfigurierte Lizenzkeys
nutzen externe Validierung. Daraus folgt keine pauschale Air-Gap-Zusage.
Eigene Infrastruktur und Betrieb bleiben kostenpflichtig.
[Editionen und Lizenzbetrieb](https://docs.obot.ai/enterprise/overview/).

Die Upstream-Produktionsanleitung verlangt Kubernetes, externes PostgreSQL 17+,
Authentifizierung, TLS, Verschluesselungsanbieter und Backup. Ein einzelnes
Gateway ist daher nicht automatisch eine leichte, vollstaendig offline betreibbare
Ergaenzung fuer einen kleinen VPS.
[Deployment-Anforderungen](https://docs.obot.ai/installation/overview/).

Die [Entwicklungsanleitung am Stand](https://github.com/obot-platform/obot/blob/251f96eb1ddae99d61e78a15b7a96115fc45630b/DEVELOPMENT.md)
ist **kein freigegebenes natives Produktions-Buildrezept** dieses Setups.
Ihre Entwicklungsstarts werden nicht uebernommen.
Ein GitHub-Source-Build, Laufzeitdefinition, Update/Uninstall, Smoke-Test und
Datenbank-Restore fehlen hier als abgenommener Obot-Gesamtvertrag.
Kein Docker-Socket, kein automatischer MCP-Server-Start, kein Helm-Apply.

Empfehlung: Obot erst evaluieren, wenn mehrere MCP-Server oder Mandanten eine
zentrale Verwaltung rechtfertigen. Fuer wenige lokale Tools den bestehenden
[MCP Server Hub](MCP_SERVER_HUB.md) und seine Allowlist-Grenzen bevorzugen.

## 3. Together AI: bezahlte Cloud-Inferenz

Together ist ein externer Inferenzdienst, kein lokal installierbares Tool.
Der aktuelle Self-Service-Billing-Beleg sagt: **kein allgemeines kostenloses
Trial**, **paid-prepaid**, erster Guthabenkauf mindestens **15 USD**,
Folgekaeufe mindestens **5 USD**. Ohne positives Guthaben keine regulaere Nutzung.
Scale-/Enterprise-Vertraege separat behandeln; Sonderaktionen nur mit eigenem
Beleg einplanen. Keine behaupteten Gratis-Credits oder kostenlose Ersatzinferenz.
[Credits und Billing](https://docs.together.ai/docs/billing-credits).

Automatisches Nachladen kann weitere Zahlungen ausloesen; nicht einschalten.
Modellpreise, Rate-Limits, Ablauf-/Erstattungsregeln und Kontobedingungen vor
Nutzung pruefen. Hier wurden weder Zahlungsmittel noch Konten abgefragt.
Die Nennung von MiniMax-M3 bedeutet nicht, dass Together dieses konkrete Modell
bereitstellt: Katalog, Modell-ID, Modalitaeten und Lizenz separat bestaetigen.

Standardmaessig beschreibt Together Prompt-/Antwortspeicherung und moegliche
Produktverbesserung; Training ist ein separates Opt-in. Passthrough-Modelle
koennen Daten an Drittanbieter weiterreichen. Organisationsbezogenes ZDR,
Modellroute, Speicher- und Verarbeitungsort vor Freigabe pruefen.
Kein pauschales Datenschutzversprechen aus lokaler UI oder TLS ableiten.
[Datenregeln](https://docs.together.ai/docs/privacy-and-security).

Im Setup: **Cloud-Fallback standardmaessig aus**. Jede externe Route braucht
Human Approval, Datenminimierung, konkreten Modellnamen und Kosten-/Tokenlimit.
Timeout/Retry ohne doppelte Kosten testen. API-Keys bleiben ausserhalb des Repos
und duerfen weder in Prompts noch MCP-Argumente oder Logs gelangen.
Bei lokaler Stoerung ohne Cloud-Freigabe warten/abbrechen, nicht heimlich umleiten.
Bestehende [Anbieterauswertung](./_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md).

## Freigabereihenfolge und Nachweise

1. Lokales Ollama und genau einen Modell-/Tool-Pfad als Baseline messen.
2. Fuer M3 zuerst Lizenz-/Speicherentscheidung treffen, noch nichts herunterladen.
3. Obot gegen vorhandene MCP-Gates vergleichen; keine zweite Plattform ohne Bedarf.
4. Together nur nach ausdruecklicher Daten-/Kostenfreigabe isoliert konfigurieren.
5. Erst dann separate Abnahme: Build, Auth-/Egress-Negativtests, Budget,
   Log-Redaktion, Abbruch, Update/Uninstall und Restore.

Der Quellenabruf ist **kein Laufzeitnachweis**. Keine neuen Menue-Haekchen,
kein Installationsstatus und keine Produktionsfreigabe werden erzeugt.
Weiterhin verbindlich: [Installationsrichtlinie](INSTALLATION_POLICY.md).
