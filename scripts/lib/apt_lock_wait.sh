#!/usr/bin/env bash

run_apt_with_lock_wait() {
    local wait_seconds="${APT_LOCK_WAIT_SECONDS:-300}"
    local started=$SECONDS remaining log_file apt_rc
    if ! [[ "$wait_seconds" =~ ^[0-9]{1,5}$ ]]; then
        echo 'Fehler: APT_LOCK_WAIT_SECONDS muss eine Zahl von 0 bis 99999 sein.' >&2
        return 2
    fi
    wait_seconds=$((10#$wait_seconds))
    log_file="$(mktemp)" || return 1
    echo "apt-Sperrenschutz: Warte bei laufender Paketverwaltung bis zu ${wait_seconds} Sekunden."
    while true; do
        remaining=$((wait_seconds - (SECONDS - started)))
        ((remaining >= 0)) || remaining=0
        if sudo env LC_ALL=C apt-get -o "DPkg::Lock::Timeout=$remaining" "$@" 2>&1 | tee "$log_file"; then
            apt_rc=${PIPESTATUS[0]}
        else
            apt_rc=${PIPESTATUS[0]}
        fi
        if [ "$apt_rc" -eq 0 ]; then
            rm -f -- "$log_file"
            return 0
        fi
        # apt update may ignore DPkg::Lock::Timeout; retry only lock failures.
        if ! grep -Eq 'Could not get lock|Unable to acquire.*lock|Unable to lock directory' "$log_file"; then
            rm -f -- "$log_file"
            return "$apt_rc"
        fi
        remaining=$((wait_seconds - (SECONDS - started)))
        if [ "$remaining" -le 0 ]; then
            echo 'Paketverwaltung bleibt gesperrt (z. B. unattended-upgrades). Installation spaeter erneut starten. Keine Sperrdateien loeschen oder Update-Prozesse beenden.' >&2
            rm -f -- "$log_file"
            return "$apt_rc"
        fi
        echo "Andere Paketverwaltung aktiv; erneuter Versuch in wenigen Sekunden (${remaining}s verbleiben)."
        if [ "$remaining" -gt 5 ]; then sleep 5; else sleep "$remaining"; fi
    done
}
