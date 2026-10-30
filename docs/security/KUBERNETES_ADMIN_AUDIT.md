# Kubernetes: Admin-Pruefblatt und sichere Einfuehrung

Stand 25.10.2026. Gehoert zum [Repo-Audit](SECURITY_ARCHITECTURE_AUDIT_2026-10-25.md). Keine
Konformitaetsbescheinigung. Vorlage fuer eine konkrete Clusterabnahme; Status standardmaessig
**offen**, nicht aus Repository-Dateien als bestanden ableiten.

## Die wichtigsten Sicherheitsgrenzen

API/SSH privat halten, Benutzerrechte minimieren, Agenten von Host und Secrets trennen, Netzwerkwege
explizit erlauben und Wiederherstellung nachweisen. Container-Haertung allein verhindert weder
Prompt-Injection noch missbrauchte legitime Toolrechte. Externe Nachrichten, Zahlungen, Logins und
Datenloeschung brauchen eigene Freigaben und Auditspuren ohne Prompt-/Secret-Inhalte.

## NSA / CISA als Admin-Auditbogen

Ergaenzender erreichbarer Beleg: das
[CISA-Bulletin vom 15.03.2022](https://content.govdelivery.com/accounts/USDHSCISA/bulletins/30ef592)
bestaetigt die gemeinsame Guidance als historischen Kontext. Es belegt nicht den Volltext der
Version 1.2 vom August 2022. Deren gesperrte Originaladresse bleibt unten unverifiziert erhalten.

Orientierung:
`https://media.defense.gov/2022/Aug/29/2003066362/1/1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF`
(Kubernetes Hardening Guidance, Version 1.2, August 2022; unverifizierte Originalreferenz, CI HTTP
403, 30.10.2026). Keine Behauptung, dies sei eine neue 2026-Ausgabe. Die Themenzuordnung unten ist
eine projektspezifische Zusammenfassung, keine wortgetreue Kontrollnummerierung. Veraltete
PodSecurityPolicy durch aktuelle Pod Security Admission ersetzen.

| Thema der Guidance           | Projektpruefung                 | Sollnachweis                         | Status | Verantwortlich / Datum / Evidenz |
| ---------------------------- | ------------------------------- | ------------------------------------ | ------ | -------------------------------- |
| Nichtprivilegierte Container | UID, Capabilities, Seccomp      | Restricted-Admission und Negativtest | offen  | ausfuellen                       |
| Netztrennung                 | Default-Deny / erlaubte Pfade   | Positiv- und Negativtest             | offen  | ausfuellen                       |
| Authentifizierung            | Private API, TLS, Gateway-Auth  | Fremdclient abgewiesen               | offen  | ausfuellen                       |
| Rechte                       | Namespace-RBAC, keine Wildcards | can-i Soll/Ist                       | offen  | ausfuellen                       |
| Credentials                  | Verschluesselung, Rotation      | SOPS, Datastore, Recovery            | offen  | ausfuellen                       |
| Images                       | Gepinnte Herkunft               | Digest, Scan, SBOM                   | offen  | ausfuellen                       |
| Nodes                        | Updates, SSH, Laufzeit          | Hostprofil und Wartungsbeleg         | offen  | ausfuellen                       |
| Auditierung                  | Geschuetzte Ereignisse          | Zugriff/Retention/Alarm getestet     | offen  | ausfuellen                       |
| Wiederherstellung            | State und Cluster sichern       | Isolierter Restore                   | offen  | ausfuellen                       |
| Wartung                      | Sicherheitsupdates              | Gepruefter Rollout und Rueckweg      | offen  | ausfuellen                       |

Pro Zeile Nachweislink, verantwortliche Person, Frist und Restabweichung eintragen. Zusaetzlich
Node-/Cluster-Version, CNI, StorageClass, Image-Digests, Scope und Testdatum festhalten. Keine
Tokens oder kubeconfig-Inhalte anhaengen.

## Pod Security Standards vergleichen

| Level      | Bedeutung                                                                                                  | Einsatz in diesem Projekt                                                           |
| ---------- | ---------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Privileged | Keine PSS-Einschraenkung; ist nicht automatisch `privileged: true`                                         | Nur begruendete System-/Geraetetreiber-Ausnahmen, eigener administrierter Namespace |
| Baseline   | Blockiert bekannte gefaehrliche Pod-Einstellungen, z.B. privilegierte Container / Host-Namespace-Freigaben | Migrationszwischenstufe, keine vollstaendige Haertung                               |
| Restricted | Strengere Regeln, u.a. Non-Root, Seccomp, Drop ALL und keine Privilegieneskalation fuer Linux              | Ziel fuer Ollama/LiteLLM/Agenten, sofern Images/Volumes kompatibel                  |

`readOnlyRootFilesystem` ist zusaetzliche Haertung, nicht mit allen Restricted- Anforderungen
gleichzusetzen. PSS regelt weder NetworkPolicy noch RBAC/Secrets. Quelle:
[Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

Vorgehen: Namespace im Staging inventarisieren, Restricted erst in `warn` und `audit` beobachten,
Images/Volumes korrigieren, Negativtests, dann `enforce`. Versionslabels am **tatsaechlich
getesteten** Clusterstand pinnen; nicht unbesehen `latest` oder das Beispiel unten einsetzen. Die
bestehende neue Repo-Basis erzwingt bereits Restricted; nicht fuer Browser/Monitoring pauschal
herunterstufen. Aenderungen betreffen neue Podzulassung, nicht die nachtraegliche Haertung laufender
Pods.
[Einfuehrung](https://kubernetes.io/docs/setup/best-practices/enforcing-pod-security-standards/).

```yaml
# Example only: replace v1.34 with the cluster version tested in staging.
apiVersion: v1
kind: Namespace
metadata:
  name: llmops-staging
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/enforce-version: v1.34
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: v1.34
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: v1.34
```

## NetworkPolicies einrichten

1. CNI-/Policy-Durchsetzung und DNS-Labels nachweisen; eine YAML-Datei allein filtert nichts.
2. Bestehende Verbindungen und Labelverwaltung inventarisieren; Default-Deny zuerst im Staging.
3. DNS und konkrete Client/Server-Fluesse in beiden Richtungen freigeben.
4. Erlaubten Client, fremden Namespace, falsches Podlabel und unerlaubten Port pruefen.

Die [Beispieldatei](examples/network-policy.yaml) zeigt Default-Deny/DNS und einen eng begrenzten
Gatewaypfad fuer `llmops`. Sie ist **nicht** automatisch in der Runtime-Kustomization. Die
bestehende Basis hat eigene Policies: Regeln sind additiv; weitere Allow-Regeln koennen die
Beispielgrenze erweitern. Namespace- und Podselector im **selben** `from`-Element bedeuten UND;
getrennte Elemente bedeuten ODER. Antworten auf erlaubte Verbindungen brauchen keine umgekehrte
eigene Verbindungsfreigabe. Egress im Clientnamespace bleibt separat erforderlich.
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).

Clusterlabels zuerst nur lesen:

```bash
kubectl --context REVIEWED_CONTEXT get namespaces --show-labels
kubectl --context REVIEWED_CONTEXT get pods -n kube-system --show-labels
kubectl --context REVIEWED_CONTEXT get networkpolicies -n llmops
# Server validation contacts the cluster/admission; it is not an offline test.
kubectl --context REVIEWED_CONTEXT apply --dry-run=server -f docs/security/examples/network-policy.yaml
```

Kein Netzwerk-Testpod automatisch gestartet. Einen freigegebenen Testclient spaeter mit gepinntem
Image und kurzen Timeouts verwenden; keine echten API-Keys in `curl`-Argumenten/Logs. DNS- und
private Proxywege explizit pruefen.

## RBAC korrekt konfigurieren

[observer-rbac.yaml](examples/observer-rbac.yaml) bindet eine externe Gruppe an eine Namespace-Role
mit rein lesendem Pod-/Deployment-/StatefulSet-Status. Keine Secrets, Logs, Exec, TokenRequests oder
Schreibrechte. Gruppenmitgliedschaft kommt aus dem geprueften Identity-Provider; eine RoleBinding
erstellt keine Benutzer und fuehrt keine Anmeldung ein.
[RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).

Agenten brauchen normalerweise **keinen** Kubernetes-API-Zugriff. Ohne API-Aufgabe kein RoleBinding,
`automountServiceAccountToken: false`. Bei einer begruendeten API-Aufgabe eigene ServiceAccounts,
engste Ressourcen/Verben und kurzlebige projizierte Tokens; niemals pauschal `cluster-admin`,
Wildcards, `system:masters`, `bind`, `escalate`, `impersonate` oder `nodes/proxy` verteilen.
Workload-Erstellung kann indirekt Zugriff auf Namespace-Secrets/ServiceAccounts geben.
[RBAC Good Practices](https://kubernetes.io/docs/concepts/security/rbac-good-practices/).

```bash
# The auditing identity needs impersonation permission for these checks.
kubectl --context REVIEWED_CONTEXT auth can-i get pods -n llmops --as=fixture-observer --as-group=llmops-observers
kubectl --context REVIEWED_CONTEXT auth can-i get secrets -n llmops --as=fixture-observer --as-group=llmops-observers
kubectl --context REVIEWED_CONTEXT auth can-i create pods/exec -n llmops --as=fixture-observer --as-group=llmops-observers
```

Soll: erster Test ja, folgende nein. Ein Impersonation-Fehler ist kein negativer
Berechtigungsnachweis. Bestehende weitere Bindings koennen mehr Rechte geben; die Role in diesem
Beispiel allein beweist das Gesamtergebnis nicht.

## Abschlussabnahme

Auth-/Netz-Negativtest, Pending/OOM/Kaltstart, PVC nach Pod-/Nodeverlust, Alarmzustellung und
Restore. [Ressourcenplaner](../resource-planner/index.html) unterstuetzt die Kapazitaetsplanung,
nicht die Compliance-Bewertung. Cluster-Auditlogs koennen Requestdaten enthalten: Zugriff, Retention
und Redaktion planen; keine unbegrenzten Prompts/Secrets zentral sammeln.
