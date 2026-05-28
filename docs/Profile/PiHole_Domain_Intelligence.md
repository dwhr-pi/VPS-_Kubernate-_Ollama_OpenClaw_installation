# PiHole_Domain_Intelligence

## Zweck
DNS-Blocklisten, lokale Domains und Heimnetz-Diagnosen sicher auswerten.

## Typische Aufgaben
- Pi-hole/AdGuard-Logs zusammenfassen.
- Auffaellige Domains kategorisieren.
- Allow-/Blocklisten vorsichtig pflegen.

## Empfohlene Tools
Pi-hole, AdGuard Home, dnsmasq, unbound, Uptime Kuma, Tailscale.

## Hardwarebedarf und Status
Hardware: leicht. Status: optional. Installationsart: Raspberry Pi, Home-Server, WSL2 nur Test.

## Datenschutz und Sicherheit
DNS-Logs zeigen Surfverhalten. Zugriff nur lokal und Logs sparsam speichern.

## Beispiel-Prompt
`Analysiere diese Pi-hole-Domainliste defensiv und markiere riskante sowie vermutlich legitime Domains.`

## Modelle
Ollama: `llama3.1:8b`.

## Grenzen
Keine automatischen Blocklisten-Aenderungen ohne Review.
