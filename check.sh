#!/usr/bin/env bash
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

healthcheck_url="${HEALTHCHECK_URL:-}"
final_healthcheck_url="${healthcheck_url//\{HOSTNAME\}/$HOSTNAME}"
sleep_time="${SLEEP_TIME:-3600}"

while true; do
  filesystems="$(df -hPT | grep -vE '^Filesystem|tmp|/dev/loop|overlay|aufs' | awk '{print $1 " " $6}' | sort | uniq)"

  errors=()

  while read -r fs usage_string; do
    if [ -z "$fs" ]; then break; fi

    usage_number=$(echo "$usage_string" | tr -d '%')

    if [ "$usage_number" -ge "$THRESHOLD" ]; then
      error="$(printf "%s usage is at %s\n" "$fs" "$usage_string")"
      errors+=("$error")
    fi
  done <<< "$filesystems"

  if [ ${#errors[@]} -eq 0 ]; then
    if [ -n "${final_healthcheck_url}" ]; then
      curl -fsS -m 10 --retry 5 -o /dev/null "$final_healthcheck_url"
    fi
  else
    hostname="$(hostname)"
    error_lines="$(printf '%s\n' "${errors[@]}")"
    msg=$(printf "Problems on %s:\n\n%s" "$hostname" "$error_lines")

    >&2 echo -e "$msg"

    if [ -n "${final_healthcheck_url}" ]; then
      curl -fsS -m 10 --retry 5 --data-raw "$msg" "$final_healthcheck_url/fail"
    fi
  fi

  >&2 echo "Sleeping ${sleep_time} seconds.."
  sleep "$sleep_time"
done
