# Vorhandene CI-/Deployment- und Praesentationsbausteine

Nur die fuer die gewaehlte Sprache benoetigte Vorlage lesen. Die Dateien sind Referenzen im
Setup-Repository, keine bereits aktiven Workflows des Zielprojekts.

| Bedarf                  | Referenz                                                                                                                                                       | Entscheidender Unterschied                                                |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Go CI                   | [go-ci.yml.example](../../../examples/manus-ci-cd/go-ci.yml.example)                                                                                           | go-version-file, vet, Race-/Coverage-Tests; cache ist bewusst false       |
| Rust CI                 | [rust-ci.yml.example](../../../examples/manus-ci-cd/rust-ci.yml.example)                                                                                       | Exakte Toolchain, fmt, Clippy mit -D warnings, --locked und Release-Build |
| Manueller Image-Release | [go-release.yml.example](../../../examples/manus-ci-cd/go-release.yml.example)                                                                                 | Freigegebener main-Aufruf, eigene Publish-Rechte, kein Cluster-Rollout    |
| Container               | [Dockerfile.go.example](../../../examples/manus-ci-cd/Dockerfile.go.example)                                                                                   | Multi-Stage/Non-Root; echte Basis-Digests erforderlich, nur Go ohne CGO   |
| Kubernetes              | [kubernetes.yml.example](../../../examples/manus-ci-cd/kubernetes.yml.example)                                                                                 | Ungueltiges Platzhalterimage, Requests/Limits und getrennte Probes        |
| Technologiefolien       | [Praesentation](../../../docs/presentations/technology-tooling-overview.pptx) und [Folienquelle](../../../docs/presentations/technology-tooling-overview.json) | Bestehende 13 Folien, kein Zugriff auf Manus-internes Slide-Artefakt      |

Go-Modul-Caching ist eine optionale Optimierung, kein Korrektheitsnachweis. Bei Freigabe nach
OS/Architektur/Go-Version und go.sum trennen; fremden PR-Code nicht in privilegierte Release-Caches
oder private Runner uebernehmen. Keine Cache-Aenderung allein aufgrund des Interviewtexts vornehmen.

Cargo.lock und --locked stabilisieren Abhaengigkeitsaufloesung, garantieren aber keine
byteidentischen Release-Binaries. Toolchain, Target, Linker, Buildflags und native Abhaengigkeiten
gehoeren ebenfalls zum Buildnachweis.

Die [ausfuehrliche Anleitung](../../../docs/tutorials/manus-ci-cd-deployment.md) erklaert echte
Aktivierungsvoraussetzungen. Kubeconform/KubeLinter koennen Schemas/Regeln pruefen, beweisen aber
weder Laufzeitfunktion noch Sicherheit. Schemaabrufe, Plugins und Clusterzugriff nicht als rein
offline einstufen.

Keine Vorlage nach .github/workflows kopieren, keinen Container bauen/pushen und kein Manifest
anwenden, solange dafuer kein ausdruecklicher Auftrag vorliegt.
