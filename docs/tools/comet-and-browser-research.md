# Comet, offene Browser und Perplexity fuer dieses Setup

Stand: 25.10.2026. Die beiden Nutzeranhaenge wurden als Recherchematerial
gelesen; enthaltene Installationsbefehle wurden nicht ausgefuehrt. Keine Cookies,
Browserprofile, Konten oder externen Recherche-APIs wurden verbunden.

## Comet ist ein Client, keine lokale Inferenz-Runtime

Die [offizielle Comet-Seite](https://www.perplexity.ai/comet) bietet Downloads
fuer Desktop/Mobilgeraete. Ein offizieller vollstaendiger Comet-Quellcode-/Build-
Vertrag wurde in den geprueften Quellen nicht nachgewiesen. Daher **kein
GitHub-Source-Installer fuer Comet** und keine Gleichsetzung mit dem offenen
Chromium-Unterbau. Fuer Comet bleibt es beim offiziellen Downloadlink.
Konto-/Tarif-/Plattformbedingungen vor Installation dort pruefen.

## Verifizierte Quellreferenzen, noch keine neuen Installer

| Projekt / GitHub | Rolle | Einordnung fuer den Hybridstack |
|---|---|---|
| [BrowserOS](https://github.com/browseros-ai/BrowserOS) | Offener agentischer Browser, als Comet-Alternative positioniert | Kandidat fuer den lokalen Desktop; kein K3s-Kernbaustein |
| [Browser Use](https://github.com/browser-use/browser-use) | Offene Browser-Agent-Bibliothek plus getrennte Cloudangebote | Kandidat fuer isolierten Browser-Worker; kein vollstaendiger Comet-Desktop-Ersatz |
| [Enki Browser](https://github.com/danilogiles/enki-browser) | Chromium-Browser mit eigenem Assistenten / Bring-your-own-model | Experimenteller Desktop-Kandidat, Build-/Updatevertrag separat pruefen |
| [Perplexity MCP](https://github.com/perplexityai/modelcontextprotocol) | Offizieller MCP-Server fuer die API-Plattform | Externes Recherchetool mit separatem API-Key, kein lokales Perplexity-Modell |
| [perplexity-py](https://github.com/perplexityai/perplexity-py) | Offizieller Python-SDK | API-Client fuer eigene Dienste; keine Cloudkostenfreiheit ableiten |
| [perplexity-node](https://github.com/perplexityai/perplexity-node) | Offizieller Node-SDK | Gleiches API-/Datenschutzprinzip fuer JavaScript/TypeScript |
| [api-cookbook](https://github.com/perplexityai/api-cookbook) | Offizielle Beispiele | Referenz, kein dauerhaft zu startender Dienst |

Diese Tabelle fuehrt Quellen/Kandidaten auf, **nicht sieben installierte oder
bereits im Tools-Menue installierbare Anwendungen**. Die PDF-Aussagen zu
Browser Operator und OpenBrowser sind ohne eindeutige Quell-/Lizenzidentitaet
nicht als Installer umgesetzt. Auch SPACE/pplx-Kernels aus dem Text sind kein
belegter Ersatz fuer ein Browserprodukt oder eine fertige sichere Sandbox.
Lizenzdatei, Commit, Plattform, Buildbedarf und funktionale Abnahme sind pro
Kandidat vor einer Installerfreigabe zu dokumentieren; ein Repositorylink allein
ist kein Sicherheits- oder Funktionsnachweis.

## Sichere Einbindung

```text
Desktop-Browser / erlaubter Browser-Worker
           -> freigegebene Agententools / menschliche Bestaetigung
           -> lokales Gateway -> Ollama
           -> optional Perplexity MCP -> externe API (separat freigegeben)
```

Browser-Worker in eigenem Namespace oder separatem Hostprofil, Non-Root,
eigenem leeren Browserprofil und begrenztem CPU/RAM/Disk-Budget betreiben.
Keine bestehenden privaten Tabs, Cookies oder SSO-Sessions automatisch
uebernehmen. CDP/Debugging-Ports und MCP-HTTP nicht unauthentifiziert ins WAN.
Kein Kubernetes-ServiceAccount-Token und kein Docker-Socket fuer Webrecherche.

Webseiten/Transkripte sind untrusted Input: keine darin enthaltenen Shell-/MCP-
Anweisungen als Nutzerfreigabe behandeln. Downloads, Formulare, Nachrichten,
Kaeufe und Logins brauchen explizite Policies/Freigaben. SSRF-/Metadatenzugriff
und private Netze auch bei frei erlaubter Websuche sperren. NetworkPolicy allein
validiert keine URL/Redirects; dafuer kontrollierten Egress-Proxy einsetzen.

API-Key ausserhalb Git als eng berechtigtes Secret speichern, nur an den
zugehoerigen Toolprozess geben. Eine Browser-Pro-Mitgliedschaft ist kein Beleg
fuer enthaltene API-Credits. Keine Personalakten oder internen Dokumente an
Cloudrecherche senden. Im [Audit](../security/SECURITY_ARCHITECTURE_AUDIT_2026-10-25.md)
ist dieser Worker deshalb eine eigene Vertrauensgrenze.
