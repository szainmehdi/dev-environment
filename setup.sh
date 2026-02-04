#!/bin/bash
# =============================================================================
# Environment Setup Script (macOS)
# =============================================================================
# Run this script on a new machine to set up shell and terminal configuration.
# Usage: ./setup.sh
# =============================================================================

set -e

ENV_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSH_DIR="$ENV_DIR/zsh"

echo "Setting up environment from: $ENV_DIR"
echo

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------
backup_if_exists() {
  local file="$1"
  if [[ -e "$file" && ! -L "$file" ]]; then
    local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
    echo "  Backing up existing $file → $backup"
    mv "$file" "$backup"
  elif [[ -L "$file" ]]; then
    echo "  Removing existing symlink: $file"
    rm "$file"
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"
  backup_if_exists "$target"
  echo "  Linking $target → $source"
  ln -s "$source" "$target"
}

# -----------------------------------------------------------------------------
# Check for Homebrew
# -----------------------------------------------------------------------------
if ! command -v brew &> /dev/null; then
  echo "Error: Homebrew is required. Install from https://brew.sh"
  exit 1
fi

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------
echo "Checking dependencies..."

# Antidote
if ! brew list antidote &> /dev/null; then
  echo "  Installing antidote..."
  brew install antidote
else
  echo "  ✓ antidote already installed"
fi

# Starship
if ! command -v starship &> /dev/null; then
  echo "  Installing starship..."
  brew install starship
else
  echo "  ✓ starship already installed"
fi

echo

# -----------------------------------------------------------------------------
# Create symlinks
# -----------------------------------------------------------------------------
echo "Creating symlinks..."

# starship.toml
mkdir -p "$HOME/.config"
create_symlink "$ENV_DIR/starship.toml" "$HOME/.config/starship.toml"

# ghostty config (optional)
if [[ -d "$ENV_DIR/ghostty" ]]; then
  mkdir -p "$HOME/.config/ghostty"
  create_symlink "$ENV_DIR/ghostty/config" "$HOME/.config/ghostty/config"
fi

echo

# -----------------------------------------------------------------------------
# Create ~/.zshrc (local, not synced)
# -----------------------------------------------------------------------------
if [[ ! -f "$HOME/.zshrc" ]]; then
  echo "Creating ~/.zshrc..."
  cat > "$HOME/.zshrc" << EOF
# =============================================================================
# Zsh Configuration (Local)
# =============================================================================
# This file is machine-specific and not synced.
# Common config is sourced below; add local customizations after.

source "$ENV_DIR/zsh/zshrc.common"

# -----------------------------------------------------------------------------
# Machine-specific config below
# -----------------------------------------------------------------------------

EOF
else
  echo "~/.zshrc already exists - please ensure it sources:"
  echo "  source \"$ENV_DIR/zsh/zshrc.common\""
fi

echo
echo "Setup complete!"
echo
echo "Next steps:"
echo "  1. Open a new terminal or run: source ~/.zshrc"
echo "  2. Add machine-specific settings directly to ~/.zshrc"
echo
