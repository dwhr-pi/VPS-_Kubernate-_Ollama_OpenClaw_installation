#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  FIXTURE="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$FIXTURE/scripts/quality" "$FIXTURE/config" "$FIXTURE/docs"
  cp "$REPO_ROOT/scripts/check_ports.sh" "$FIXTURE/scripts/"
  cp "$REPO_ROOT/scripts/validate_config.sh" "$FIXTURE/scripts/"
  cp "$REPO_ROOT/scripts/quality/repository_audit.py" "$FIXTURE/scripts/quality/"
  printf 'fixture\n' > "$FIXTURE/install.sh"
  printf 'fixture\n' > "$FIXTURE/uninstall.sh"
  printf 'fixture\n' > "$FIXTURE/docs/tool.md"
  printf '%s\n' '{"tools":[{"id":"example","status":"planned","auto_install":false,"install_script":"install.sh","uninstall_script":"uninstall.sh","doc":"docs/tool.md","check_type":"path","check_value":"marker"}]}' > "$FIXTURE/config/tools.yml"
  printf '%s\n' '{"profiles":[{"id":"Example","status":"planned","doc":"docs/tool.md","tools":["example"]}]}' > "$FIXTURE/config/profiles.yml"
  printf '%s\n' '{"ports":[{"port":1234,"service":"fixture"}]}' > "$FIXTURE/config/ports.yml"
}

@test "both real scripts pass bash syntax parsing" {
  run bash -n "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -eq 0 ]
  run bash -n "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -eq 0 ]
}

@test "port registry accepts unique integer ports without opening sockets" {
  run bash "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"keine Doppelbelegung"* ]]
}

@test "duplicate ports fail" {
  printf '%s\n' '{"ports":[{"port":1234},{"port":1234}]}' > "$FIXTURE/config/ports.yml"
  run bash "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *DOPPELT* ]]
}

@test "boolean ports fail instead of being accepted as integers" {
  printf '%s\n' '{"ports":[{"port":true}]}' > "$FIXTURE/config/ports.yml"
  run bash "$FIXTURE/scripts/check_ports.sh"
  [ "$status" -ne 0 ]
}

@test "configuration validation includes the real semantic repository audit" {
  run bash "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -eq 0 ]
}

@test "invalid JSON stops configuration validation" {
  printf 'not-json\n' > "$FIXTURE/config/tools.yml"
  run bash "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *FEHLER* ]]
}

@test "unknown profile tool fails semantic configuration validation" {
  printf '%s\n' '{"profiles":[{"id":"Example","status":"planned","doc":"docs/tool.md","tools":["absent"]}]}' > "$FIXTURE/config/profiles.yml"
  run bash "$FIXTURE/scripts/validate_config.sh"
  [ "$status" -ne 0 ]
}
