#!/usr/bin/env bats

setup() {
  watchdog="$BATS_TEST_DIRNAME/../../scripts/healthcheck-watchdog.sh"
  export FIXTURE_HTTP=200 FIXTURE_EXIT=0
  export FIXTURE_ARGS="$BATS_TEST_TMPDIR/curl-args"
  curl() {
    printf '%s\n' "$@" > "$FIXTURE_ARGS"
    printf '%s' "$FIXTURE_HTTP"
    return "$FIXTURE_EXIT"
  }
  export -f curl
}

@test "default probe is read-only, bounded and never uses a proxy" {
  run bash "$watchdog"
  [ "$status" -eq 0 ]
  grep -Fx -- 'http://127.0.0.1:18789/readyz' "$FIXTURE_ARGS"
  grep -Fx -- '--noproxy' "$FIXTURE_ARGS"
  grep -Fx -- '--max-time' "$FIXTURE_ARGS"
  ! grep -Fx -- '--json' "$FIXTURE_ARGS"
}

@test "redirects, unavailable gateways and transport errors fail" {
  for FIXTURE_HTTP in 202 302 503; do
    run bash "$watchdog" gateway
    [ "$status" -eq 1 ]
  done
  FIXTURE_HTTP=200 FIXTURE_EXIT=28 run bash "$watchdog" gateway
  [ "$status" -eq 1 ]
}

@test "warmup and pull are separate explicit Ollama operations" {
  run bash "$watchdog" warmup qwen3-coder
  [ "$status" -eq 0 ]
  grep -Fx -- 'http://127.0.0.1:11434/api/generate' "$FIXTURE_ARGS"
  grep -Fx -- '{"model":"qwen3-coder","stream":false,"keep_alive":"10m"}' "$FIXTURE_ARGS"
  run bash "$watchdog" pull qwen3-coder
  [ "$status" -eq 0 ]
  grep -Fx -- 'http://127.0.0.1:11434/api/pull' "$FIXTURE_ARGS"
}

@test "invalid model and unexpected arguments do not reach curl" {
  run bash "$watchdog" warmup 'bad"model'
  [ "$status" -eq 2 ]
  run bash "$watchdog" gateway extra
  [ "$status" -eq 2 ]
  [ ! -e "$FIXTURE_ARGS" ]
}
