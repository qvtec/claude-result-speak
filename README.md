# claude-result-speak

[日本語](README.ja.md)

Claude Code plugin that reads the last sentence of Claude's response aloud and sends desktop notifications.

![demo](demo.png)

## Features

- **TTS** — speaks the last sentence of each response
- **Desktop notifications** — notifies on response complete, permission prompt, and idle
- **`result:` summary** — Claude appends a one-line summary to every response; the plugin reads it aloud
- **Cross-platform** — macOS and Windows (WSL2)

## Requirements

| Platform | Requirements |
|----------|-------------|
| macOS | Python 3, built-in `say` command |
| WSL2 | Python 3, `powershell.exe` (built-in) |

## Installation

```bash
claude plugin marketplace add https://github.com/qvtec/claude-result-speak.git
claude plugin install claude-result-speak@claude-result-speak
```

Then enable the plugin:

```bash
# All projects (recommended)
claude plugin enable --scope user claude-result-speak@claude-result-speak

# Current project only
claude plugin enable --scope project claude-result-speak@claude-result-speak
```

## How it works

The included `CLAUDE.md` instructs Claude to end every response with:

```
result: <one-line summary>
```

The `Stop` hook fires when Claude finishes responding and reads that line aloud via TTS.

## Platform support

| Feature | macOS | Windows (WSL2) |
|---------|-------|----------------|
| TTS | `say -v Kyoko -r 250` | PowerShell SpeechSynthesizer |
| Notification | `osascript` | PowerShell balloon tip |
| Complete sound | Blow | Asterisk |
| Permission sound | Pop | Exclamation |
| Idle sound | Tink | Beep |

## Configuration

Add an `env` block to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_RESULT_SPEAK_LANGUAGE": "ja",
    "CLAUDE_RESULT_SPEAK_TTS_ENABLED": "false"
  }
}
```

| Environment variable | Type | Default | Description |
|---------------------|------|---------|-------------|
| `CLAUDE_RESULT_SPEAK_TTS_ENABLED` | boolean | `true` | Enable/disable TTS |
| `CLAUDE_RESULT_SPEAK_NOTIFY_ENABLED` | boolean | `true` | Enable/disable desktop notifications |
| `CLAUDE_RESULT_SPEAK_LANGUAGE` | string | `en` | Notification language (`ja` / `en`) |
| `CLAUDE_RESULT_SPEAK_MESSAGE_COMPLETE` | string | _(language default)_ | Completion message override |
| `CLAUDE_RESULT_SPEAK_MESSAGE_PERMISSION` | string | _(language default)_ | Permission prompt message override |
| `CLAUDE_RESULT_SPEAK_MESSAGE_IDLE` | string | _(language default)_ | Idle message override |
| `CLAUDE_RESULT_SPEAK_VOICE_MAC` | string | `Kyoko` | macOS voice name (e.g. `Alex`, `Samantha`) |
| `CLAUDE_RESULT_SPEAK_VOICE_WINDOWS` | string | _(system default)_ | Windows (WSL2) voice name (e.g. `Microsoft Haruka Desktop`) |
| `CLAUDE_RESULT_SPEAK_RATE_MAC` | number | `250` | macOS TTS speed in WPM (50–500) |
| `CLAUDE_RESULT_SPEAK_RATE_WINDOWS` | number | `3` | Windows (WSL2) TTS rate (-10–10) |
| `CLAUDE_RESULT_SPEAK_MAX_CHARS` | number | `200` | Max characters to read aloud (50–500) |
| `CLAUDE_RESULT_SPEAK_SOUND_COMPLETE` | string | `Blow` | macOS notification sound for completion |
| `CLAUDE_RESULT_SPEAK_SOUND_PERMISSION` | string | `Pop` | macOS notification sound for permission prompt |
| `CLAUDE_RESULT_SPEAK_SOUND_IDLE` | string | `Tink` | macOS notification sound for idle |
| `CLAUDE_RESULT_SPEAK_EMOJI_COMPLETE` | string | `✨` | Emoji for completion notification |
| `CLAUDE_RESULT_SPEAK_EMOJI_PERMISSION` | string | `⚠️` | Emoji for permission prompt notification |
| `CLAUDE_RESULT_SPEAK_EMOJI_IDLE` | string | `💬` | Emoji for idle notification |

Available macOS sounds: `Basso` `Blow` `Bottle` `Frog` `Funk` `Glass` `Hero` `Morse` `Ping` `Pop` `Purr` `Sosumi` `Submarine` `Tink`

## Related plugins

### [claude-result-speak-pet](https://github.com/qvtec/claude-result-speak-pet)

A visual companion plugin that delivers notifications via an animated desktop pet (cat) in the bottom-right corner.  
Pair it with this plugin to get both TTS and a pet popup at the same time.

To avoid duplicate notifications, disable the balloon tip from this plugin:

```json
{
  "env": {
    "CLAUDE_RESULT_SPEAK_NOTIFY_ENABLED": "false"
  }
}
```

## License

MIT
