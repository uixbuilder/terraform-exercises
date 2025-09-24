#!/bin/bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-/var/log/sample/app.log}"
LOG_INTERVAL_SEC="${LOG_INTERVAL_SEC:-5}"
# Space-separated levels (can be overridden via env)
LOG_LEVELS_DEFAULT=("INFO" "DEBUG" "ERROR")
read -ra LOG_LEVELS <<< "${LOG_LEVELS:-${LOG_LEVELS_DEFAULT[*]}}"

mkdir -p "$(dirname "$LOG_FILE")"

# Flush on SIGTERM/SIGINT for graceful shutdown
_term() { echo "Shutting down logger..." >&2; exit 0; }
trap _term SIGTERM SIGINT

echo "Writing logs to: $LOG_FILE"
echo "Interval: ${LOG_INTERVAL_SEC}s"
echo "Levels: ${LOG_LEVELS[*]}"

while true; do
  # Pick random level
  level="${LOG_LEVELS[$((RANDOM % ${#LOG_LEVELS[@]}))]}"

  # ISO 8601 timestamp (UTC)
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  # Unique id from kernel uuid source (fallback to random if unavailable)
  if [[ -r /proc/sys/kernel/random/uuid ]]; then
    id="$(cat /proc/sys/kernel/random/uuid)"
  else
    id="$(printf "%08x-%04x-%04x-%04x-%012x" $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM)"
  fi

  # Optional simple message per level
  case "$level" in
    INFO)  msg="Heartbeat OK";;
    DEBUG) msg="Detailed diagnostic sample";;
    ERROR) msg="Something went wrong (sample)";;
    *)     msg="Sample event";;
  esac

  # Write JSON line (with optional namespace + annotations)
  if [[ -n "${K8S_NAMESPACE:-}" ]]; then
    annotations_json=""

    # Collect annotations from env vars prefixed with K8S_ANNOTATIONS_
    for var in $(compgen -e | grep '^K8S_ANNOTATIONS_'); do
      key="${var#K8S_ANNOTATIONS_}"
      # Normalize key to avoid invalid characters in Fluentd (replace / with _)
      key_norm=$(echo "$key" | sed 's|/|_|g')
      value="${!var}"
      # Escape quotes if needed
      value_esc=$(printf '%s' "$value" | sed 's/"/\\"/g')
      if [[ -n "$annotations_json" ]]; then
        annotations_json="$annotations_json,\"$key_norm\":\"$value_esc\""
      else
        annotations_json="\"$key\":\"$value_esc\""
      fi
    done

    if [[ -n "$annotations_json" ]]; then
      printf '{"timestamp":"%s","level":"%s","id":"%s","message":"%s","kubernetes":{"namespace_name":"%s","annotations":{%s}}}\n' \
        "$ts" "$level" "$id" "$msg" "$K8S_NAMESPACE" "$annotations_json" >> "$LOG_FILE"
    else
      printf '{"timestamp":"%s","level":"%s","id":"%s","message":"%s","kubernetes":{"namespace_name":"%s"}}\n' \
        "$ts" "$level" "$id" "$msg" "$K8S_NAMESPACE" >> "$LOG_FILE"
    fi
  else
    printf '{"timestamp":"%s","level":"%s","id":"%s","message":"%s"}\n' \
      "$ts" "$level" "$id" "$msg" >> "$LOG_FILE"
  fi

  sleep "$LOG_INTERVAL_SEC"
done
