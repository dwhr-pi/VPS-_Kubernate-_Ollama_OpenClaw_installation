# WSL unter Windows einrichten und wieder entfernen

Diese Anleitung erklärt kurz und einfach:

- WSL installieren
- Ubuntu 24.04 oder eine andere Linux-Distribution unter WSL einrichten
- WSL sauber beenden oder zurücksetzen
- Ubuntu oder andere Distributionen wieder deinstallieren

## 1. WSL unter Windows installieren

Öffne `PowerShell` als Administrator und führe aus:

```powershell
wsl --install
```

Danach Windows neu starten, falls du dazu aufgefordert wirst.

## 2. Ubuntu 24.04 installieren

Für Ubuntu 24.04 kannst du ausführen:

```powershell
wsl --install -d Ubuntu-24.04
```

Wenn du eine andere Distribution möchtest, liste zuerst die verfügbaren Versionen auf:

```powershell
wsl --list --online
```

Danach z. B.:

```powershell
wsl --install -d Ubuntu
```

oder:

```powershell
wsl --install -d Debian
```

## 3. Erster Start

Beim ersten Start fragt Linux nach:

1. einem Benutzernamen
2. einem Passwort

Wichtig:

- Dieses Passwort ist dein Linux- bzw. Ubuntu-Passwort
- es ist nicht automatisch dein Windows-Passwort
- genau dieses Passwort ist später das `sudo`-Passwort

## 4. WSL starten

Ubuntu z. B. so starten:

```powershell
wsl -d Ubuntu-24.04
```

## 5. WSL sauber beenden

Eine einzelne laufende Distribution beenden:

```powershell
wsl --terminate Ubuntu-24.04
```

Alle laufenden WSL-Instanzen komplett stoppen:

```powershell
wsl --shutdown
```

## 6. WSL-Status prüfen

```powershell
wsl --list --verbose
```

## 7. Eine Distribution zurücksetzen oder löschen

Wenn du Ubuntu komplett entfernen willst:

```powershell
wsl --unregister Ubuntu-24.04
```

Wichtig:

- Dadurch wird die gesamte Linux-Installation dieser Distribution gelöscht
- alle Daten innerhalb dieser WSL-Distribution gehen verloren

## 8. Eine andere Linux-Version installieren

Nach dem Entfernen kannst du einfach eine andere Distribution neu installieren:

```powershell
wsl --install -d Debian
```

## 9. WSL komplett von Windows entfernen

Wenn du WSL selbst ganz loswerden willst:

1. Optionale Distributionen zuerst mit `wsl --unregister` entfernen.
2. Danach in PowerShell als Administrator:

```powershell
wsl --shutdown
```

3. Anschließend Windows-Features oder DISM verwenden:

```powershell
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart
```

4. Windows neu starten.

## 10. Empfehlung für dieses Projekt

Für dieses Setup ist `Ubuntu-24.04` unter WSL eine gute Standardwahl.

Empfohlener Schnellstart:

```powershell
wsl --install -d Ubuntu-24.04
```

Danach in Ubuntu:

```bash
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```
