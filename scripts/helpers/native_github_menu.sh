#!/usr/bin/env bash
# Shared menu/status allowlist for native migration tools; no installer execution.
NATIVE_GITHUB_TOOL_KEYS=("Airbyte" "Apache_Tika" "Appsmith" "ArchiveBox" "Argilla" "Budibase" "Caddy" "cAdvisor" "Changedetection_IO" "CrowdSec" "Directus" "Forgejo" "Grafana" "Grafana_Alloy" "Healthchecks" "Home_Assistant" "Langfuse" "LiteLLM" "Loki" "Meilisearch" "Metabase" "MinIO" "Mosquitto" "Neo4j" "Netdata" "Nextcloud" "NocoDB" "Node_Exporter" "Node_Red" "Open_WebUI" "Penpot" "Prometheus" "Promtail" "Qdrant" "Rhasspy" "SearXNG" "Stirling_PDF" "Uptime_Kuma" "Vault" "Vikunja" "Watchtower" "Weaviate" "Zigbee2MQTT" "PyAirbyte")

# Include newly discovered paths in the same native status dispatch.
NATIVE_GITHUB_TOOL_KEYS+=("OpenTelemetry" "AutoGPT" "Supabase")
NATIVE_GITHUB_TOOL_KEYS+=("Kubeseal")

register_native_github_tool_keys() {
    local key
    local -A seen=()
    for key in "${TOOL_KEYS[@]}"; do seen["$key"]=1; done
    for key in "${NATIVE_GITHUB_TOOL_KEYS[@]}"; do
        if [[ -z "${seen[$key]:-}" ]]; then
            TOOL_KEYS+=("$key")
            seen["$key"]=1
        fi
    done
}
