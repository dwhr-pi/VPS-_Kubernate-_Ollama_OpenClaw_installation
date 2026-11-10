# Historische Installation und Abschnittslinks

Archiv, keine aktuelle Anleitung. Fuer Installation und Updates gilt das
[Haupt-README](../../readme.md#installation-und-betrieb).

<!-- markdownlint-configure-file {"MD033": {"allowed_elements": ["a", "details", "summary"]}} -->

**Historischer One-Liner (nicht ausfuehren):** So lautete der fruehere
unsignierte Einstieg. Er fuehrte den Download direkt aus, ohne vorherige
Pruefung. Der aktuelle Bootstrap blockiert diesen Aufruf standardmaessig.

```text
cd ~
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

<details>
<summary>Historischer Installationsweg: Neustart, Update und Entfernen</summary>

**Archivtext, keine aktuelle Anleitung. Nicht ausführen.** Der folgende
Originaltext beschreibt einen älteren Setup-Stand. Die Reset-, Clean- und
Löschbefehle können lokale Änderungen und private Daten unwiederbringlich
entfernen. Maßgeblich ist der aktuelle Installations- und Updateweg oben.

#### Historisch: Setup erneut starten

Wenn du das Setup-Menü erneut starten möchtest, navigiere in das Installationsverzeichnis
(standardmäßig `~/openclaw_ultimate_setup`) und führe das Hauptskript aus:

```text
cd ~/openclaw_ultimate_setup
bash ./setup_ultimate.sh
```

#### Historisch: Setup aktualisieren oder lokal entfernen

Wenn es Änderungen im Repository gab und du dein bestehendes Setup aktualisieren möchtest, wird
jetzt bewusst ein **harter Repo-Abgleich** empfohlen. So bleiben keine alten Setup-Dateien halb
stehen, während dein ausgelagerter Benutzer-Workspace erhalten bleibt:

```text
cd ~/openclaw_ultimate_setup
git status --short
git fetch origin --prune
git checkout main 2>/dev/null || git checkout -b main --track origin/main
git reset --hard origin/main
git clean -fd
printf '\nDas Repository ist jetzt aktualisiert.\n'
printf 'Du kannst die aktuelle Terminal-Ausgabe jetzt in Ruhe lesen oder kopieren.\n'
read -rp "Drücke Enter, um danach das Setup-Menü zu starten ... "
bash ./setup_ultimate.sh
```

Wenn du vor dem Neustart des Menüs den angezeigten Stand erst prüfen möchtest, ist diese kleine
Pause bewusst hilfreich. So kannst du z. B. Git-Meldungen, Versionsstände oder Warnungen noch lesen
und direkt aus dem Terminal kopieren, bevor das interaktive Setup weiterläuft.

Wichtig:

- Die Pause erscheint nur dann, wenn der harte Repo-Abgleich erfolgreich war.
- `git reset --hard origin/main` und `git clean -fd` verwerfen lokale Änderungen und ungetrackte
  Zusatzdateien **im Setup-Repository**.
- Dein ausgelagerter Benutzer-Workspace unter `~/.openclaw_ultimate_user_data` bleibt dabei
  erhalten.
- Die neueren Update-Skripte legen vor dem harten Abgleich zusätzlich eine Sicherung der verworfenen
  Repo-Differenzen unter `~/.openclaw_ultimate_user_data/repo_update_backups` an.

Wenn dabei vorher lokale Änderungen in Dateien wie `install.sh` oder `setup_ultimate.sh` auftauchen,
ist das gerade der Grund für den harten Abgleich: Das Repo soll vollständig auf `origin/main`
zurück, statt nur teilweise über `git pull` aktualisiert zu werden.

In diesem Fall gibt es jetzt zwei sichere Wege:

- im Menü den Punkt `Setup-Repository hart reparieren / auf GitHub main zurücksetzen` verwenden
- oder den One-Liner-Installer erneut starten, der bei vorhandenem Repo jetzt ebenfalls den harten
  Abgleich verwendet

Wichtig dabei:

- Es werden nur Dateien im Setup-Repository zurückgesetzt.
- Dein ausgelagerter Benutzer-Workspace unter `~/.openclaw_ultimate_user_data` bleibt erhalten.
- Vor dem harten Abgleich legt der Installer jetzt zusätzlich eine Sicherung des Repo-Zustands unter
  `~/.openclaw_ultimate_user_data/repo_update_backups` an.

Alternativ kannst du im Menü den Punkt `Setup-Update + System-Update (Repo, OS & pnpm)` nutzen.
Dieser zieht den aktuellen Repository-Stand direkt im Setup-Verzeichnis und aktualisiert danach
Ubuntu sowie `pnpm`.

Wenn danach trotzdem noch ein älterer Setup-Stand angezeigt wird, sollte zuerst geprüft werden, ob
wirklich das richtige Repository-Verzeichnis verwendet wird. Ein normaler `git pull` ist dafür nicht
mehr der empfohlene Weg.

Prüfen:

```text
cd ~/openclaw_ultimate_setup
git status
```

Wenn du den harten Repo-Abgleich lieber manuell ausführen möchtest, kannst du das Setup so direkt
auf den aktuellen GitHub-Stand zurücksetzen:

```text
cd ~/openclaw_ultimate_setup
git fetch origin --prune
git reset --hard origin/main
printf '\nDas Repository wurde hart auf GitHub main zurückgesetzt.\n'
printf 'Du kannst die aktuelle Terminal-Ausgabe jetzt in Ruhe lesen oder kopieren.\n'
read -rp "Drücke Enter, um danach das Setup-Menü zu starten ... "
bash ./setup_ultimate.sh
```

Dafür gibt es jetzt auch direkt im Menü einen eigenen Punkt:

- `Setup-Repository hart reparieren / auf GitHub main zurücksetzen`

Dieser Weg ist hilfreich, wenn trotz normalem `git pull` noch ein älterer Setup-Stand angezeigt
wird.

Wenn du ganz sauber neu anfangen willst, ist auch das weiterhin möglich:

```text
cd ~
rm -rf ~/openclaw_ultimate_setup
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Wenn du das lokale Setup wieder entfernen möchtest, hast du zwei saubere Wege:

1. Zuerst im Menü `Tools: Installieren & Deinstallieren` und
   `Profile: Installieren & Deinstallieren` alle gewünschten Komponenten wieder abwählen.
2. Danach das lokale Arbeitsverzeichnis entfernen:

```text
cd ~
rm -rf ~/openclaw_ultimate_setup
```

Wenn du zusätzlich lokal installierte Komponenten wie `Home Assistant`, `Ollama` oder einzelne Tools
vollständig entfernen willst, nutze die jeweiligen `*_uninstall.sh` Skripte im Menü oder direkt
unter `scripts/tools/`.

Wenn du zusätzlich den ausgelagerten Benutzer-Workspace mit sensiblen Daten entfernen möchtest,
kannst du das entweder im Menü über `Benutzer-Workspace verwalten` tun oder manuell:

```text
rm -rf ~/.openclaw_ultimate_user_data
```

</details>

<!-- Explicit legacy anchors preserve incoming links without oversized heading navigation. -->
<details>
<summary>Historische Abschnittslinks aufklappen</summary>

Alte Kommandos, Versionen und Aussagen sind keine aktuelle Installationsempfehlung.
Die bisherigen Abschnittsanker bleiben hier erhalten; ihre Links fuehren in die historische Langfassung.

<a id="vps--kubernate--ollama--openclaw-installation---ultimate-setup-v1117"></a>
[VPS- Kubernate- Ollama & OpenClaw installation - Ultimate Setup V11.17](README_FULL_2026_11_01.md#vps--kubernate--ollama--openclaw-installation---ultimate-setup-v1117)

<a id="empfohlener-sicherer-einstieg"></a>
[Empfohlener sicherer Einstieg](README_FULL_2026_11_01.md#empfohlener-sicherer-einstieg)

<a id="inhaltsverzeichnis"></a>
[Inhaltsverzeichnis](README_FULL_2026_11_01.md#inhaltsverzeichnis)

<a id="aktuelle-governance-dokumente"></a>
[Aktuelle Governance-Dokumente](README_FULL_2026_11_01.md#aktuelle-governance-dokumente)

<a id="wichtiger-original--und-support-hinweis"></a>
[Wichtiger Original- und Support-Hinweis](README_FULL_2026_11_01.md#wichtiger-original--und-support-hinweis)

<a id="empfohlener-start-he-vorne-oracle-steuert-pi-weckt-rtx-rechnet"></a>
[Empfohlener Start: HE vorne, Oracle steuert, Pi weckt, RTX rechnet](README_FULL_2026_11_01.md#empfohlener-start-he-vorne-oracle-steuert-pi-weckt-rtx-rechnet)

<a id="-zielbild"></a>
[🧱 Zielbild](README_FULL_2026_11_01.md#-zielbild)

<a id="quickstarts"></a>
[Quickstarts](README_FULL_2026_11_01.md#quickstarts)

<a id="setup-skripte-schnell-finden"></a>
[Setup-Skripte schnell finden](README_FULL_2026_11_01.md#setup-skripte-schnell-finden)

<a id="speicherplatz-und-bereinigung"></a>
[Speicherplatz und Bereinigung](README_FULL_2026_11_01.md#speicherplatz-und-bereinigung)

<a id="-gegenwärtiger-status"></a>
[🟡 Gegenwärtiger Status](README_FULL_2026_11_01.md#-gegenwärtiger-status)

<a id="-neue-übersichten-und-doctor-skripte"></a>
[🧭 Neue Übersichten und Doctor-Skripte](README_FULL_2026_11_01.md#-neue-übersichten-und-doctor-skripte)

<a id="tool-quellen-und-github-regel"></a>
[Tool-Quellen und GitHub-Regel](README_FULL_2026_11_01.md#tool-quellen-und-github-regel)

<a id="optionale-profile"></a>
[Optionale Profile](README_FULL_2026_11_01.md#optionale-profile)

<a id="optional-openhiggsstack--ai-cinema-studio"></a>
[Optional: OpenHiggsStack / AI Cinema Studio](README_FULL_2026_11_01.md#optional-openhiggsstack--ai-cinema-studio)

<a id="optional-gamedev-3d-studio-nextlevel"></a>
[Optional: GameDev 3D Studio NEXTLEVEL](README_FULL_2026_11_01.md#optional-gamedev-3d-studio-nextlevel)

<a id="optional-cad_konstrukteur"></a>
[Optional: CAD_Konstrukteur](README_FULL_2026_11_01.md#optional-cad_konstrukteur)

<a id="optional-architektur-3d-bim"></a>
[Optional: Architektur 3D BIM](README_FULL_2026_11_01.md#optional-architektur-3d-bim)

<a id="optional-robotertechnik--anlagensteuerung"></a>
[Optional: Robotertechnik & Anlagensteuerung](README_FULL_2026_11_01.md#optional-robotertechnik--anlagensteuerung)

<a id="optional-wissenschaftliche-science-lab-profile"></a>
[Optional: Wissenschaftliche Science-Lab-Profile](README_FULL_2026_11_01.md#optional-wissenschaftliche-science-lab-profile)

<a id="-sicherheit-bei-der-nutzung"></a>
[🔐 Sicherheit bei der Nutzung](README_FULL_2026_11_01.md#-sicherheit-bei-der-nutzung)

<a id="-kostenfalle-durch-cloud-apis-und-bezahldienste"></a>
[⚠️ Kostenfalle durch Cloud-APIs und Bezahldienste](README_FULL_2026_11_01.md#-kostenfalle-durch-cloud-apis-und-bezahldienste)

<a id="-trading--web3--und-finanzhinweis"></a>
[⚠️ Trading-, Web3- und Finanzhinweis](README_FULL_2026_11_01.md#-trading--web3--und-finanzhinweis)

<a id="-installationspfade"></a>
[🧭 Installationspfade](README_FULL_2026_11_01.md#-installationspfade)

<a id="minimal-setup"></a>
[Minimal Setup](README_FULL_2026_11_01.md#minimal-setup)

<a id="full-setup"></a>
[Full Setup](README_FULL_2026_11_01.md#full-setup)

<a id="cluster-setup"></a>
[Cluster Setup](README_FULL_2026_11_01.md#cluster-setup)

<a id="quickstart-gpu-workstation"></a>
[Quickstart GPU Workstation](README_FULL_2026_11_01.md#quickstart-gpu-workstation)

<a id="quickstart-media-ai"></a>
[Quickstart Media AI](README_FULL_2026_11_01.md#quickstart-media-ai)

<a id="quickstart-secure-production-like"></a>
[Quickstart Secure Production-like](README_FULL_2026_11_01.md#quickstart-secure-production-like)

<a id="-dokumentation"></a>
[📖 Dokumentation](README_FULL_2026_11_01.md#-dokumentation)

<a id="neue-plattformprofile"></a>
[Neue Plattformprofile](README_FULL_2026_11_01.md#neue-plattformprofile)

<a id="neue-studio--und-spezialprofile"></a>
[Neue Studio- und Spezialprofile](README_FULL_2026_11_01.md#neue-studio--und-spezialprofile)

<a id="-enthaltene-komponenten--tools"></a>
[🛠️ Enthaltene Komponenten & Tools](README_FULL_2026_11_01.md#-enthaltene-komponenten--tools)

<a id="-profil-management"></a>
[👤 Profil-Management](README_FULL_2026_11_01.md#-profil-management)

<a id="profilgruppen"></a>
[Profilgruppen](README_FULL_2026_11_01.md#profilgruppen)

<a id="-codex-nachbau-und-plattformziele"></a>
[💻 Codex-Nachbau und Plattformziele](README_FULL_2026_11_01.md#-codex-nachbau-und-plattformziele)

<a id="-verzeichnisstruktur"></a>
[⚙️ Verzeichnisstruktur](README_FULL_2026_11_01.md#-verzeichnisstruktur)

<a id="-wichtige-hinweise"></a>
[⚠️ Wichtige Hinweise](README_FULL_2026_11_01.md#-wichtige-hinweise)

<a id="ai-media-studio"></a>
[AI Media Studio](README_FULL_2026_11_01.md#ai-media-studio)

<a id="start-here"></a>
[Start Here](README_FULL_2026_11_01.md#start-here)

</details>
