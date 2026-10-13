#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Load only the uninstall functions, without executing installers or dependencies.
eval "$(sed -n '/^validate_git_docker_uninstall_dir() {/,$p' "$repo_dir/scripts/tools/helpers/simple_tool_common.sh")"
log_info() { :; }
log_error() { :; }
log_success() { :; }
begin_measurement() { :; }
end_measurement() { result="$1"; }
mark_tool_removed() { marked=true; }
realpath() { printf '%s\n' "${!#}"; }
sudo() {
  [[ "$*" == "rm -rf --one-file-system -- $test_target" ]]
  sudo_called=true
  return "$sudo_result"
}
# Simulate an existing tool folder; no filesystem modifications are performed.
function [ {
  if [[ "$1" == '-e' && "$2" == "$test_target" ]]; then return 0; fi
  if [[ "$1" == '-f' && "$2" == "$test_target/docker-compose.yml" ]]; then return 1; fi
  if [[ "$1" == '-L' ]]; then return 1; fi
  builtin [ "$@"
}
test_target=/opt/metabase
for path in / /opt /opt/../home /opt/metabase/child /home/metabase; do
  if validate_git_docker_uninstall_dir "$path"; then
    echo "FAIL: accepted unsafe target $path"; exit 1
  fi
done
validate_git_docker_uninstall_dir /opt/metabase
sudo_result=0 sudo_called=false marked=false result=''
uninstall_git_docker_tool Metabase /opt/metabase
[[ "$sudo_called" == true && "$marked" == true && "$result" == success ]]
sudo_result=1 sudo_called=false marked=false result=''
if uninstall_git_docker_tool Metabase /opt/metabase; then
  echo 'FAIL: deletion failure accepted'; exit 1
fi
[[ "$sudo_called" == true && "$marked" == false && "$result" == failed ]]
for tool in Mosquitto Node_RED; do
  case "$tool" in Mosquitto) test_target=/opt/mosquitto ;; Node_RED) test_target=/opt/node_red ;; esac
  sudo_result=0 sudo_called=false marked=false result=''
  uninstall_git_docker_tool "$tool" "$test_target"
  [[ "$sudo_called" == true && "$marked" == true && "$result" == success ]]
done
echo 'PASS: unsafe paths rejected; sudo removal used; failures do not mark success.'
