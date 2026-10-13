#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/mosquitto_install.sh"
unset MOSQUITTO_HOST_PORT
compose="$(mosquitto_main --dry-run)"
[[ "$compose" == *'127.0.0.1:1883:1883'* && "$compose" != *9001* ]]
MOSQUITTO_HOST_PORT=1884
[[ "$(mosquitto_compose)" == *'127.0.0.1:1884:1883'* ]]
for MOSQUITTO_HOST_PORT in 0 65536 bad '1883:9001'; do
    if mosquitto_compose >/dev/null 2>&1; then exit 1; fi
done
unset MOSQUITTO_HOST_PORT
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
id() { printf '%s\n' testuser; }
sudo() {
    case "$1" in mkdir) shift; command mkdir "$@" ;; chown) return 0 ;; *) return 99 ;; esac
}
mosquitto_prepare_config "$temp_dir"
grep -Fxq 'allow_anonymous false' "$temp_dir/config/mosquitto.conf"
printf 'existing configuration\n' > "$temp_dir/config/mosquitto.conf"
mosquitto_prepare_config "$temp_dir"
[[ "$(< "$temp_dir/config/mosquitto.conf")" == 'existing configuration' ]]
mosquitto_prepare_config() { return 0; }
install_git_docker_tool() {
    [[ "$1" == Mosquitto && "$4" != *9001* ]]
    return 17
}
if mosquitto_main >/dev/null; then exit 1; else [[ "$?" -eq 17 ]]; fi
echo 'PASS: no websocket publication, localhost MQTT, port validation, config preservation and failure propagation.'
