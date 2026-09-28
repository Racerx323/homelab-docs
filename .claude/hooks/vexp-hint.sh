#!/bin/bash
# vexp-hint: event-driven orientation hint (UserPromptSubmit). Fails open.
VEXP_BIN="/home/aaron/.nvm/versions/node/v26.4.0/lib/node_modules/vexp-cli/node_modules/@vexp/core-linux-x64/bin/vexp-core"
[ -x "$VEXP_BIN" ] || exit 0
VEXP_HOOK_AGENT="claude-code" "$VEXP_BIN" prompt-hint 2>/dev/null
exit 0
