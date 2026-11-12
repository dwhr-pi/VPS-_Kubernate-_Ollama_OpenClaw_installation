# Alle Tools im Blick: Browser, Windows-Desktop und Kubernetes

**Ja: Eine zentrale Uebersicht ist moeglich, auch fuer Kubernetes/K3s.**
Empfohlene Kombination: **Headlamp fuer Cluster-Workloads**, **Grafana fuer Messwerte** und optional eine
**Startseite fuer Tool-Links**. [Boardroom](tools/boardroom.md) steht daneben fuer Entscheidungen und Reviews.
Das Setup liefert bisher kein fertig eingerichtetes gemeinsames Dashboard fuer alle installierten Tools.

Stand: 2026-11-12. Dies ist eine ausdrueckliche Einstiegsempfehlung, keine bereits ausgefuehrte Installation.
Keine Anwendung, Browseransicht, Verbindung zum Cluster oder Installation wird durch Lesen dieser Seite gestartet.

**Apps wie Qwen/Gemini mit Icons starten und CPU/RAM/GPU in einem weiteren Reiter sehen:**
Der [Launcher-/Installer- und Metrikvertrag](DESKTOP_LAUNCHER_AND_METRICS_CONTRACT.md) beschreibt den Ausbau.
Eine lokale App braucht einen separat freigegebenen nativen Starter; eine Webseite darf keine beliebigen EXEs starten.

[Auch macOS, Linux, Android und iPhone beruecksichtigen](CROSS_PLATFORM_APP_DISCOVERY.md):
begrenzter Desktop-Inventarscan jetzt vorhanden; mobile App-Erkennung und App-Starts bleiben separat zu entwickeln.

## Welcher Weg passt zu mir?

| Wunsch | Passender Baustein | Stand im Setup und Grenze |
| --- | --- | --- |
| Kubernetes im Browser ansehen | Headlamp Web | Empfohlene Ergaenzung; Source-/Deployment-Rezept und Abnahme noch offen |
| Kubernetes als Windows-EXE ansehen | Headlamp Desktop | Upstream bietet Windows-App; im Setup noch nicht integriert oder installiert |
| CPU, RAM, GPU, Alarme und Tool-Metrikziele sehen | Grafana | Vorhanden; [All-Tools-Dashboard](monitoring/ALL_TOOLS_OBSERVABILITY.md) vorbereitet, Aktivierung/Import separat |
| Eine Startseite mit allen erreichbaren Oberflaechen | Homepage oder eigene statische Linkseite | Optional; Homepage hat Upstream-Quellinstallation, Setup-Integration noch offen |
| Kubernetes ohne Browser per SSH ansehen | K9s | Bereits im Tool-Katalog; Installation und Clusterrechte separat pruefen |
| Optionen, Kosten und Stoerungen bewerten | Boardroom | Entscheidungsprofil, keine Cluster-Oberflaeche und kein autonomer Administrator |

Fuer den Anfang reichen **Headlamp Desktop plus Grafana**. Eine weitere zentrale Web-Startseite ist optional.
Headlamp Desktop braucht keinen zusaetzlichen Headlamp-Pod im Cluster, aber einen freigegebenen API-Zugang.
Es ersetzt weder die Tool-Programme noch ihre eigenen Oberflaechen und erkennt keine nativen CLI-Installationen.

## Was bedeutet alle installierten Tools?

Vier verschiedene Aussagen muessen im Dashboard getrennt bleiben:

| Anzeige | Benoetigter Nachweis | Was daraus nicht folgt |
| --- | --- | --- |
| Im Setup-Katalog | Registry-Eintrag | Weder installiert noch gestartet |
| Nativ installiert | Versions-/Artefaktnachweis aus dem jeweiligen Installer/Doctor | Ein Marker oder Source-Clone allein reicht nicht; kein Laufzeitnachweis |
| In Kubernetes ausgerollt | Deployment, StatefulSet, DaemonSet, Job oder andere freigegebene Ressource | Ein angelegtes Objekt kann Pending, defekt oder auf null Replikate skaliert sein |
| Betriebsbereit | Readiness plus geeigneter, bewusst freigegebener Funktionstest | Ein erfolgreicher HTTP-Scrape belegt keine erfolgreiche Agentenaktion |

Das aktuelle Grafana-Paket umfasst alle **422 Haupt-Registry-IDs**, aber meldet sie nicht pauschal als installiert.
Headlamp zeigt die zugaenglichen Kubernetes-Ressourcen; ein Tool kann aus mehreren Workloads bestehen.
Auch Helm-Releases und Operator-CRs sind nicht automatisch eine eindeutige Tool-Installation.
Zum Zuordnen eine stabile Registry-ID verwenden, z. B. das bereits vorgesehene Pod-Label `openclaw_tool`.
Freie Namespace-/Pod-Namen nicht ungeprueft als Tool-Nachweis interpretieren.

