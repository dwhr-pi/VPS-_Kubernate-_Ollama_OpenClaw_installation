# Wartungsreview: Releases, Quellen und Kubernetes

## Umgesetzt

- [Nationaler Rechtsquellenkatalog](legal/NATIONAL_DATABASES.md): 195 Staaten,
  nach Setup-Prioritaet, Kontinent und A-Z. Fehlende nationale Einstiege und
  Abrufgrenzen bleiben sichtbar. Keine Rechtsfreigabe und kein automatischer Abruf.
- [Quickstart](../readme.md#installation-und-betrieb) trennt Signaturpruefung,
  Installation und Update. Destruktive Altablaeufe sind nur im
  [Archiv](legacy/INSTALLATION_HISTORY.md) dokumentiert.
- [Signierte Releases](SIGNED_RELEASES.md): Freigabe, Gegenpruefung und
  unabhaengige Schluesselverteilung beschrieben. GitHub lieferte bei der
  Bestandsaufnahme keine veroeffentlichten Releases. Hier wurde weder ein
  echter Schluessel gelesen noch ein Tag, Release oder eine Signatur erzeugt.
- Dependabot ueberwacht Actions und das vorhandene Websitefactory-npm-Manifest.
  Bei der Bestandsaufnahme waren die externen Workflow-Actions mit vollen SHAs
  referenziert. Der vorhandene blockierende Trivy-Konfigurations-, Secret- und
  Image-Freigabepfad bleibt unveraendert.

## CIS-Audit ohne Cluster-Deployment

Der [Audit-Wrapper](../scripts/security/kube-bench-audit.sh) zeigt ohne
Argumente nur den Plan. Fuer einen echten Scan auf dem autorisierten
Linux-Knoten sind ein aus geprueften [Git-Quellen](https://github.com/aquasecurity/kube-bench)
gebautes Binary, passende Konfigurationsdateien aus demselben Pin und die
explizite Benchmark-/Rollenwahl erforderlich. Nur erforderliche Leserechte
freigeben; der Wrapper installiert nichts, verwendet kein sudo und startet
keinen Dienst. JSON-Berichte intern halten. Tool-Exitcode allein ist kein
CIS-Pass; FAIL-, WARN- und manuelle Befunde auswerten. Bei externem Datastore
die etcd-Pruefungen und ihre Anwendbarkeit gesondert beurteilen.

## Offene Arbeiten nach Prioritaet

1. **P1: Release-Abnahme.** Freigegebenen Tag, autorisierten Offline-Signierer
   und unabhaengigen Public-Key-Kanal bereitstellen. Danach echte Signatur,
   GitHub-Download und Install/Update in einer Wegwerf-VM pruefen. Cosign
   erst nach Festlegung und Abnahme der OIDC-Identitaet.
2. **P1: Staging-Nachweise.** Argo CD ist im vorhandenen
   [Hybrid-Beispiel](../examples/hybrid-production-review/README.md) bereits
   skizziert und bleibt der erste Kandidat; keinen zweiten Controller
   parallel installieren. Kyverno-Regeln fuer privileged, Tags und Limits
   zunaechst im Audit-Modus gegen gerenderte Workloads pruefen. Velero erst
   nach einem separaten PVC-/Datenbank-Restore als Betriebsprofil freigeben.
   Traefik und cert-manager/DNS-01 weiterverwenden; external-dns erst mit
   begrenzter Zone, TXT-Owner-ID und ohne Loeschrechte abnehmen.
3. **P2: Pfade konsolidieren.** `k8s/` besitzt die Basismanifeste,
   `deploy/kustomize/` ist ein kompatibler Einstieg und enthaelt eigene
   optionale Overlays. Erst Referenzen und rendergleiche Migration pruefen.
   `config`/`configs` und die Persona-/Profilpfade bleiben bis zur
   Verbraucherpruefung bestehen. Keine Windows-inkompatiblen Symlinks.
4. **P2: Supply Chain vertiefen.** Kein eigenstaendiges gepinntes pip-Manifest
   und keine externen Helm-Chart-Dependencies im geprueften Manifestbestand.
   Chart-Archive werden ueber separate Pins verwaltet; diese nicht von
   Dependabot als automatisch abgedeckt ausgeben. Einen zusaetzlichen
   nicht-blockierenden Report erst parallel zu den bestehenden harten Gates
   einfuehren; kein bestehendes Gate absenken.
5. **P3: Testmatrix vervollstaendigen.** Der Bestand enthielt 33 Shell-Dateien,
   2 Bats-, 3 Node- und 198 Python-Testdateien. ShellCheck und Bats sind
   bereits in CI; die Python-Suite nutzt unittest. Kein globaler Wechsel
   auf pytest ohne Bestandsabnahme. Windows-Fixtures sind kein WSL-Lauf;
   echte WSL- und Ubuntu-VM-Abnahme gesondert nachweisen.
