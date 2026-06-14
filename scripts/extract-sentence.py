#!/usr/bin/env python3
"""stdin の Stop フック JSON からテキストを抽出し、読み上げ用の一文を stdout へ出力する。

出力形式: <session_id>\t<sentence>
引数: MAX_CHARS (省略時 200)
"""
import json, sys, re, os

max_chars = int(sys.argv[1]) if len(sys.argv) > 1 else int(os.environ.get('MAX_CHARS', '200'))

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

sid = data.get("session_id", "default") or "default"
last_text = data.get("last_assistant_message", "") or ""

if not last_text:
    path = data.get("transcript_path", "")
    if path:
        try:
            with open(path) as f:
                msgs = [json.loads(l) for l in f if l.strip()]
            for msg in reversed(msgs):
                if msg.get("type") == "assistant" and not msg.get("isSidechain"):
                    content = msg.get("message", {}).get("content", [])
                    parts = [b["text"] for b in content if isinstance(b, dict) and b.get("type") == "text"]
                    last_text = "\n".join(parts).strip()
                    break
        except Exception:
            pass

if not last_text:
    sys.exit(0)

text = re.sub(r'```[\s\S]*?```', '', last_text)
text = re.sub(r'`[^`]*`', '', text)
text = re.sub(r'\[([^\]]*)\]\([^)]+\)', r'\1', text)
text = re.sub(r'[_~#>]+', '', text)

for line in reversed(text.splitlines()):
    line = line.strip()
    if re.match(r'^result[:：]', line, re.IGNORECASE):
        sentence = re.sub(r'^result[:：]\s*', '', line, flags=re.IGNORECASE)
        print(f"{sid}\t{sentence[:max_chars]}")
        sys.exit(0)

sentences = re.findall(r'[^。！？!?]+[。！？!?]', text.replace('\n', ' '))
if sentences:
    print(f"{sid}\t{sentences[-1].strip()[:max_chars]}")
    sys.exit(0)

fallback = text.replace('\n', ' ').strip()[:max_chars]
if fallback:
    print(f"{sid}\t{fallback}")
