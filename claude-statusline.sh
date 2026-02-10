#!/bin/bash

# Read JSON input
input=$(cat)

# Extract data
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
model=$(echo "$input" | jq -r '.model.id // empty')

# Calculate context used (inverse of remaining)
if [ -n "$remaining" ]; then
    used=$(( 100 - remaining ))
else
    used=""
fi

# Colors (using printf for ANSI codes, dimmed for status line)
BLUE='\033[0;34m'
DIM='\033[2m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Output parts
output=""

# Directory (in blue, basename only)
dir_name=$(basename "$cwd")
output+="$(printf "${BLUE}${dir_name}${RESET}")"

# Git branch (if in git repo)
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --config core.fileMode=false branch --show-current 2>/dev/null || echo "detached")
    output+="$(printf " ${DIM}${branch}${RESET}")"

    # Git status (check for modifications)
    if ! git -C "$cwd" --config core.fileMode=false diff-index --quiet HEAD -- 2>/dev/null || [ -n "$(git -C "$cwd" --config core.fileMode=false ls-files --others --exclude-standard 2>/dev/null)" ]; then
        output+="$(printf " ${CYAN}*${RESET}")"
    fi
fi

# Model name (shortened)
if [ -n "$model" ]; then
    # Extract simplified model name (e.g., claude-sonnet-4-5-20250929 -> sonnet-4.5)
    if [[ "$model" =~ sonnet ]]; then
        model_short="sonnet-4.5"
    elif [[ "$model" =~ opus ]]; then
        model_short="opus-4.6"
    elif [[ "$model" =~ haiku ]]; then
        model_short="haiku-4.5"
    else
        model_short="$model"
    fi
    output+="$(printf " ${DIM}${model_short}${RESET}")"
fi

# Context window progress bar (color-coded, shows usage)
if [ -n "$used" ]; then
    # Create progress bar [████████░░] 23% (showing context used)
    bar_length=10
    filled=$(( used * bar_length / 100 ))
    empty=$(( bar_length - filled ))

    bar="["
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="]"

    # Color-code based on context used
    # Green: < 40% used, Yellow: 40-70% used, Red: > 70% used
    if [ "$used" -lt 40 ]; then
        bar_color="$GREEN"
    elif [ "$used" -lt 70 ]; then
        bar_color="$YELLOW"
    else
        bar_color="$RED"
    fi

    output+="$(printf " ${bar_color}${bar} ${used}%%${RESET}")"
fi

# Python virtual environment
if [ -n "$VIRTUAL_ENV" ]; then
    venv_name=$(basename "$VIRTUAL_ENV")
    output+="$(printf " ${DIM}${venv_name}${RESET}")"
fi

echo -e "$output"
