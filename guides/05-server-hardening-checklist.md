# Server hardening checklist

Last updated: 2026-11 · The `sshd -t` check passes on Ubuntu 24.04

A fresh VPS is scanned by bots within minutes. An agent that can run shell commands and holds an API key makes a compromised box more costly. This checklist covers the minimum for a Debian/Ubuntu server. Commands assume a sudo-capable non-root user (see [guide 01](01-run-claude-code-on-a-vps.md)).

Work through it in order. Keep a second SSH session open while changing SSH or firewall settings.

## Checklist

- [ ] 1. Non-root user with sudo; you log in with an SSH key
- [ ] 2. Password login and root login disabled

## 1. Non-root user and keys

```bash
# as root
adduser dev && usermod -aG sudo dev
# from your computer
ssh-copy-id dev@YOUR_SERVER_IP
```

Test `ssh dev@YOUR_SERVER_IP` in a new terminal before going further.

## 2. Disable passwords and root login

Use the drop-in [`templates/00-hardening.conf`](../templates/00-hardening.conf):

```bash
sudo cp templates/00-hardening.conf /etc/ssh/sshd_config.d/00-hardening.conf
sudo sshd -t                      # syntax check; no output means OK
sudo systemctl restart ssh        # the unit is "sshd" on some distributions
sudo sshd -T | grep -i -E "passwordauth|permitroot|kbdinteractive"
```

Why `00-`: sshd uses the first value it sees for a keyword, and drop-ins are read in lexical order. A file like `50-cloud-init.conf` that sets `PasswordAuthentication yes` would beat a `99-` file. The drop-in directory is only read if the main `/etc/ssh/sshd_config` contains an `Include /etc/ssh/sshd_config.d/*.conf` line (the default on current Debian and Ubuntu; check with `grep -i include /etc/ssh/sshd_config`). The `sshd -T` command prints the effective values, so always verify with it. Keep your current session open until a new login works.
