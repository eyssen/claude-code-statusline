---
description: Install or update the Claude Code statusline from GitHub
allowed-tools: ["Bash"]
---

Install the Claude Code statusline. Run these steps in order:

1. Clone the repo: `git clone https://github.com/kalmarr/claude-code-statusline.git /tmp/claude-code-statusline`
2. Run the installer: `bash /tmp/claude-code-statusline/install.sh`
   - If it asks about overwrite, answer yes
3. Clean up: `rm -rf /tmp/claude-code-statusline`
4. Tell the user: "Restart Claude Code to activate the statusline."
