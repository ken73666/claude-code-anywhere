# Templates

Copy-paste configs used by the guides. Each file starts with comments that say what it is for and how to install it. Read the file before you install it.

| File | Install to | Used in |
| --- | --- | --- |
| [`tmux.conf`](tmux.conf) | `~/.tmux.conf` | [Guide 03](../guides/03-keep-sessions-alive-tmux-systemd.md) |
| [`claude-session.sh`](claude-session.sh) | `~/.local/bin/cs` (`install -m 755`) | [Guide 03](../guides/03-keep-sessions-alive-tmux-systemd.md) |
| [`claude-tmux.service`](claude-tmux.service) | `~/.config/systemd/user/` | [Guide 03](../guides/03-keep-sessions-alive-tmux-systemd.md) |
| [`claude-nightly.service`](claude-nightly.service), [`claude-nightly.timer`](claude-nightly.timer) | `~/.config/systemd/user/` | [Guide 03](../guides/03-keep-sessions-alive-tmux-systemd.md) |
| [`00-hardening.conf`](00-hardening.conf) | `/etc/ssh/sshd_config.d/00-hardening.conf` | [Guide 05](../guides/05-server-hardening-checklist.md) |
| [`ufw-setup.sh`](ufw-setup.sh) | Run once with `sudo bash ufw-setup.sh` | [Guide 05](../guides/05-server-hardening-checklist.md) |
| [`jail.local`](jail.local) | `/etc/fail2ban/jail.local` | [Guide 05](../guides/05-server-hardening-checklist.md) |
| [`settings.user.example.jsonc`](settings.user.example.jsonc) | `~/.claude/settings.json` (remove the `//` comment lines first) | [Guide 03](../guides/03-keep-sessions-alive-tmux-systemd.md), [05](../guides/05-server-hardening-checklist.md) |
| [`settings.gateway.example.jsonc`](settings.gateway.example.jsonc) | `~/.claude/settings.json` (remove the `//` comment lines first) | [Guide 04](../guides/04-api-keys-and-gateways.md) |
| [`settings.openrouter.example.jsonc`](settings.openrouter.example.jsonc) | `~/.claude/settings.json` (remove the `//` comment lines first) | [Guide 04](../guides/04-api-keys-and-gateways.md) |
| [`codex-config.example.toml`](codex-config.example.toml) | Merge into `~/.codex/config.toml` | [Guide 04](../guides/04-api-keys-and-gateways.md) |

The `.jsonc` files contain comments, which JSON does not allow. The settings examples all install to the same path, so use only one of them at a time, or merge the `env` blocks by hand.
