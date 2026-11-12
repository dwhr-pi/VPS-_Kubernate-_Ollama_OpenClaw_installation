# Ollama-Log-Monitor: Kubernetes, optional Discord

Standard: nur Offline-Plan. Kein Docker, Dienststart, Lesen von Zugangsdaten,
Clusterzugriff, Versand oder Neustart durch Installation/Import dieses Skripts.
Python-Standardbibliothek, kein zusaetzliches requests-Paket erforderlich.

## Vorlagenkorrekturen und Grenzen

Die gelieferte Vorlage enthielt einen Syntaxfehler, shell=True, rohe Logausgabe,
einen eingebetteten Webhook und einen Root-Dienst. Diese Wege werden nicht
uebernommen. Der neue Monitor verwendet feste Argumentlisten, begrenzte
Snapshots statt unbegrenzter Follow-Prozesse, Timeout und Backoff. Auch ein
regulaeres kubectl-Ende verursacht keine enge Neustartschleife.

Nur Kategorien verlassen den Prozess: gpu-memory, oom-killed, crash,
model-load und error. Keine Logzeile, Modellantwort, URL, Exception oder
Dateipfad wird versendet. Discord wird nativ mit content und deaktivierten
Mentions angesprochen, nicht mit text oder dem Slack-Endpunkt. Umleitungen
und Umgebungs-Proxys werden nicht benutzt. TLS-Pruefung bleibt aktiv.

Ein OOMKilled steht haeufig nur im Pod-Status, nicht im Log. Dieser Monitor
erkennt nur im Snapshot enthaltene Signale und ersetzt weder kube-state-metrics
noch Prometheus-Alerts. Keine automatische Pod-Loeschung, Reparatur oder
Modellentladung. Ein erfolgreicher Poll ist kein Inferenz-/Verfuegbarkeitsnachweis.

## Manuell ueber SSH

kubectl erhaelt nur eine begrenzte Umgebung inklusive der ausdruecklich
konfigurierten KUBECONFIG, keine Provider-Tokens oder Proxy-Variablen. Nur eine
vertrauenswuerdige, minimal berechtigte Kubeconfig verwenden; Exec-Plugins in
fremden Kubeconfigs sind ausfuehrbarer Code und werden nicht automatisch freigegeben.

Auf dem Client ssh -t vps verwenden, Host-Key pruefen, dann auf dem VPS in den
geprueften Setup-Checkout wechseln. Fuer Zugriff auf lokale Worker muss die
Kubernetes-API privat ueber WireGuard erreichbar sein. Nicht oeffentlich machen.

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
python3 -B scripts/monitoring/ollama_log_monitor.py
```

Erst nach Freigabe und mit passendem explizitem Kontext, Namespace, Label und
Containernamen fuer maximal fuenf Minuten lesen; CONTEXT vorher ersetzen:

```bash
python3 -B scripts/monitoring/ollama_log_monitor.py \
  --watch --apply --context CONTEXT \
  --namespace llmops --selector app=ollama --container ollama --duration 300
```

Nur einfache Gleichheits-Selektoren werden akzeptiert. Pro Poll maximal
100 Zeilen/65536 Bytes aus 60 Sekunden; standardmaessig alle 30 Sekunden.
Cooldown pro Kategorie 300 Sekunden, auch nach fehlgeschlagenem Versand.
Bei Kubernetes-Fehlern exponentieller Backoff bis 300 Sekunden; endliche
Laufzeit. Exit 1 meldet aufgetretene Poll-/Versandfehler, Exit 2 Konfiguration,
Exit 130 Abbruch. Bei Abbruch bleibt kein Follow-Prozess zurueck.

## Discord separat freigeben

Webhook ist ein Secret: ausserhalb Git, Prompts, Shell-History und Logs halten.
Eine bereits privat angelegte Datei mit Modus 0600 oder strenger, Eigentum des
ausfuehrenden Linux-Benutzers, verwenden. Keine Beispiel-Credentials kopieren.
Datei nur bei ausdruecklichem --send-discord lesen. Windows-ACLs separat absichern.

Zum obigen bewusst ausgefuehrten Befehl beide Optionen ergaenzen:

```text
--send-discord --webhook-file /privater/pfad/discord-webhook
```

Erwartet wird https://discord.com/api/webhooks/ID/TOKEN ohne /slack, Query oder
Weiterleitung. Nur 200/204 gelten als Versand-Erfolg; keine 403/429-Ausnahme.
Fehlschlaege werden ohne sensible Fehlerdetails gemeldet und nicht sofort wiederholt.

## Optionaler systemd-Betrieb

[Unit-Vorlage](../examples/systemd/ollama-log-monitor.service) ist nicht installiert
oder aktiviert. Pfad, dediziertes Konto ollama-monitor und Kontext manuell einrichten.
Geprueftes Skript nach /opt/openclaw-monitor kopieren; Admin besitzt den Code,
Dienstkonto darf ihn nicht veraendern. kubectl mit vertrauenswuerdigem PATH bereitstellen.
Die Unit uebergibt eine getrennte minimal berechtigte Kubeconfig per LoadCredential,
nicht die Admin-Kubeconfig. Nicht-root, keine Capabilities, CPU/RAM/Tasks begrenzt.
Der Beispielprozess endet nach 24 Stunden; danach bewusst neu starten oder einen
geprueften Timer verwenden. Kein unbegrenzter Dienststart durch das Setup.

[RBAC-Role](../examples/monitoring/ollama-log-reader-rbac.yaml) ist nur ein
opt-in Beispiel. Separates RoleBinding fuer die bewusst ausgewaehlte Identitaet
administrativ erstellen. pods get/list und pods/log get sind namespaceweit;
Labels sind keine RBAC-Sicherheitsgrenze. Bei Bedarf eigenen Namespace nutzen.
Keine Rechte auf Secrets, exec, Delete, Deployment oder ClusterRoleBinding.

Discord ist in der Unit nicht aktiviert. Falls gewuenscht ein zweites
LoadCredential fuer den Webhook und die zwei CLI-Optionen bewusst ergaenzen.
Nicht mit systemctl enable/start automatisch aus dieser Doku ausfuehren.

## Quellen und Nachweis

[kubectl logs](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/),
[Discord Webhooks](https://docs.discord.com/developers/resources/webhook).
Offline-Fixtures pruefen Befehle, Limits, Freigaben, Payload, Cooldown, Backoff
und Redaktionsgrenzen. Kein echter Cluster-/Discord-/systemd-Test durchgefuehrt.
