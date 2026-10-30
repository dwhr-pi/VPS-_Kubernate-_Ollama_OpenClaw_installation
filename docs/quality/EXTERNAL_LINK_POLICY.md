# Externe Markdown-Links: Policy und PR-6-Befunde

Stand: 30.10.2026. Keine Merge- oder Produktionsfreigabe.

## Verbindlicher Check

Alle Markdown-Dateien bleiben im bestehenden Link-Gate. In jedem Workflow muss die Konfiguration
explizit angegeben werden; sie wird nicht automatisch gefunden:

```sh
markdown-link-check -c .github/markdown-link-check.json readme.md
find docs -type f -name '*.md' -print0 | xargs -0 -n1 markdown-link-check -c .github/markdown-link-check.json
```

Die zusaetzliche Einzelpruefung unter `scripts/quality/external_link_probe.py` ersetzt diesen Parser
und seine vollstaendige Markdown-Abdeckung nicht. Sie untersucht explizite Markdown-Ziele mit GET,
vier parallelen Anfragen, zehn Sekunden Timeout und hoechstens zwei Versuchen. Nur 200/206 gelten
nach Weiterleitungen als erreichbar. 202, 429, temporaere 5xx und Transportfehler erhalten einen
zweiten Versuch nach einer Sekunde; 403/404 bleiben Fehler. Keine Cookies, Tokens oder privaten
Kontodaten.

```sh
python -B scripts/quality/external_link_probe.py --markdown docs/quality/EXTERNAL_LINK_POLICY.md
python -B -m unittest discover -s tests -p test_external_link_policy.py
```

Der Zusatzcheck prueft Erreichbarkeit, nicht fachliche Richtigkeit. Ein HTTP 200 allein beweist
weder Lizenz, Rechtsstand noch die Existenz eines bestimmten Inhalts. Ein gescheiterter Abruf darf
nicht durch eine beliebige erreichbare Startseite ersetzt werden. Historische Quellen bleiben mit
unveraenderter URL und explizitem Befund als Inline-Code erhalten, nicht als angeblich aktuelle
Empfehlung.

## Exakte Auth-Klassifikation

Nur diese vier persoenlichen Kontoeinstiege sind in der Konfiguration exakt verankert. Sie werden
als AUTH/ausgenommen bezeichnet, niemals als verifizierter Inhalt. Die oeffentlichen Anleitungen in
den jeweiligen Registrierungsdokumenten bleiben aktiv geprueft. Andere Pfade, Query-Parameter,
Subdomains oder 401/403-Antworten sind damit nicht freigegeben.

