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

### Scheduled headless runs

For a recurring job (for example, a nightly dependency check), use a oneshot service and a timer with Claude Code's non-interactive mode, `claude -p`.

```bash
cp templates/claude-nightly.service templates/claude-nightly.timer ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now claude-nightly.timer
systemctl --user list-timers
systemctl --user start claude-nightly.service    # run once now to test
```

Notes:

- In `-p` mode the API key is used without a prompt, so authenticate unattended jobs with `ANTHROPIC_API_KEY` in `~/.claude/settings.json` or an `apiKeyHelper` (see guide 04). `claude setup-token` generates a long-lived OAuth token for `CLAUDE_CODE_OAUTH_TOKEN` for subscription users.
- An unattended run cannot answer permission prompts. Pre-approve only what the job needs in the `permissions` section of settings (see `settings.user.example.jsonc`) and have the job work on a branch.
- systemd does not load your shell profile. The unit sets `PATH` explicitly so `~/.local/bin/claude` is found.

## 3. Habits that save you

- Tell Claude to commit often. A reboot or crash then costs minutes, not hours.
- Keep long jobs in their own tmux window so you can `Ctrl+b n` between them.
- If the session is gone after a reconnect, you started `claude` outside tmux.
- After OS updates that require a reboot, plan for it: tmux is gone, the systemd unit brings back an empty session.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `systemctl --user` says "Failed to connect to bus" | Log in with a full SSH session (not `su`), or `export XDG_RUNTIME_DIR=/run/user/$(id -u)` |
| Unit does not start at boot | Run `loginctl show-user "$USER" \| grep Linger`; it should say `Linger=yes` |
| `claude: command not found` in a unit | Check the `Environment=PATH=` line includes `%h/.local/bin` |
| `tmux: no server running` after reboot | The unit is not enabled, or `ExecStart` failed; read `journalctl --user -u claude-tmux.service` |
