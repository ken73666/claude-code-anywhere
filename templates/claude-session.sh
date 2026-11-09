#!/usr/bin/env bash
# claude-session.sh - attach to a named tmux session, or create it and start Claude Code.
# Purpose: one command to get back to your agent from any device (phone SSH app included).
# Install: install -m 755 claude-session.sh ~/.local/bin/cs
# Usage:   cs [session-name] [project-directory]
#          cs                    -> session "work", directory ~/projects
#          cs api ~/projects/api -> session "api",  directory ~/projects/api

set -euo pipefail

# Session name and working directory; both can be overridden by arguments
SESSION="${1:-work}"
DIR="${2:-$HOME/projects}"

# Create the directory if missing so tmux can start in it
mkdir -p "$DIR"

# Create the session if missing: start claude detached; if it exits, fall back to a shell
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -c "$DIR" 'claude; exec "$SHELL"'
fi

# Inside tmux already: switch client. Otherwise attach
if [ -n "${TMUX:-}" ]; then
  tmux switch-client -t "$SESSION"
else
  tmux attach-session -t "$SESSION"
fi
