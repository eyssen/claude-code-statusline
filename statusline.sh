#!/bin/bash

# Claude Code Statusline - Informative status bar for Claude Code CLI
# https://github.com/kalmarr-dev/claude-code-statusline
#
# Shows: Model, Cost, Context Window, Duration, API Calls, Fast Mode,
#        Lines Changed, Git Branch, Project Folder

# Force C locale for consistent number formatting
export LC_ALL=C

data=$(cat)

# Optional debug: set DEBUG=1 to save raw JSON input
# Usage: DEBUG=1 claude
[ "${DEBUG:-0}" = "1" ] && echo "$data" > ~/.claude/debug_status.json

# === EXTRACT ALL DATA IN ONE JQ CALL ===
eval "$(echo "$data" | jq -r '
  @sh "model=\(.model.display_name // "?")",
  @sh "cost=\(.cost.total_cost_usd // 0)",
  @sh "duration_ms=\(.cost.total_duration_ms // 0)",
  @sh "lines_added=\(.cost.total_lines_added // 0)",
  @sh "lines_removed=\(.cost.total_lines_removed // 0)",
  @sh "ctx_pct=\(.context_window.used_percentage // 0)",
  @sh "ctx_size=\(.context_window.context_window_size // 200000)",
  @sh "cwd=\(.workspace.current_dir // "")",
  @sh "transcript=\(.transcript_path // "")"
')"

# === PROJECT FOLDER ===
project_dir=$(basename "$cwd" 2>/dev/null)

# === COST FORMAT ===
cost_formatted=$(printf "\$%.2f" "$cost")

# === CONTEXT WINDOW ===
ctx_pct=${ctx_pct:-0}
ctx_size=${ctx_size:-200000}

# Cap percentage at 100
[ "$ctx_pct" -gt 100 ] && ctx_pct=100

# Colored progress bar (20 chars)
bar_len=20
filled=$((ctx_pct * bar_len / 100))
empty=$((bar_len - filled))

if [ "$ctx_pct" -lt 50 ]; then
    color="\033[32m"  # Green
elif [ "$ctx_pct" -lt 75 ]; then
    color="\033[33m"  # Yellow
else
    color="\033[31m"  # Red
fi

bar="${color}["
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done
bar+="]\033[0m"

# Format token counts as Xk (derive current usage from percentage, not cumulative totals)
ctx_used=$((ctx_pct * ctx_size / 100))
ctx_used_k=$((ctx_used / 1000))
ctx_size_k=$((ctx_size / 1000))
tokens_info=$(printf "%b %d%% (%dk/%dk)" "$bar" "$ctx_pct" "$ctx_used_k" "$ctx_size_k")

# === SESSION DURATION ===
duration_ms=${duration_ms:-0}
total_secs=$((duration_ms / 1000))
if [ "$total_secs" -ge 3600 ]; then
    hours=$((total_secs / 3600))
    mins=$(( (total_secs % 3600) / 60 ))
    duration_str="⏱ ${hours}h${mins}m"
elif [ "$total_secs" -ge 60 ]; then
    mins=$((total_secs / 60))
    secs=$((total_secs % 60))
    duration_str="⏱ ${mins}m${secs}s"
else
    duration_str="⏱ ${total_secs}s"
fi

# === TRANSCRIPT DATA (API calls + Fast mode) ===
api_info=""
speed_info=""
if [ -f "$transcript" ]; then
    api_count=$(grep -c '"type":"assistant"' "$transcript" 2>/dev/null)
    api_count=${api_count:-0}
    [ "$api_count" -gt 0 ] && api_info="📡 ${api_count}"

    # Fast mode: check /fast toggle event (primary), speed field (fallback)
    fast_toggle=$(tac "$transcript" | grep -m1 -oP 'Fast mode \K(ON|OFF)' 2>/dev/null)
    if [ "$fast_toggle" = "ON" ]; then
        speed_info="\033[33m⚡FAST\033[0m"
    elif [ "$fast_toggle" = "OFF" ]; then
        speed_info="\033[90mSTD\033[0m"
    else
        # No toggle found → fallback to API speed field
        speed_mode=$(tac "$transcript" | grep -m1 -oP '"speed"\s*:\s*"\K[^"]*' 2>/dev/null)
        if [ "$speed_mode" = "fast" ]; then
            speed_info="\033[33m⚡FAST\033[0m"
        else
            speed_info="\033[90mSTD\033[0m"
        fi
    fi
fi

# === LINES ADDED/REMOVED ===
lines_added=${lines_added:-0}
lines_removed=${lines_removed:-0}
if [ "$lines_added" -eq 0 ] && [ "$lines_removed" -eq 0 ]; then
    lines_info="±0"
else
    lines_info="\033[32m+${lines_added}\033[0m/\033[31m-${lines_removed}\033[0m"
fi

# === GIT BRANCH ===
git_info=""
if [ -n "$cwd" ] && { [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; }; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        dirty=""
        [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ] && dirty="*"
        git_info="${branch}${dirty}"
    fi
fi

# === OUTPUT ===
output="🤖 ${model}"

# Append fast mode indicator right after model name
[ -n "$speed_info" ] && output="${output} ${speed_info}"

output="${output} │ ${cost_formatted} │ ${tokens_info} │ ${duration_str}"

[ -n "$api_info" ] && output="${output} │ ${api_info}"

output="${output} │ ${lines_info} │ 🌿 ${git_info} │ 📁 ${project_dir}"

printf "%b" "$output"
