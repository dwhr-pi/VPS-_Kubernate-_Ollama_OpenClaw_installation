#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
eval "$(sed -n '/^uninstall_kubectx_kubens() {/,$p' "$repo_dir/scripts/tools/kubectx_kubens_uninstall.sh" | sed '$d')"
begin_measurement() { :; }
end_measurement() { result="$1"; }
log_error() { :; }
mark_tool_removed() { marked=true; }
realpath() { echo "$resolved_target"; }
sudo() {
  called=true
  case "$*" in
    'rm -f -- /usr/local/bin/kubectx /usr/local/bin/kubens') return 0 ;;
    'rm -rf --one-file-system -- /opt/kubectx') return "$delete_result" ;;
    *) return 99 ;;
  esac
}
function [ {
  if [[ "$1" == -L ]]; then return 1; fi
  builtin [ "$@"
}
resolved_target=/opt/kubectx delete_result=0 called=false marked=false result=''
uninstall_kubectx_kubens
[[ "$called" == true && "$marked" == true && "$result" == success ]]
delete_result=1 marked=false result=''
if uninstall_kubectx_kubens; then
  echo 'FAIL: deletion failure accepted'
  exit 1
fi
[[ "$marked" == false && "$result" == failed ]]
resolved_target=/home/other called=false marked=false
if uninstall_kubectx_kubens; then
  echo 'FAIL: unsafe target accepted'
  exit 1
fi
[[ "$called" == false && "$marked" == false ]]
echo 'PASS: sudo removal, failure status and target validation checked.'
