# Tool Deployment Matrix

| Toolgruppe | Status | Zielhost | Risiko | Bemerkung |
| --- | --- | --- | --- | --- |
| Queue/Jobs | planned | alle | medium | FIFO/TSV minimal, Redis/RabbitMQ optional |
| Monitoring | planned/optional | MiniPC/VPS | medium | Glances/Netdata zuerst, Grafana optional |
| Security Scanner | planned/optional | WSL2/VPS | medium | keine Secrets ausgeben |
| K3s/Kubernetes | planned/heavy | Home Server/VPS | high | nur mit Opt-in |
| Media/GPU | planned/gpu-heavy | RTX | high | nur Queue + GPU-Check |
| Mailserver | documentation-first | Oracle VPS | high | DNS/rDNS/PTR Pflicht |
