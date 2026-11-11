# Keep sessions alive: tmux and systemd

Last updated: 2026-11

Two different failures kill a Claude Code session on a server: the SSH connection drops, or the machine reboots. tmux handles the first. systemd handles the second. Anthropic's own Remote Control docs give the same advice for remote machines: start `claude` inside `tmux` or `screen`.

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

## 2. systemd for reboots

tmux sessions do not survive a reboot. A systemd **user** unit can recreate the session at boot. It runs as your own user, so no root-owned services and no extra privileges.

```bash
mkdir -p ~/.config/systemd/user
cp templates/claude-tmux.service ~/.config/systemd/user/
# let user services run at boot without an active login:
sudo loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now claude-tmux.service
systemctl --user status claude-tmux.service
tmux ls
```

Edit `ExecStart` first if tmux is not at `/usr/bin/tmux` (check with `command -v tmux`) or if your project is not in `~/projects`.

The unit starts an empty shell session named `work`. After a reboot, attach and start `claude` yourself, or `claude --continue` to resume the last conversation in that directory. Starting an agent unattended is a deliberate choice: it will act without you watching, so decide that with your permission settings in mind.

Logs: `journalctl --user -u claude-tmux.service`.
