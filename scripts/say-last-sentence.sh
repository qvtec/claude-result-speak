#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
  exec "$SCRIPT_DIR/say-last-sentence-mac.sh"
elif grep -qi microsoft /proc/version 2>/dev/null; then
  exec "$SCRIPT_DIR/say-last-sentence-windows.sh"
fi
