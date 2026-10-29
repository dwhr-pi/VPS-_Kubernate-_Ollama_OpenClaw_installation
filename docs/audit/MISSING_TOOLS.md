# Werkzeuge nach echtem Mehrwert bewerten

Stand 29.10.2026. **Keine neue Anwendung installiert.** Bereits vorhandene
Registry-Eintraege sind kein Installations-/Integrationsnachweis.
Empfehlungen beziehen sich auf Funktionsluecken, nicht auf Beliebtheit.

| Kandidat / Quelle | Empfehlung | Mehrwert, Ueberschneidung und Aufwand |
|---|---|---|
| [Gitleaks](https://github.com/gitleaks/gitleaks) | ALREADY_PRESENT | Registry, Hook und CI vorhanden; Full-History-Scan und immutable Action-Refs zuerst abnehmen. CLI kurzzeitig, kein Daemon |
| [Trivy](https://github.com/aquasecurity/trivy) | ALREADY_PRESENT | Datei-/Image-/Konfigurationsscans vorhanden; Datenbankfrische und Ergebnisgates vereinheitlichen |
| [Syft](https://github.com/anchore/syft) / [Grype](https://github.com/anchore/grype) | ALREADY_PRESENT | SBOM-/Scanpfade nutzen; nicht noch ein paralleles CVE-System ohne zusaetzlichen Nutzen |
| [Semgrep](https://github.com/semgrep/semgrep) | ALREADY_PRESENT | SAST-Ergaenzung fuer Python/Shell-Glue; Ruleset/Telemetrie/Offline-Verhalten explizit festlegen |
| [Cosign](https://github.com/sigstore/cosign) | ALREADY_PRESENT | Signaturpruefung und SBOM-Attestation als fehlende Verbindung behandeln; Identitaet/Issuer pinnen, nicht nur signieren |
| [Renovate](https://github.com/renovatebot/renovate) | ALREADY_PRESENT | Ueberschneidung mit Dependabot; einen Update-Verantwortlichen bestimmen, kein Auto-Merge |
| [Falco](https://github.com/falcosecurity/falco) | OPTIONAL | Registry vorhanden; Kernel-/BPF-/Hostrechte und Ereignislast fuer VPS vorher messen |
| [Kyverno](https://github.com/kyverno/kyverno) | OPTIONAL | K8s-Admission gegen unsignierte/privilegierte Workloads; Controllerkosten und Bootstrap-Ausnahmen, erst Audit-Modus |
| [Checkov](https://github.com/bridgecrewio/checkov) | OPTIONAL | IaC-Policies koennen bestehende Trivy-/Manifest-Gates ueberlappen; erst belegte Regel-Luecke auswaehlen |
| [Ragas](https://github.com/explodinggradients/ragas) / [DeepEval](https://github.com/confident-ai/deepeval) | OPTIONAL | Zunaechst deterministischen Retrieval-/ACL-Benchmark verwenden; LLM-Judge kann API-/GPU-Kosten und Datenabfluss erzeugen |
| [Temporal](https://github.com/temporalio/temporal) / [LangGraph](https://github.com/langchain-ai/langgraph) | OPTIONAL | Keine zweite Orchestrierungsschicht ohne fehlenden Retry-/State-/Approval-Vertrag der vorhandenen Workflows |
| Weitere Inferenz-Runtime | REJECT als Standarderweiterung | llama.cpp/vLLM/SGLang/TensorRT-LLM erst mit gleichem Modell, Qualitaet, Hardwarebudget und nachvollziehbarer Latenzverbesserung vergleichen |

## Lizenz und Wartung

Am Prueftag direkt eingesehene Original-Lizenztexte:
[Gitleaks: MIT](https://raw.githubusercontent.com/gitleaks/gitleaks/master/LICENSE),
[Trivy: Apache-2.0](https://raw.githubusercontent.com/aquasecurity/trivy/main/LICENSE),
[Cosign: Apache-2.0](https://raw.githubusercontent.com/sigstore/cosign/main/LICENSE),
[Kyverno: Apache-2.0](https://raw.githubusercontent.com/kyverno/kyverno/main/LICENSE).
Dies sind aktuelle Branchtexte, **keine Zertifizierung aller im Setup gepinnten
Commits, Action-Wrapper, Abhaengigkeiten oder Cloud-Angebote**. Andere Tabellenlinks
sind Quellenzeiger und keine abgeschlossene aktuelle Lizenz-/Wartungspruefung.

Bei 399 Tool-Records fehlen nach Registry-Auswertung 239 Lizenzfelder; weitere
77 enthalten Pruef-/Platzhalterangaben. Fehlende Metadaten werden im Inventar
ausdruecklich unbekannt gelassen, nicht aus dem Projekt-Root-LICENSE abgeleitet.
Ein erreichbares Repository beweist weder aktiven Support noch sichere Releases.
Vor Integration: Lizenz **am Pin**, letzte Sicherheitsreaktion, Archivierung,
Abhaengigkeiten, Signatur und reproduzierbaren Build pruefen und datieren.

## Entscheidungsvertrag

INTEGRATE erst nach dokumentierter Funktionsluecke, Plattform-/Ressourcenbudget,
Owner, Install-/Update-/Uninstall-/Healthvertrag und Regressionen. EXPERIMENTAL
bleibt fuer nicht abgenommene Studien-/Buildpfade sinnvoll. REPLACE_EXISTING
erfordert Datenmigration und Rollback; ALREADY_PRESENT verhindert Doppelinstaller.
Eine Punktzahl allein erlaubt weder Download noch Installation oder Veroeffentlichung.
