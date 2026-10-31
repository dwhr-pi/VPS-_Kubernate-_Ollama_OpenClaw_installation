#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/whisper_cpp_uninstall.sh"
begin_measurement() { measured=true; }
end_measurement() { result="$1"; }
log_warn() { :; }
log_error() { :; }
log_success() { :; }
mark_tool_removed() {
  [[ "$1" == Whisper_CPP ]]
  marked=true
}
realpath() { echo "$resolved_target"; }
sudo() {
  called=true
  [[ "$*" == 'rm -rf --one-file-system -- /opt/whisper_cpp' ]] || return 99
  return "$delete_result"
}
function [ {
  if [[ "$1" == -L && "$2" == /opt/whisper_cpp ]]; then return "$symlink_result"; fi
  if [[ "$1" == -e && "$2" == /opt/whisper_cpp ]]; then return "$exists_result"; fi
  builtin [ "$@"
}
resolved_target=/opt/whisper_cpp delete_result=0 symlink_result=1 exists_result=1
called=false marked=false measured=false result=''
uninstall_whisper_cpp --dry-run >/dev/null
[[ "$called" == false && "$marked" == false && "$measured" == false ]]
uninstall_whisper_cpp
[[ "$called" == true && "$marked" == true && "$result" == success ]]
delete_result=1 marked=false result=''
if uninstall_whisper_cpp; then exit 1; fi
[[ "$marked" == false && "$result" == failed ]]
delete_result=0 exists_result=0 marked=false
if uninstall_whisper_cpp; then exit 1; fi
[[ "$marked" == false && "$result" == failed ]]
exists_result=1 resolved_target=/home/other called=false
if uninstall_whisper_cpp; then exit 1; fi
[[ "$called" == false ]]
resolved_target=/opt/whisper_cpp symlink_result=0
if uninstall_whisper_cpp; then exit 1; fi
[[ "$called" == false ]]
echo 'PASS: sudo, dry-run, unsafe targets, deletion failure and residual directory checks.'
