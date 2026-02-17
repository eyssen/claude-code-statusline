#!/bin/bash

# Claude Code Statusline - Minimal Example
# Shows only model name, cost, and context percentage
#
# Usage: Add to ~/.claude/settings.json:
# { "statusLine": { "command": "~/.claude/statusline-minimal.sh" } }

export LC_ALL=C

data=$(cat)

eval "$(echo "$data" | jq -r '
  @sh "model=\(.model.display_name // "?")",
  @sh "cost=\(.cost.total_cost_usd // 0)",
  @sh "ctx_pct=\(.context_window.used_percentage // 0)"
')"

cost_formatted=$(printf "\$%.2f" "$cost")

printf "🤖 %s │ %s │ %d%%" "$model" "$cost_formatted" "$ctx_pct"
