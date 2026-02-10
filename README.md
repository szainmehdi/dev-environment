# Environment Configuration

Shared shell, terminal, and development tool configuration across machines.

## Quick Setup

```bash
cd ~/Development/env
./setup.sh
```

## What Gets Installed

- **Zsh configuration** - Common shell setup in `zsh/zshrc.common`
- **Starship prompt** - Cross-shell prompt configuration
- **Ghostty terminal** - Terminal emulator config (if present)
- **Claude Code statusline** - Custom statusline for Claude Code CLI

## Manual Configuration

### Claude Code Statusline

The `claude-statusline.sh` script provides a custom statusline for the Claude Code CLI that shows:

- Current directory (blue)
- Git branch and status (dimmed, with cyan * for changes)
- Model name (dimmed, e.g., "sonnet-4.5")
- Context window progress bar (yellow, e.g., `[████████░░] 77%`)
- Python virtualenv (dimmed, if active)

**Setup on a new machine:**

1. Ensure Claude Code is installed
2. Run the main setup script: `./setup.sh`
3. Configure Claude Code to use the statusline:

```bash
# Edit ~/.claude/settings.json and add:
{
  "statusLine": {
    "type": "command",
    "command": "/Users/zain/Development/env/claude-statusline.sh"
  }
}
```

Or manually create a symlink:

```bash
mkdir -p ~/.claude
ln -s ~/Development/env/claude-statusline.sh ~/.claude/statusline-command.sh
```

Then update settings.json to point to `~/.claude/statusline-command.sh` instead.

## Directory Structure

```
.
├── aliases/              # Shell aliases
├── bin/                  # Custom scripts
├── ghostty/              # Ghostty terminal config
├── snippets/             # Code snippets
├── zsh/                  # Zsh configuration
├── claude-statusline.sh  # Claude Code statusline script
├── starship.toml         # Starship prompt config
└── setup.sh              # Main setup script
```

## Repository

This configuration is version-controlled and synced across machines. Machine-specific customizations should go in `~/.zshrc` (local, not synced).