| Kontoeinstieg                                        | Klassifikation                                                     |
| ---------------------------------------------------- | ------------------------------------------------------------------ |
| [Zotero Keys](https://www.zotero.org/settings/keys)  | Login erforderlich; gemeldeter Abruf 403; Inhalt nicht verifiziert |
| [Mistral Studio](https://console.mistral.ai/)        | Konto-Dashboard; gemeldeter Abruf 403; Inhalt nicht verifiziert    |
| [Cloudflare Dashboard](https://dash.cloudflare.com/) | Konto-Dashboard; gemeldeter Abruf 403; Inhalt nicht verifiziert    |
| [DeepSeek Platform](https://platform.deepseek.com/)  | Konto-Dashboard; gemeldeter Abruf 202; Inhalt nicht verifiziert    |

Die Beispiele `http://127.0.0.1:7860` und `http://127.0.0.1:4200` sind lokale Browseradressen, keine
oeffentlichen Quellen. Sie stehen als Code in den Anleitungen; Offline-Tests pruefen Scheme,
Loopback-Adresse und Port, ohne Dienste zu kontaktieren. Es gibt keine pauschale
localhost-/IP-/Domain-Ausnahme im Link-Gate.

## Quellenhistorie und Korrekturen

Die Alt-URLs stehen weiterhin an ihren urspruenglichen Fundstellen. Das duplizierte Setup-Audit ist
ein Quelleninventar, keine Liste funktionierender Installationen.

| Alte URL oder Klasse                                                                                           | Entscheidung und belegte Primaerquelle                                                                                                                                           |
| -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv5.8.2`                                 | 404; [Release mit unkodiertem Slash](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize/v5.8.2) inhaltlich abgerufen                                            |
| `https://hg.reportlab.com/hg-public/reportlab`                                                                 | 403; [ReportLab-Dokumentation](https://docs.reportlab.com/) inhaltlich abgerufen; kein Nachweis, dass das alte Repository geloescht ist                                          |
| `https://docs.n8n.io/sustainable-use-license/`                                                                 | 404; [Lizenz im offiziellen Repository](https://github.com/n8n-io/n8n/blob/master/LICENSE.md) inhaltlich abgerufen                                                               |
| `https://docs.mistral.ai/getting-started/models/weights/`                                                      | 404; [Modellkatalog](https://docs.mistral.ai/models) inhaltlich abgerufen; Lizenzen pro Modell pruefen                                                                           |
| `https://ai.google.dev/gemma/docs/core.md`                                                                     | Abruf 0; [HTML-Modelluebersicht](https://ai.google.dev/gemma/docs/core) inhaltlich abgerufen; kein pauschaler Nachweis fuer einen Markdown-Export                                |
| `modelcontextprotocol/server-filesystem`, `modelcontextprotocol/server-git`                                    | Alte Reponamen 404; Verzeichnisse im [offiziellen Monorepo](https://github.com/modelcontextprotocol/servers)                                                                     |
| `modelcontextprotocol/server-sqlite`, `modelcontextprotocol/server-postgres`, `servers/tree/main/src/sqlite`   | Alte Pfade 404; [offizielles Archiv](https://github.com/modelcontextprotocol/servers-archived); nicht mehr gepflegt, keine Produktionsfreigabe                                   |
| `https://codeberg.org/forgejo/forgejo.git`                                                                     | Clone-URL, Abruf 403; als Code erhalten, [offizielle Projektdokumentation](https://forgejo.org/docs/latest/) inhaltlich abgerufen; kein erfolgreicher Repository-Abruf behauptet |
| `https://github.com/bminor/bash`                                                                               | 404; GNU Bash bleibt aktive Primaerquelle, dessen Transportfehler bleiben Blocker                                                                                                |
| `https://github.com/canonical/ufw`                                                                             | 404; keine stillschweigende Behauptung eines existierenden GitHub-Repositories                                                                                                   |
| `https://github.com/flowiseai/flowisechatbot`                                                                  | 404; historischer Inventareintrag, nicht automatisch mit einem anderen Produkt gleichgesetzt                                                                                     |
| `https://github.com/openclaw/clawbake`                                                                         | 404; historisch, bestehender Clawbake-Leitfaden dokumentiert die separate Nutzerquelle                                                                                           |
| `https://github.com/till-schaefer/jarvis`                                                                      | 404; Nutzerquelle bleibt unverifiziert; keine Gleichsetzung mit Hermes                                                                                                           |
| `https://github.com/Microsoft/TypeScript-Node-Starter`, `https://github.com/microsoft/typescript-node-starter` | 404; historische Vorlage, keine aktuelle Sicherheitsempfehlung                                                                                                                   |
| `https://github.com/cheahjs/free-llm-api-resources`                                                            | 404; datierte Reviews bleiben erhalten; kein Nachweis dauerhafter Loeschung                                                                                                      |
| `https://github.com/dwhr-pi/content-multiplier`, `https://github.com/dwhr-pi/content-multiplier.git`           | 404; keine oeffentlich bestaetigte Quelle, keine Freigabe                                                                                                                        |
| `https://github.com/deinname/fingpt`, `https://github.com/username/huginn`                                     | Beispiel-/Fork-Platzhalter, keine Live-Repositories                                                                                                                              |
| `https://huggingface.co/datasets/ontocord/VALID/blob/1758855b0f16da2ba0edda156099cc5a78405a94/README.md`       | 401; historische Kartenrevision nicht erneut verifiziert, keine Auth-Ausnahme und keine aktuelle Lizenzbestaetigung                                                              |

## Oeffentliche Quellen mit gemeldeten Fehlern

Diese Liste umfasst alle uebrigen unterschiedlichen URLs aus dem gemeldeten Lauf; Mehrfachvorkommen
wurden zusammengefasst. Status 0 bedeutet Transportfehler, nicht HTTP. Keine dieser oeffentlichen
Quellen wird vom Gate ausgenommen. Die Spalte ist der **gemeldete CI-Befund**, keine Behauptung
eines erfolgreichen aktuellen Abrufs. Google Veo konnte im Recherchewerkzeug inhaltlich abgerufen
werden; ein solcher Browserabruf ersetzt keinen erfolgreichen anonymen CI-Abruf. Bei Rechtstexten
bleiben Zuordnung, Originalfassung, Konsolidierung und zeitliche Gueltigkeit separat zu pruefen.

| Quelle                                                                                                                                                     | Gemeldeter CI-Befund                          |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| [BMF DSGVO](https://amtliche-handbuecher.bundesfinanzministerium.de/ao/2026/Datenschutz-Grundverordnung/inhalt.html)                                       | 503                                           |
| [BDSG 26](https://www.gesetze-im-internet.de/bdsg_2018/__26.html)                                                                                          | 0                                             |
| [BMF GoBD](https://amtliche-handbuecher.bundesfinanzministerium.de/ao/2026/Anhaenge/BMF-Schreiben-und-gleichlautende-Laendererlasse/Anhang-33/inhalt.html) | 503                                           |
| [GNU GDB](https://www.gnu.org/software/gdb/)                                                                                                               | 0                                             |
| [GNU Bash](https://www.gnu.org/software/bash/)                                                                                                             | 0                                             |
| [DSGVO DE ELI](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de)                                  | 202                                           |
| [UrhG 69d](https://www.gesetze-im-internet.de/urhg/__69d.html)                                                                                             | 0                                             |
| [UrhG 69e](https://www.gesetze-im-internet.de/urhg/__69e.html)                                                                                             | 0                                             |
| [Veo](https://ai.google.dev/gemini-api/docs/veo)                                                                                                           | 0                                             |
| [AI Act](https://op.europa.eu/en/publication-detail/-/publication/dc8116a1-3fe6-11ef-865a-01aa75ed71a1/language-de)                                        | 202                                           |
| [OJ 2026/1744](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=OJ:L_202601744)                                                                         | 202; Zuordnung zu AI Omnibus nicht bestaetigt |
| [DSGVO ELI](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de)                                     | 202                                           |
| [DSM](https://op.europa.eu/en/publication-detail/-/publication/214471fe-786e-11e9-9f05-01aa75ed71a1/language-de)                                           | 202                                           |
| [NIS-2](https://op.europa.eu/en/publication-detail/-/publication/9b84d482-85bd-11ed-9887-01aa75ed71a1/language-de)                                         | 202                                           |
| [Gesetze im Internet](https://www.gesetze-im-internet.de/)                                                                                                 | 0                                             |
| [Korea](https://www.law.go.kr/)                                                                                                                            | 0                                             |
| [Singapur](https://www.pdpc.gov.sg/)                                                                                                                       | 202                                           |
| [Nigeria](https://ndpc.gov.ng/)                                                                                                                            | 403                                           |
| [VAE](https://uaelegislation.gov.ae/)                                                                                                                      | 403                                           |
| [Russland](https://pravo.gov.ru/)                                                                                                                          | 0                                             |
| [Russland Publikation](https://publication.pravo.gov.ru/)                                                                                                  | 0                                             |
| [Ukraine](https://zakon.rada.gov.ua/laws/main?lang=en)                                                                                                     | 0                                             |
| [Paperless API](https://github.com/paperless-ngx/paperless-ngx/blob/main/docs/api.md)                                                                      | 403; oeffentliche Doku, keine Auth-Ausnahme   |
| [Google Preise](https://ai.google.dev/gemini-api/docs/pricing)                                                                                             | 0                                             |
| [Google Billing](https://ai.google.dev/gemini-api/docs/billing)                                                                                            | 0                                             |
| [Google Einstieg](https://ai.google.dev/)                                                                                                                  | 0                                             |
| [DSGVO CELEX](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de)                                   | 202                                           |
| [AI Act CELEX](https://op.europa.eu/en/publication-detail/-/publication/dc8116a1-3fe6-11ef-865a-01aa75ed71a1/language-de)                                  | 202                                           |
| [Google API Key](https://ai.google.dev/gemini-api/docs/api-key)                                                                                            | 0                                             |
| [NSA/CISA Kubernetes 1.2](https://media.defense.gov/2022/Aug/29/2003066362/1/1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)                       | 403                                           |

## CI-Quellenabgleich (30.10.2026)

Die Alt-Adressen bleiben als Herkunftsbeleg erhalten. Die neuen Nachweise wurden anonym mit HTTP 200
abgerufen und anhand von Titel und CELEX bzw. offizieller Projektquelle zugeordnet.
EU-Metadatensaetze belegen die jeweilige Originalveroeffentlichung, nicht eine aktuelle
konsolidierte Rechtspruefung. Keine Anmeldung und keine Provider-Inferenz.

| Alt-Adresse (Abruf fehlgeschlagen)                                     | Erreichbarer Nachweis                                                                                                      |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=de`              | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de) |
| `https://eur-lex.europa.eu/eli/reg/2016/679/oj`                        | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de) |
| `https://eur-lex.europa.eu/legal-content/DE/TXT/?uri=CELEX:32016R0679` | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de) |
| `https://eur-lex.europa.eu/eli/reg/2024/1689/oj`                       | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/dc8116a1-3fe6-11ef-865a-01aa75ed71a1/language-de) |
| `https://eur-lex.europa.eu/legal-content/DE/TXT/?uri=CELEX:32024R1689` | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/dc8116a1-3fe6-11ef-865a-01aa75ed71a1/language-de) |
| `https://eur-lex.europa.eu/eli/dir/2019/790/oj`                        | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/214471fe-786e-11e9-9f05-01aa75ed71a1/language-de) |
| `https://eur-lex.europa.eu/eli/dir/2022/2555/oj`                       | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/9b84d482-85bd-11ed-9887-01aa75ed71a1/language-de) |
| `https://docs.paperless-ngx.com/api/`                                  | [Primaerquelle](https://github.com/paperless-ngx/paperless-ngx/blob/main/docs/api.md)                                      |
