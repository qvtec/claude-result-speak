#!/bin/bash
[[ "${CLAUDE_RESULT_SPEAK_NOTIFY_ENABLED:-true}" == "false" ]] && exit 0

TYPE="${1:-complete}"
LANG="${CLAUDE_RESULT_SPEAK_LANGUAGE:-en}"

case "$LANG" in
  en) DEFAULT_COMPLETE="Done!"; DEFAULT_PERMISSION="Waiting for permission..."; DEFAULT_IDLE="Waiting for input..." ;;
  *)  DEFAULT_COMPLETE="できたよ！"; DEFAULT_PERMISSION="権限確認待ち..."; DEFAULT_IDLE="入力待ち..." ;;
esac

case "$TYPE" in
  complete)
    EMOJI="${CLAUDE_RESULT_SPEAK_EMOJI_COMPLETE:-✨}"
    MSG="${CLAUDE_RESULT_SPEAK_MESSAGE_COMPLETE:-}"
    SOUND="${CLAUDE_RESULT_SPEAK_SOUND_COMPLETE:-Blow}"
    WIN_SOUND="[System.Media.SystemSounds]::Asterisk.Play()"
    [[ -z "$MSG" ]] && MSG="$DEFAULT_COMPLETE"
    ;;
  permission)
    EMOJI="${CLAUDE_RESULT_SPEAK_EMOJI_PERMISSION:-⚠️}"
    MSG="${CLAUDE_RESULT_SPEAK_MESSAGE_PERMISSION:-}"
    SOUND="${CLAUDE_RESULT_SPEAK_SOUND_PERMISSION:-Pop}"
    WIN_SOUND="[System.Media.SystemSounds]::Exclamation.Play()"
    [[ -z "$MSG" ]] && MSG="$DEFAULT_PERMISSION"
    ;;
  idle)
    EMOJI="${CLAUDE_RESULT_SPEAK_EMOJI_IDLE:-💬}"
    MSG="${CLAUDE_RESULT_SPEAK_MESSAGE_IDLE:-}"
    SOUND="${CLAUDE_RESULT_SPEAK_SOUND_IDLE:-Tink}"
    WIN_SOUND="[System.Media.SystemSounds]::Beep.Play()"
    [[ -z "$MSG" ]] && MSG="$DEFAULT_IDLE"
    ;;
  *) exit 0 ;;
esac

FULL_MSG="${EMOJI} ${MSG}"

if [[ "$OSTYPE" == "darwin"* ]]; then
  ESCAPED=$(printf '%s' "$FULL_MSG" | sed 's/"/\\"/g')
  osascript -e "display notification \"${ESCAPED}\" with title \"Claude Code\" sound name \"${SOUND}\""
elif grep -qi microsoft /proc/version 2>/dev/null; then
  ESCAPED=$(printf '%s' "$FULL_MSG" | sed "s/'/\`'/g")
  powershell.exe -NoProfile -NonInteractive -Command "
    Add-Type -AssemblyName System.Windows.Forms;
    Add-Type -AssemblyName System.Drawing;
    ${WIN_SOUND};
    \$n = New-Object System.Windows.Forms.NotifyIcon;
    \$n.Icon = [System.Drawing.SystemIcons]::Information;
    \$n.BalloonTipTitle = 'Claude Code';
    \$n.BalloonTipText = '${ESCAPED}';
    \$n.BalloonTipIcon = 'Info';
    \$n.Visible = \$true;
    \$n.ShowBalloonTip(5000);
    Start-Sleep -Milliseconds 1000;
    \$n.Dispose()
  " >/dev/null 2>&1 &
fi
