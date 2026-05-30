# HE Oracle DDoS Protection

## Architektur

Hurricane Electric ist DNS-/IPv6-/Domain-Einstieg, Oracle VPS ist DMZ/Control Node, Heimnetz kommt ueber WireGuard.

## Wichtig

HE allein ist kein vollstaendiger DDoS-Schutz. Notwendig bleiben Firewall, Rate-Limits, CrowdSec/Fail2ban, Reverse Proxy, Monitoring und Provider-Regeln.

## Nicht oeffentlich

Ollama, OpenClaw Gateway, Home Assistant, Datenbanken, Kubernetes API, NAS, ComfyUI.
