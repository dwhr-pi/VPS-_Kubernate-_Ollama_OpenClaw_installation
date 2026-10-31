# Automaton-Integrationsschicht

[Tutorial, Upstream-Pruefung und Sicherheitsgrenzen](../../docs/tools/automaton.md).

Dies ist **nicht** der Conway-Automaton-Quellcode und kein autonomer Agent. Der optionale
GitHub-Source-Installer liegt in `scripts/tools/automaton_install.sh`. Er baut separat unter dem
privaten User-Workspace, ohne Docker oder Agentenstart. `review.py` prueft ausschliesslich
strukturierte Vorschlaege offline, ohne Shell, Netzwerk, Walletzugriff oder Ausfuehrungsfreigabe.

```bash
python3 tools/automaton/review.py plan
python3 tools/automaton/review.py review examples/automaton/review-proposal.json
```

Keine Secrets in Vorschlaege einfuegen. Die Policy-Datei ist nur ein Entwurf fuer spaetere Adapter,
kein Sicherheitsprofil der Upstream-Runtime. Die Integration folgt der Repository-Lizenz; Upstream
ist separat MIT-lizenziert.
