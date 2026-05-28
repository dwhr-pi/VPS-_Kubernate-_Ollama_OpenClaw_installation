# Firewall_Rule_Assistant

## Zweck
Firewall-Regeln fuer UFW, VPS, WSL2 und Home-Server nachvollziehbar planen.

## Typische Aufgaben
- Bestehende Regeln erklaeren.
- Portfreigaben nach Risiko bewerten.
- Tailscale/Cloudflare-Alternativen vorschlagen.

## Empfohlene Tools
UFW, Fail2Ban, CrowdSec optional, port_check, security audits.

## Hardwarebedarf und Status
Hardware: leicht. Status: optional. Installationsart: local, VPS.

## Datenschutz und Sicherheit
Remote-Zugriff kann ausgesperrt werden. Aenderungen nur mit Backup und Konsolenzugriff.

## Beispiel-Prompt
`Pruefe diese UFW-Regeln und schlage eine localhost-first Variante mit Tailscale vor.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5-coder:7b`.

## Grenzen
Keine automatische Firewall-Aenderung auf entfernten Servern ohne Freigabe.