Fuer eine wirklich gemeinsame Inventaransicht fehlt noch ein freigegebener **read-only Inventaradapter**:
Registry + begrenzte native Installationsnachweise + erlaubte Clusterobjekte + Messwerte.
Er muss Standort/Cluster/Namespace, Zeitstempel, Quelle und Status `unbekannt` getrennt ausgeben.
Veraltete oder nicht erreichbare Daten duerfen nicht als aktuell oder gesund erscheinen.
Keine rekursive Suche in privaten Home-Verzeichnissen und keine automatische Ausfuehrung aller Doctor-Skripte.
Einige Checks koennen Netzwerk oder Laufzeitaktionen benoetigen; vor einer Sammelabfrage einzeln pruefen.

## Headlamp als Browseransicht oder Windows-App

Upstream unterstuetzt Web und Desktop fuer Windows, Linux und macOS.
Die Desktop-App liest eine bewusst ausgewaehlte kubeconfig und arbeitet mit deren Kubernetes-Rechten.
Ein read-only Zugang ist daher wichtiger als die Frage, ob die Oberflaeche im Browser oder als EXE laeuft.

Die offizielle Desktop-Dokumentation weist derzeit auf **nicht signierte Windows-Builds** hin.
Den Signatur-/Veroeffentlichungsstatus fuer die konkrete Version erneut pruefen.
Nicht pauschal SmartScreen, Virenschutz oder Signaturpruefungen abschalten.
Quell-Pin, Herkunft, Build und Integritaet pruefen; ein Hash vom gleichen ungesicherten Download allein schafft
noch keinen unabhaengigen Vertrauensanker. Ist die Herkunft nicht belastbar pruefbar, Installation vertagen.

Die Upstream-EXE ist hier ein Hinweis auf eine vorhandene Darstellungsmoeglichkeit, **keine neue Binary-Ausnahme**.
Fuer eine Setup-Integration gilt weiterhin: gepinnte Git-Quellen, nativer Build, Lockfiles und Build-Nachweise;
kein Docker-/Compose-Installationsweg oder -Fallback. Ein entsprechendes Headlamp-Rezept ist noch offen.

Im Browser kann entweder eine bewusst eingerichtete private Web-Instanz oder ein gepruefter lokaler Modus dienen.
Fuer eine Cluster-Web-Instanz sind eigene Authentifizierung/TLS, RBAC und NetworkPolicies erforderlich.
Nicht allein deshalb einen zweiten Ingress-Controller oder eine weitere komplette Monitoring-Plattform installieren.

## Sichere Rechte und Verbindung

- Zugriff nur lokal oder ueber den freigegebenen VPN-/TLS-Pfad; keine neue oeffentliche Kubernetes-API-Freigabe.
- Eigenen read-only Benutzer/Context verwenden, nicht die K3s-Admin-kubeconfig kopieren.
- Nur benoetigte Namespaces und `get`, `list`, `watch` fuer ausgewaehlte Workload-/Service-Ressourcen erlauben.
- Kein `cluster-admin`, keine Secret-Leserechte, kein `exec`, `attach` oder Port-Forwarding fuer die Uebersicht.
- Logs und Events separat freigeben: auch sie koennen sensible Daten enthalten.
- Keine kubeconfig, Tokens oder Zertifikate in Git, Browser-URLs, Desktop-Verknuepfungen oder Boardroom-Prompts ablegen.
- Unbekannte kubeconfig-Dateien koennen ausfuehrbare Credential-Plugins enthalten; nur gepruefte Konfigurationen nutzen.
- Headlamp-/Grafana-Plugins sind zusaetzlicher Code mit Datenzugriff; nur geprueft und versionsgebunden zulassen.

Die [Kubernetes-kubeconfig-Dokumentation][kubeconfig] beschreibt die Vertrauensgrenzen dieser Verbindungsdateien.

[kubeconfig]: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/

Headlamp folgt den API-Berechtigungen. Nicht erlaubte Ansichten koennen deshalb leer bleiben oder Zugriff verweigern.
Das ist kein Anlass, pauschal Admin-Rechte zu vergeben. Auch kube-state-metrics und Metrics-Server bleiben
getrennte Datenquellen; eine funktionierende Ressourcenliste beweist keine vorhandenen CPU-/GPU-Metriken.

## Eine gemeinsame Startseite, gern mit Boardroom

Als lesbare Startseite bietet sich folgende Aufteilung an; sie ist ein Zielbild, keine fertige Live-Oberflaeche:

