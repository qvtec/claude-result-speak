#!/bin/bash
set -u

[[ "${CLAUDE_RESULT_SPEAK_TTS_ENABLED:-true}" == "false" ]] && exit 0

VOICE="${CLAUDE_RESULT_SPEAK_VOICE_WINDOWS:-}"
RATE="${CLAUDE_RESULT_SPEAK_RATE_WINDOWS:-3}"
MAX_CHARS="${CLAUDE_RESULT_SPEAK_MAX_CHARS:-200}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

input=$(cat)
result=$(echo "$input" | python3 "$SCRIPT_DIR/extract-sentence.py" "$MAX_CHARS")
[ -z "$result" ] && exit 0

sid=$(echo "$result" | cut -f1)
short=$(echo "$result" | cut -f2-)
[ -z "$short" ] && exit 0

safe=$(printf '%s' "$short" | sed "s/'/''/g")
voice_cmd=""
[ -n "$VOICE" ] && voice_cmd="try { \$s.SelectVoice('$(printf '%s' "$VOICE" | sed "s/'/''/g")') } catch {}"

powershell.exe -NoProfile -NonInteractive -Command "
  Add-Type -AssemblyName System.Speech;
  \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer;
  $voice_cmd
  \$s.Rate = $RATE;
  \$s.Speak('$safe')
" >/dev/null 2>&1
