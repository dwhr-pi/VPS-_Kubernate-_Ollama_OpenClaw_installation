# Verbindliche Installationsrichtlinie

Entscheidung des Maintainers vom 03.11.2026:

- Git-Quellen herunterladen, pruefen, bauen und installieren bleibt der Standard fuer Tools und Programme.
- Keine Installation von Docker Engine, Docker Compose oder Tools ueber Docker; kein automatischer Docker-Fallback.
- Warnungen oder spaetere Reviews sind kein Auftrag, Git-Installationen pauschal zu sperren
  oder auf Docker umzulenken.
- Integritaets-, Pfad-, Speicherplatz- und Berechtigungspruefungen bleiben verbindlich.
  Eine fehlgeschlagene Pruefung stoppt den konkreten Versuch, nicht grundsaetzlich den Git-Weg.
- Fehlende native Buildrezepte bleiben sichtbar offen; Quellen allein sind keine installierte Runtime.
- apt ist nur fuer erforderliche System-/Build-Abhaengigkeiten vorgesehen.
  Bereits genehmigte private Basis-Toolchains und die offizielle Forgejo-Codeberg-Ausnahme
  bleiben dokumentierte Ausnahmen.

Bestehende Docker-/Compose-Dateien bleiben fuer historische Referenz und Datenrettung erhalten,
nicht als Empfehlung fuer Neuinstallationen. Bestehende Container, Volumes und Programme werden nicht entfernt.
Kubernetes benoetigt eine CRI-Laufzeit wie containerd; das ist keine Docker-Installation und keine
Freigabe fuer einen automatischen Cluster-Start. Dienste, Tunnel, Modelle und Cluster bleiben opt-in.

Die Alt-Deinstallationen von K3s und Clawbake liefern jetzt wie Ollama/OpenClaw eine
nicht loeschende Vorschau mit Exitcode 3. Ohne belegten Besitz-/Migrationsvertrag gibt es
keine automatische Entfernung und keinen geloeschten Installationsstatus.

Abnahme und Restarbeiten: [F01-F07](F01_F07_IMPLEMENTATION.md).
