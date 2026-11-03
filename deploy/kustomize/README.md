# Deklarative Einstiegspunkte

Die Workload-Quelle bleibt `k8s/`; hier liegen kompatible Kustomize-Einstiege, keine Kopien der Pods/PVCs.
Alte Pfade bleiben gueltig. Pro Umgebung genau einen Workload-Einstieg verwenden.

| Einstieg | Zweck | Automatisch aktiv? |
|---|---|---|
| `base/` | Namespace, PSS, Budgets, Ollama/PVC, LiteLLM und Default-Deny | Nein |
| `overlays/vps-cpu/` | Bestehendes kleines CPU-Budget | Nein |
| `overlays/gpu/` | Bestehende GPU-/Workspace-Variante | Nein |
| `overlays/production/` | Kompatibilitaet zum bisherigen Produktions-Template | Nein |
| `overlays/vps-cpu-local-storage/` | Explizites `local-path`, nur fuer Neuinstallation | Nein |
| `overlays/private-ingress/` | Privates TLS-Gateway mit DNS01-Verweis | Nein |
| `monitoring-operator/` | ServiceMonitor/PrometheusRule und deaktivierter Inventar-Exporter | Nein |
| `platform-dns01/` | Separater administrativer ClusterIssuer, Staging-CA | Nein |
| `optional/direct-openclaw-ollama/` | Enger direkter API-Bypass, nicht empfohlen als Standard | Nein |

Helm-Values, Patches, SealedSecret-Beispiele und historische Dateien sind keine eigenstaendigen
Workloads. Sie werden nicht wahllos in ein Sammel-Apply aufgenommen. Die bestehenden ArgoCD-
Applications bleiben gueltig; fuer neue Applications kann `source.path` auf einen der Workload-
Einstiege zeigen. Vollstaendiger Commit-Pin, bestehendes AppProject und manuelle Synchronisation bleiben Pflicht.

```bash
bash scripts/setup-cluster.sh
bash scripts/setup-cluster.sh --render vps-cpu
```

Echte Image-/Modell-Pins und Domain-/Secret-Einstellungen in einem geprueften privaten Overlay
ergaenzen; die Vorlagen sind kein sofort freigegebenes Produktionsdeployment.
Anleitung, Staging-CI, Abnahmegrenzen und Rollback:
[GitOps-Deployment-Pfad](../../docs/GITOPS_DEPLOYMENT_PATH.md).
