# P0-A: Host-Listener-Audit ohne Scheinerfolg

Basis: `1e75043a8ec567d193a0fd54b174d5105ab1a97d`, Ziel `main`.
Branch: `codex/claude-review-p0-20261103`.

## Zweck und Umfang

Der alte Port-Audit beendete sich bei fehlendem `ss` erfolgreich, pruefte nur TCP und hatte
keinen verbindlichen Vergleich mit der Registry. Neuer redigierter Python-Pruefpfad und
kompatibler Shell-Einstieg; 6443/18789 in Registry und generierter Matrix; isolierte CI-Fixtures.
Keine Installer-/Service-/Firewall-/Kubernetes-Aenderung und keine neuen Tools.

[Vollstaendige Nachpruefung der elf Ausgangsbefunde](../CLAUDE_REVIEW_2026-11-03.md).

## Risiko und Rollback

Neue Exitcodes machen reale Fehler sichtbar; alte Caller koennen dadurch erstmals abbrechen.
Private Hosts brauchen die richtigen expliziten VPN-CIDRs. Der Check klassifiziert lokale
Listener, nicht die gesamte Netzwerksicherheit. Revert dieses einzelnen Patches moeglich,
keine Nutzdatenmigration, kein Reset, keine Runtime-Ruecksetzung. Fehlende Abnahme nie als gruen melden.

## Abnahmekriterien und Befehle

```bash
python3 -B -m unittest discover -s tests -p test_listener_audit.py -v
python3 -B -m unittest discover -s tests -p test_registry_catalog.py -v
python3 -B -m unittest discover -s tests -p test_repository_audit.py -v
python3 -B scripts/quality/registry_catalog.py --check
python3 -B scripts/quality/repository_audit.py --section registry
shellcheck scripts/security/port_exposure_audit.sh
bash -n scripts/security/port_exposure_audit.sh
git diff --check
```

Erwartung: IPv4/IPv6/UDP-Wildcards werden erkannt, Loopback erlaubt, expliziter VPN-Bereich
eng begrenzt. Fehlende Werkzeuge, Timeout, kaputte Ausgabe und doppelte Registry-Ports schlagen
fehl. Keine Prozessargumente/Secrets in Ausgabe; Dry-run beruehrt weder Registry noch Host.
Der neue Test ist im bestehenden Ubuntu-Workflow eingebunden; keine neue Allowlist/Skip-Regel.

Lokaler Nachweis am 03.11.2026: sechs gezielte Suites, 58 Tests insgesamt, 54 bestanden,
vier POSIX-Tests unter Windows begruendet uebersprungen. Alle elf neuen Listener-Fixtures bestanden.
Generator: kein Drift. Registry: 400 Tools, 250 Profile, 47 Ports, null Fehler und 793 Altlasten-Hinweise.
ShellCheck, shfmt, Bash-Syntax, Markdownlint und Diff-Pruefung bestanden. Gitleaks-Dateiscans
aller acht Patchdateien bestanden (redigierte Ausgabe); kein erneuter Vollhistorien-Scan behauptet.

Echte Linux-Listener-, NAT-, CNI-, Firewall-/WAN-, TLS-, GPU- und Restore-Abnahmen wurden hier
nicht ausgefuehrt. Vollstaendiges Gruen aller GitHub-Checks erst fuer den hochgeladenen Head belegen.
