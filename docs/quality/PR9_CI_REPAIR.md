# PR 9: Ursachen und Reparaturvertrag

Ausgangspunkt: Head `15589d834d308688e3db234cdff432009714b6f1`, PR-Merge-Test
`2b65b70450fa704c54148a155daf79453427e4ff`. Die zehn roten Jobanzeigen waren nicht zehn
unabhaengige Defekte. Push-/PR-Duplikate werden nach Ursache behandelt, keine neuen PRs angelegt.

| Ursache | Reparatur | Erhaltener Schutz |
|---|---|---|
| ShellCheck 0.9: Argumentvertrag der Sortierung | Expliziter Baseline-Pfad am Menueaufruf | Fixer Kern, A-Z-Bestand, neue Eintraege danach; keine verlorenen Auswahlen |
| ShellCheck: Code nach `exec` in Legacy-Einstiegen | Alte Skriptnamen bleiben delegierende Wrapper, Altcode als gesperrte Textreferenz archiviert | Gepruefter Core-Vertrag vor jedem Hosteingriff; alte Funktions-Fixtures bleiben separat |
| Zwei neue native Rezepte nicht vollstaendig verdrahtet | ArgoCD CLI/Cloudflared in Menue-, Dispatch-, Marker- und Recovery-Vertraegen | Kein Server-, Tunnel-, Login- oder Clusterstart |
| Veraltete Testannahmen | Aktive Docker-freie Baseline statt Docker-APT-Download testen; dokumentierten Menuehelfer pruefen | Alte signierte Hash-Metadaten im historischen Snapshot bleiben erhalten |
| Generierter Inventartext verlor Quellenklassifikation | Generator und Inventar nennen unverifizierte Originalreferenzen explizit | Original-URLs und 23 einzeln genehmigte Belege bleiben; keine Domain-Ausnahme |
| Historische Zeilenanker zeigen auf heutige kurze Wrapper | Historische Zeilennummern im Label erhalten, heutige Dateilinks ohne falschen Live-Anker | Ausgangscommit und historische Einstufung bleiben sichtbar |
| Trivy bricht bereits bei Installation ab | Scanner aus festem offiziellen Git-Commit bauen statt Release-Installerskript | Secret-Scan und HIGH/CRITICAL-Konfigurationsscan bleiben fail-closed |

Betroffene urspruengliche PR-Jobs: ShellCheck `126397196553`, Offline-Tests `126397196616`,
Regression `126397196310`, Trivy `126397196961` und `126397196912`, Repo-Health `126397196607`.
Trivy meldete beim Installer Exitcode 6, nicht bereits Scanner-Funde. Ein neues Scan-Ergebnis darf
deshalb erst nach erfolgreichem Build und tatsaechlicher Scanner-Ausfuehrung behauptet werden.

## Scanner-Vertrag und Ressourcen

`scripts/ci/build_trivy.sh` plant ohne Optionen nur. `--build` verlangt ausdruecklich einen
nicht privilegierten GitHub-Linux-Runner, vorhandenes Go 1.27.3 und Runner-Temp/Output-Kontext.
Der offizielle Tag v0.76.1 wurde zu Commit `e713f67f7d54decdcd9b3132c9751833dcced698` aufgeloest;
`go.mod` nennt Go 1.27.0, der Versionsstring liegt unter `pkg/version/app.ver`.
Keine Version/Pins/Checksummen werden erfunden oder als Live-Inferenzabnahme ausgegeben.

Der genehmigte Go-SDK-Weg bleibt eine SHA-gepinnte Setup-Action im Wegwerf-Runner. Trivy selbst
kommt aus Git-Quellen, Module werden geprueft, Lock-Drift blockiert den Build. Keine Docker-Engine,
kein globales Installieren oder Loeschen von Caller-Verzeichnissen. Zwei Buildjobs, Go-Heap-Ziel
zwei GiB; die getrennten Scan-Jobs haben je 35 Minuten fuer Build plus Scan. Das ist keine
Anhebung von Test-Zeitgrenzen oder Abschwaechung der Scan-Schweregrade. Der Runner entsorgt seine
temporaeren Quellen/Caches nach dem Job, nicht ein rekursiver Cleanup gegen Benutzerpfade.

## Abnahme und Grenzen

Gezielt erneut pruefen: `test_pr9_ci_repair.py`, `test_core_source_gate.py`,
`test_native_tool_menu.py`, `test_platform_gap_additions.py`, `test_platform_navigation.py`,
`test_online_services_docs.py`, `test_external_link_policy.py`, `test_ci_scan_safety.py`,
`test_security_audit_docs.py` und `test_production_baseline.py`.
Die volle isolierte Regression und die echten Scanner muessen fuer den neuen Online-Head laufen.
Lokale Windows-Bash-Zeitueberschreitungen werden nicht durch neue Skips oder hoehere Test-Limits verdeckt.

Kein Merge nach `main`, kein Force-Push, kein WSL-/Credential-/Produktivzugriff und keine echten
Tool-/Modell-/Dienststarts. Die vorhandene Nutzerdatenablage bleibt unberuehrt.
Rollback: gezielter Revert des Reparaturcommits auf dem Review-Branch, ohne Reset oder Datenloeschung.
Nicht zu einem ungeprueften Scanner-Download oder faelschlich gruenen Scan zurueckkehren.
