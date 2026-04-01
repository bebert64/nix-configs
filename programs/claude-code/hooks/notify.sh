#!/usr/bin/env bash
TITLE="Claude @ $(hostname)"
BODY="Answer ready on $(git branch --show-current 2>/dev/null || echo 'no branch')"
if [[ -n "$SSH_CLIENT" ]]; then
  ssh -p 2222 -o ConnectTimeout=3 -o BatchMode=yes localhost notify-send "$TITLE" "$BODY" || true
else
  notify-send "$TITLE" "$BODY"
fi
