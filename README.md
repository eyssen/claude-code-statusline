# Claude Code Statusline

A customizable, informative status bar for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI.

*Magyar verzio lentebb / Hungarian version below*

```
🤖 Opus 4.6 ⚡FAST │ $0.51 │ [████░░░░░░░░░░░░░░░░] 24% (22k/200k) │ ⏱ 6m51s │ 📡 5 │ +12/-3 │ 🌿 main │ 📁 my-project
```

## What it shows

| Indicator | Description |
|-----------|-------------|
| 🤖 Model | Current model (Opus 4.6, Sonnet 4.5, etc.) |
| ⚡FAST | Fast mode indicator (only shown when active) |
| $X.XX | Session cost (API users: actual cost, Pro/Max: $0.00) |
| [████░░] X% | Context window usage with color-coded progress bar |
| (Xk/200k) | Token usage (used/total) |
| ⏱ Xm | Session duration |
| 📡 N | Number of API calls in this session |
| +X/-Y | Lines added/removed |
| 🌿 branch | Current git branch (* = uncommitted changes) |
| 📁 folder | Current project folder |

### Context window colors

- 🟢 Green: < 50% used
- 🟡 Yellow: 50-75% used
- 🔴 Red: > 75% used

## Requirements

- **bash** 4.0+
- **jq** (JSON processor)
- **git** (optional, for branch info)
- **Claude Code** CLI

## Installation

### One-liner install

```bash
git clone https://github.com/kalmarr/claude-code-statusline.git /tmp/claude-code-statusline && /tmp/claude-code-statusline/install.sh && rm -rf /tmp/claude-code-statusline
```

### Install via Claude Code prompt

Paste this into Claude Code and it will install the statusline for you:

> Install the Claude Code statusline from https://github.com/kalmarr/claude-code-statusline — clone to /tmp, run install.sh, then clean up. Restart Claude Code when done.

### Claude Code slash command

For repeated use, copy `commands/install-statusline.md` to `~/.claude/commands/`, then run `/install-statusline` inside Claude Code anytime.

### Quick install

```bash
git clone https://github.com/kalmarr-dev/claude-code-statusline.git
cd claude-code-statusline
./install.sh
```

### Manual install

