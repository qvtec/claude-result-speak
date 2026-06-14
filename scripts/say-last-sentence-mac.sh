#!/bin/bash
set -u

[[ "${CLAUDE_RESULT_SPEAK_TTS_ENABLED:-true}" == "false" ]] && exit 0

VOICE="${CLAUDE_RESULT_SPEAK_VOICE_MAC:-Kyoko}"
RATE="${CLAUDE_RESULT_SPEAK_RATE_MAC:-250}"
MAX_CHARS="${CLAUDE_RESULT_SPEAK_MAX_CHARS:-200}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

input=$(cat)
result=$(echo "$input" | python3 "$SCRIPT_DIR/extract-sentence.py" "$MAX_CHARS")
[ -z "$result" ] && exit 0

sid=$(echo "$result" | cut -f1)
short=$(echo "$result" | cut -f2-)
[ -z "$short" ] && exit 0

pidfile="/tmp/cc-say-${sid}.pid"
if [ -f "$pidfile" ]; then
  oldpid=$(cat "$pidfile" 2>/dev/null)
  [ -n "$oldpid" ] && kill "$oldpid" 2>/dev/null || true
fi

say -v "$VOICE" -r "$RATE" "$short" >/dev/null 2>&1 &
echo $! > "$pidfile"
