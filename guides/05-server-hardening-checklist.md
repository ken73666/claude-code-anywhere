# Server hardening checklist

Last updated: 2026-11 · `sshd -t` and `fail2ban-client -t` checks pass on Ubuntu 24.04

A fresh VPS is scanned by bots within minutes. An agent that can run shell commands and holds an API key makes a compromised box more costly. This checklist covers the minimum for a Debian/Ubuntu server. Commands assume a sudo-capable non-root user (see [guide 01](01-run-claude-code-on-a-vps.md)).

Work through it in order. Keep a second SSH session open while changing SSH or firewall settings.

## Checklist

- [ ] 1. Non-root user with sudo; you log in with an SSH key
- [ ] 2. Password login and root login disabled
- [ ] 3. Firewall on, only the ports you need open
- [ ] 4. fail2ban running

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

## 3. Firewall (ufw)

```bash
sudo apt install ufw
sudo bash templates/ufw-setup.sh   # review the script before running it
sudo ufw status verbose
```

The script denies incoming by default, allows outgoing, and rate-limits SSH. **SSH is allowed before enabling**, otherwise you lock yourself out. Open 80 and 443 only if you serve a website. Some providers also have a network firewall in their control panel; use it as a second layer.

## 4. fail2ban

```bash
sudo apt install fail2ban
sudo cp templates/jail.local /etc/fail2ban/jail.local
sudo systemctl enable --now fail2ban
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
```

It watches authentication logs for IPs with repeated failures and bans them temporarily. If the service fails to start on a distribution that no longer writes `/var/log/auth.log`, add `backend = systemd` under `[sshd]` and install `python3-systemd` (the systemd backend uses the systemd Python library). If the jail still sees nothing, check which unit name your distribution logs sshd under (`ssh.service` on Debian/Ubuntu) and verify with `sudo fail2ban-client status sshd`.