1. Copy the script:
```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

2. Add to your Claude Code settings (`~/.claude/settings.json`):
```json
{
  "statusLine": {
    "command": "~/.claude/statusline.sh"
  }
}
```

3. Restart Claude Code.

## Configuration

The statusline is configured via `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "command": "~/.claude/statusline.sh"
  }
}
```

### Debug mode

To debug the statusline input data, start Claude Code with:

```bash
DEBUG=1 claude
```

This saves the raw JSON input to `~/.claude/debug_status.json` on every update.

## Features

### Fast mode indicator

When you toggle `/fast` in Claude Code, the statusline shows `⚡FAST` in yellow next to the model name. This works by reading the transcript file for the last `"speed"` field value.

### Context window progress bar

A 20-character wide progress bar that changes color based on usage:
- Green when under 50%
- Yellow between 50-75%
- Red above 75%

### Git integration

Shows the current branch name and a `*` suffix when there are uncommitted changes. Works with any git repository in the current working directory.

### Lines changed

Tracks total lines added and removed during the session. Shows `±0` when no changes have been made.

## Customization

You can modify `statusline.sh` to change:

- **Progress bar width**: Change `bar_len=20` (line ~51)
- **Color thresholds**: Adjust the percentage checks in the context window section
- **Output format**: Modify the output assembly section at the bottom
- **Remove sections**: Comment out or delete any section you don't need

See `examples/minimal.sh` for a stripped-down version showing only model, cost, and context percentage.

## How it works

Claude Code pipes a JSON object to the statusline command's stdin on every update. The JSON contains:

- `model.display_name` - Current model name
- `cost.total_cost_usd` - Session cost
- `cost.total_duration_ms` - Session duration
- `cost.total_lines_added` / `cost.total_lines_removed` - Code changes
- `context_window.used_percentage` - Context usage percentage
- `context_window.context_window_size` - Max context tokens
- `context_window.total_input_tokens` / `total_output_tokens` - Token counts
- `workspace.current_dir` - Current working directory
- `transcript_path` - Path to session transcript (JSONL file)

The script extracts all fields in a single `jq` call, then assembles the output string with ANSI color codes.

## Icons & Logic

| Icon | Meaning | Source / Logic |
|------|---------|---------------|
| 🤖 | Model name | `model.display_name` from Claude Code JSON input |
| ⚡FAST | Fast mode active (yellow) | Reads transcript JSONL: first checks for `Fast mode ON/OFF` toggle, falls back to `"speed":"fast"` field |
| STD | Standard speed (gray) | Same as above, shown when not in fast mode |
| $X.XX | Session cost | `cost.total_cost_usd` — actual API cost (Pro/Max users see $0.00) |
| [████░░] X% | Context window usage | `context_window.used_percentage` — 20-char progress bar, color-coded: 🟢 <50%, 🟡 50-75%, 🔴 >75% |
| (Xk/Xk) | Tokens used/total | `total_input_tokens + total_output_tokens` / `context_window_size` |
| ⏱ | Session duration | `cost.total_duration_ms` — auto-formats: Xs, XmXs, or XhXm |
| 📡 N | API call count | Counts `"type":"assistant"` entries in transcript JSONL |
| +X/-Y | Lines changed | `cost.total_lines_added` / `cost.total_lines_removed` — green/red colored |
| 🌿 | Git branch | `git branch --show-current` in workspace dir, `*` suffix = uncommitted changes |
| 📁 | Project folder | `basename` of `workspace.current_dir` |
| │ | Separator | Visual divider between sections |

## Troubleshooting

### Statusline not appearing
- Verify `~/.claude/settings.json` has the `statusLine` config
- Check that `~/.claude/statusline.sh` exists and is executable (`chmod +x`)
- Restart Claude Code after making changes

### Shows "?" for model name
- This is normal during the initial loading phase
- If it persists, run `DEBUG=1 claude` and check `~/.claude/debug_status.json`

### jq errors
- Ensure `jq` is installed: `which jq`
- Install via: `apt install jq` / `brew install jq` / `pacman -S jq`

### Git branch not showing
- The current directory must be inside a git repository
- Ensure `git` is installed and in PATH

### Fast mode not detected
- Toggle `/fast` and send at least one message
- The speed field appears in the transcript after the first API response in that mode

## License

MIT - see [LICENSE](LICENSE)

---

# Claude Code Statusline (Magyar)

Testreszabhato, informativ status bar a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI-hez.

```
🤖 Opus 4.6 ⚡FAST │ $0.51 │ [████░░░░░░░░░░░░░░░░] 24% (22k/200k) │ ⏱ 6m51s │ 📡 5 │ +12/-3 │ 🌿 main │ 📁 my-project
```

## Mit mutat

| Jelzo | Leiras |
|-------|--------|
| 🤖 Model | Aktualis modell (Opus 4.6, Sonnet 4.5, stb.) |
| ⚡FAST | Fast mode jelzo (csak aktiv allapotban latszik) |
| $X.XX | Session koltseg (API: tenyleges koltseg, Pro/Max: $0.00) |
| [████░░] X% | Context ablak hasznalat szin-kodolt progress barral |
| (Xk/200k) | Token hasznalat (felhasznalt/osszes) |
| ⏱ Xm | Session idotartam |
| 📡 N | API hivasok szama a sessionben |
| +X/-Y | Hozzaadott/torolt sorok |
| 🌿 branch | Aktualis git branch (* = nem commitolt valtozasok) |
| 📁 folder | Aktualis projekt mappa |

### Context ablak szinek

- 🟢 Zold: < 50% hasznalat
- 🟡 Sarga: 50-75% hasznalat
- 🔴 Piros: > 75% hasznalat

## Kovetelmenyek

- **bash** 4.0+
- **jq** (JSON feldolgozo)
- **git** (opcionalis, branch infohoz)
- **Claude Code** CLI

## Telepites

### Egyvonalas telepites

```bash
git clone https://github.com/kalmarr/claude-code-statusline.git /tmp/claude-code-statusline && /tmp/claude-code-statusline/install.sh && rm -rf /tmp/claude-code-statusline
```

### Telepites Claude Code prompttal

Ird be ezt a Claude Code-ba, es elvegzi a telepitest:

> Telepitsd a Claude Code statusline-t a https://github.com/kalmarr/claude-code-statusline repobol — klonozd /tmp-be, futtasd az install.sh-t, majd takarits. Inditsd ujra a Claude Code-ot ha kesz.

### Claude Code slash parancs

Ismetelt hasznalathoz masold a `commands/install-statusline.md` fajlt a `~/.claude/commands/` mappaba, majd futtasd az `/install-statusline` parancsot barmikor.

### Gyors telepites

```bash
git clone https://github.com/kalmarr-dev/claude-code-statusline.git
cd claude-code-statusline
./install.sh
```

### Kezzel

1. Masold a scriptet:
```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

