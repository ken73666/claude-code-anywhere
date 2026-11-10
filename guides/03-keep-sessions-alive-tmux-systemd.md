# Keep sessions alive: tmux and systemd

Last updated: 2026-11

Two different failures kill a Claude Code session on a server: the SSH connection drops, or the machine reboots. tmux handles the first and is covered below. Surviving reboots with systemd is added in a later update. Anthropic's own Remote Control docs give the same advice for remote machines: start `claude` inside `tmux` or `screen`.

Files referenced here live in [`../templates/`](../templates/).

## 1. tmux for disconnects

```bash
sudo apt install tmux
tmux new -A -s work        # attach if it exists, create if not
claude
# Ctrl+b then d  -> detach (process keeps running)
tmux ls
tmux attach -t work
```

The prefix is `Ctrl+b`: press it, release, then press the next key. Useful extras:

| Keys | Action |
| --- | --- |
| `Ctrl+b c` | New window |
| `Ctrl+b n` / `p` | Next / previous window |
| `Ctrl+b [` | Scroll mode (`q` to leave) |
| `Ctrl+b :kill-session` | Kill the current session |

Drop in [`templates/tmux.conf`](../templates/tmux.conf) as `~/.tmux.conf` for mouse support (touch scrolling on a phone), a larger scrollback, and a shorter escape delay. Then reload with `tmux source-file ~/.tmux.conf`.

### One command to get back in

[`templates/claude-session.sh`](../templates/claude-session.sh) attaches to a named session, or creates it, starts `claude` in your project directory, and drops back to a shell if `claude` exits.

```bash
install -m 755 templates/claude-session.sh ~/.local/bin/cs
cs                       # session "work", directory ~/projects
cs api ~/projects/api    # session "api", directory ~/projects/api
```
