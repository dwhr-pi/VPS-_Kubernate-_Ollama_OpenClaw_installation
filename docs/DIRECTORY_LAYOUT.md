# Verzeichnisse und Kompatibilitaet

Stand: 27.10.2026. Unterschiedliche Namen sind nicht automatisch Duplikate.

| Pfad | Zweck / Behandlung |
| --- | --- |
| `config/` | Deklarative Registries, gepruefte Buildvertraege, Beispielkonfigurationen |
| `configs/` | Bestehende Service-/Integrationsbeispiele, unter anderem Huginn-Szenarien; nicht blind nach `config/` verschieben |
| `config/tools.yml`, `config/profiles.yml` | Primaere JSON-kompatible YAML-Registries |
| `config/tools.yaml`, `config/profiles.yaml` | Dokumentierte Aliasdateien; keine zweiten vollstaendigen Registries |
| `docs/Profil/` | Fachliche Quellen/Prompt-Grundlagen, unter anderem `*.doc.md` |
| `docs/Profile/` | Abgeleitete Profilseiten und Status-/Matrixdokumente; nicht dieselben Quelldateien |
| `readme.md` | Einzige versionierte Root-README; Schreibweise auf case-sensitiven Systemen beachten |
| `installed_tools.txt`, `installed_profiles.txt` im Repo-Root | Historische lokale Dateien, nicht mehr versioniert; vorhandene lokale Kopien werden nicht geloescht |
| `~/.openclaw_ultimate_user_data/` | Aktiver externer Benutzer-Workspace; nicht in Git migrieren oder durch Repo-Updates ersetzen |

Der Statuspfad wird im Setup bereits getrennt verwendet. Die Entversionierung
der beiden Root-Dateien kopiert keine Daten und aendert keine Installation.
Ein alter Checkout besitzt unter Umstaenden noch versionierte Kopien; ein
Update ist kein Import dieser Altdateien in den aktiven Workspace.

Ein spaeteres Zusammenfuehren von Verzeichnissen benoetigt eine Referenz-/Link-
Migration mit Kompatibilitaetshinweisen. Diese Arbeit verschiebt keine dieser
Verzeichnisse und loescht keine historischen Dokumente.