2. Add hozza a Claude Code beallitasokhoz (`~/.claude/settings.json`):
```json
{
  "statusLine": {
    "command": "~/.claude/statusline.sh"
  }
}
```

3. Inditsd ujra a Claude Code-ot.

## Debug mod

A statusline bemenet debugolasahoz inditsd igy a Claude Code-ot:

```bash
DEBUG=1 claude
```

Ez minden frissiteskor elmenti a nyers JSON bemenetet a `~/.claude/debug_status.json` fajlba.

## Hogyan mukodik

A Claude Code minden frissiteskor egy JSON objektumot pipe-ol a statusline parancs stdin-jere. A script egyetlen `jq` hivassal kiolvassa az osszes mezot, majd ANSI szinkodokkal osszeallitja a kimenetet.

A fast mode allapotot a transcript JSONL fajlbol olvassa ki (`"speed":"fast"` vagy `"speed":"standard"`).

## Ikonok es logika

| Ikon | Jelentes | Forras / Logika |
|------|----------|-----------------|
| 🤖 | Modell neve | `model.display_name` a Claude Code JSON bemenetbol |
| ⚡FAST | Fast mod aktiv (sarga) | Transcript JSONL-bol: eloszor `Fast mode ON/OFF` toggle-t keres, fallback: `"speed":"fast"` |
| STD | Standard sebesseg (szurke) | Ugyanaz, mint fent — ha nincs fast mod |
| $X.XX | Session koltseg | `cost.total_cost_usd` — valos API koltseg (Pro/Max: $0.00) |
| [████░░] X% | Context ablak hasznalat | `context_window.used_percentage` — 20 karakteres progress bar, szin: 🟢 <50%, 🟡 50-75%, 🔴 >75% |
| (Xk/Xk) | Tokenek (hasznalt/osszes) | `total_input_tokens + total_output_tokens` / `context_window_size` |
| ⏱ | Session idotartam | `cost.total_duration_ms` — formatum: Xs, XmXs, vagy XhXm |
| 📡 N | API hivasok szama | `"type":"assistant"` bejegyzesek szama a transcript JSONL-ben |
| +X/-Y | Sorok valtozasa | `cost.total_lines_added` / `cost.total_lines_removed` — zold/piros |
| 🌿 | Git branch | `git branch --show-current`, `*` = nem commitolt valtozasok |
| 📁 | Projekt mappa | `basename` a `workspace.current_dir`-bol |
| │ | Elvalaszto | Vizualis hatarolo a szekciok kozott |

## Licenc

MIT - lasd [LICENSE](LICENSE)