```text
Mein OpenClaw-Cockpit
  Kubernetes     -> Headlamp: Workloads, Pods, Services, PVCs
  Monitoring     -> Grafana: Tool-Ziele, RAM, GPU, Alarme
  Anwendungen    -> freigegebene Web-UIs von Open WebUI, n8n, Qdrant usw.
  Native Tools   -> Inventar mit Versionsnachweis und Zeitpunkt, keine erfundenen Web-Links
  Boardroom      -> Profil im vorhandenen Agenten-Client und redigierte Entscheidungsberichte
  Dokumentation  -> dieses Handbuch und der Haertungsplan
```

Homepage kann als optionale Link-/Statusoberflaeche evaluiert werden; eine Quellinstallation ist upstream beschrieben.
Ein Link auf eine Anwendung belegt nicht deren Installation oder Funktionsfaehigkeit.
Fuer die erste Stufe genuegt eine statische Linkseite ohne Kubernetes-Zugang oder ein Browser-Lesezeichenordner.
Statuswidgets und Kubernetes-Discovery erst spaeter mit minimalen Rechten anschliessen.
Authentifizierung, HTTPS und Datenfreigaben sind separat abzunehmen, nicht aus einer Startseite abzuleiten.

Im Browser kann eine Verknuepfung auf eine bereits gesicherte Oberflaeche auf den Windows-Desktop gelegt werden.
Das ist ein schneller Einstieg in eine Web-App, **keine eigenstaendige EXE und keine Offline-Kopie der Daten**.
Keine Tokens an die URL anhaengen. Boardroom hat keinen pauschal vorhandenen HTTP-Endpunkt; keinen erfinden.

Boardroom kann zum Beispiel diese Entscheidung vorbereiten:

> Boardroom rufen: Plane eine read-only Uebersicht meiner nativen und Kubernetes-Tools.
> Vergleiche Headlamp Desktop plus Grafana mit einer gemeinsamen Web-Startseite.
> Keine Installation oder Clusterabfrage ausfuehren; benoetigte Rechte, Aufwand und offene Nachweise nennen.

Boardroom liest dadurch nicht automatisch den Cluster aus und startet keine Programme.
Nur redigierte Statusberichte uebergeben; keine privaten Verbindungsdaten oder Benutzerinhalte.

## Schritt fuer Schritt abarbeiten

- [ ] Entscheiden: Desktop zuerst oder private Web-Instanz; vorhandenes Grafana nicht nochmals installieren.
- [ ] Fuer Headlamp Source-Pin, Build-/Signaturvertrag und Plattformvoraussetzungen pruefen; Setup-Rezept erstellen.
- [ ] Einen zeitlich/raeumlich begrenzten read-only Cluster-Context ausserhalb des Repos einrichten und testen.
- [ ] Ansichten fuer erlaubte Workloads und verweigerte Secrets/exec in einer Testumgebung abnehmen.
- [ ] Vorhandenes [Grafana-JSON](../monitoring/grafana/dashboards/all-tools.json) nach bewusster Freigabe importieren.
- [ ] Tool-Zuordnung und Aktualitaet anhand weniger bekannter Installationen pruefen; fehlende Daten sichtbar lassen.
- [ ] Native Inventardaten erst mit einem begrenzten, geprueften read-only Adapter aufnehmen.
- [ ] Erst danach Startseite/Verknuepfungen und einen optionalen Boardroom-Einstieg ergaenzen.

Die Sicherheits-/Betriebsschritte E01-E09 stehen im
[Enterprise-Arbeitsplan](architecture/ENTERPRISE_HARDENING_ROADMAP.md).
Diese Seite fuehrt keine dieser Aufgaben aus. Build-, RBAC-, Import- und Runtime-Abnahmen bleiben offen.

## Quellen und weiterfuehrende Seiten

- [Headlamp: Web und Desktop](https://headlamp.dev/)
- [Headlamp: Desktop und Windows-Signaturhinweis](https://headlamp.dev/docs/latest/installation/desktop/)
- [Headlamp: Windows-EXE](https://headlamp.dev/docs/latest/installation/desktop/win-installation/)
- [Headlamp: Release-Verifikation](https://headlamp.dev/docs/latest/installation/verify-releases/)
- [Homepage: Quellinstallation](https://gethomepage.dev/installation/source/)
- [Homepage: Kubernetes-Anbindung](https://gethomepage.dev/configs/kubernetes/)
- [Setup: Tool-Monitoring und Grenzen](monitoring/ALL_TOOLS_OBSERVABILITY.md)
- [Setup: Boardroom-Profil](tools/boardroom.md)
- [Setup: K9s](K9S_INSTALLATION_NOTES.md)

Upstream-Installationsbeispiele sind keine Freigabe ihrer Admin-/Docker-/beweglichen main-Vorgaben fuer dieses Setup.
