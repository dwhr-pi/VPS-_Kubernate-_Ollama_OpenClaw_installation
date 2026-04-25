# 🔒 Installation aus einem privaten Repository

Dieses Dokument beschreibt, wie Sie das **OpenClaw Ultimate Setup V4** sicher aus einem privaten GitHub-Repository installieren können. Da private Repositories eine Authentifizierung erfordern, ist der Standard-`curl`-Befehl hier etwas komplexer.

---

## 🔑 1. GitHub Personal Access Token (PAT) erstellen

Bevor Sie beginnen, müssen Sie ein Token erstellen, um den Zugriff auf Ihr privates Repository zu autorisieren:

1.  Gehen Sie zu [GitHub Settings > Developer settings > Personal access tokens > Fine-grained tokens](https://github.com/settings/tokens?type=beta).
2.  Klicken Sie auf **Generate new token**.
3.  Geben Sie dem Token einen Namen (z. B. "OpenClaw-Installer").
4.  Wählen Sie unter **Repository access** die Option "Only select repositories" und wählen Sie `VPS-_Kubernate-_Ollama_OpenClaw_installation` aus.
5.  Geben Sie unter **Permissions** dem Repository "Contents" die Berechtigung **Read-only**.
6.  Klicken Sie auf **Generate token** und kopieren Sie das Token sicher (es wird nur einmal angezeigt!).

---

## 🚀 2. Installation via `git clone` (Empfohlen)

Dies ist der sicherste und einfachste Weg für private Repositories. Ersetzen Sie `DEIN_TOKEN` durch das zuvor erstellte Token:

```bash
# Repository klonen (Token wird für die Authentifizierung genutzt)
git clone https://DEIN_TOKEN@github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git openclaw_setup

# In das Verzeichnis wechseln und das Setup starten
cd openclaw_setup && chmod +x setup_ultimate_v11.sh && ./setup_ultimate_v11.sh
```

---

## 📡 3. Installation via `curl` (Alternativ)

Wenn Sie unbedingt einen One-Liner mit `curl` verwenden möchten, sieht der Befehl für ein privates Repository wie folgt aus:

```bash
curl -H "Authorization: token DEIN_TOKEN" \
     -L https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

**⚠️ Wichtig:** Bei dieser Methode müssen Sie sicherstellen, dass das `install.sh` Skript innerhalb Ihres Repositories ebenfalls so angepasst ist, dass es das Klonen des privaten Repositories mit dem Token unterstützt.

---

## 🛡️ Sicherheitshinweise

*   **Token-Geheimhaltung:** Geben Sie Ihr Personal Access Token niemals an Dritte weiter.
*   **Token-Löschung:** Wenn Sie die Installation abgeschlossen haben und keinen weiteren Zugriff mehr benötigen, können Sie das Token in Ihren GitHub-Einstellungen wieder löschen.
*   **Verlauf löschen:** Wenn Sie das Token direkt im Terminal eingegeben haben, sollten Sie Ihren Befehlsverlauf bereinigen:
    ```bash
    history -c && history -w
    ```

Viel Erfolg bei der Einrichtung Ihres geschützten Systems!
