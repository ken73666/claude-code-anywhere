# Server hardening checklist

Last updated: 2026-11 · `sshd -t` and `fail2ban-client -t` checks pass on Ubuntu 24.04

A fresh VPS is scanned by bots within minutes. An agent that can run shell commands and holds an API key makes a compromised box more costly. This checklist covers the minimum for a Debian/Ubuntu server. Commands assume a sudo-capable non-root user (see [guide 01](01-run-claude-code-on-a-vps.md)).

Work through it in order. Keep a second SSH session open while changing SSH or firewall settings.

## Checklist

- [ ] 1. Non-root user with sudo; you log in with an SSH key
- [ ] 2. Password login and root login disabled
- [ ] 3. Firewall on, only the ports you need open
- [ ] 4. fail2ban running
- [ ] 5. Automatic security updates on
- [ ] 6. Secrets readable only by you, never in git
- [ ] 7. Scoped git credentials
- [ ] 8. Claude Code permissions reviewed
- [ ] 9. Optional: SSH only over Tailscale
- [ ] 10. You know what is listening

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

## 5. Automatic security updates

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

Native installs of Claude Code update themselves in the background. The OS is on you.

## 6. Protect secrets

```bash
chmod 700 ~/.claude
chmod 600 ~/.claude/settings.json
```

- Claude Code stores subscription credentials in `~/.claude/.credentials.json` with mode 0600 on Linux. Give anything you write the same mode.
- Never put credentials in a project's committed `.claude/settings.json`.
- If you use `.claude/settings.local.json`, make sure `.gitignore` covers it: `echo '.claude/settings.local.json' >> .gitignore`.
- Use a spend limit on every API key, and rotate on any doubt ([guide 04](04-api-keys-and-gateways.md)).

## 7. Git credentials

Use a per-repo deploy key or a fine-grained, scoped token instead of your main account's credentials.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/deploy_myrepo -C "myrepo deploy key"
cat ~/.ssh/deploy_myrepo.pub     # add as a deploy key in the repo settings
```

Add write access only if the agent needs to push. Prefer having it push to a branch and review before merging.

## 8. Claude Code permissions

- Run Claude Code as your normal user, never as root.
- Review permission prompts instead of blanket-approving commands.
- For unattended jobs, pre-approve only what the job needs with `permissions` in settings and deny reads of secret files. Example: [`templates/settings.user.example.jsonc`](../templates/settings.user.example.jsonc).
- Keep anything you would not want leaked out of directories the agent works in.
- Work on branches, so changes are reviewable and reversible.

## 9. Optional: SSH only over Tailscale

If you reach the server from your own devices only, you can avoid public SSH altogether. Install Tailscale on the server and your devices (guide 02), confirm you can connect via the Tailscale name, then close the public port:

```bash
sudo ufw allow in on tailscale0 to any port 22 proto tcp
sudo ufw delete limit 22/tcp
sudo ufw status numbered
```

Do this only after a Tailscale login works. If your provider has a web console, know how to reach it in case you lock yourself out.

## 10. Know what is listening

```bash
sudo ss -tlnp
```

Anything bound to `0.0.0.0` or `::` that you did not intend (a dev server, a database) is reachable from the internet unless the firewall blocks it. Bind dev servers to `127.0.0.1` and reach them over an SSH tunnel: `ssh -L 3000:127.0.0.1:3000 dev@YOUR_SERVER_IP`.

Docker note: per Docker's packet-filtering docs, container traffic is routed in the `nat` table before ufw's rules apply, so published ports can ignore your ufw configuration. Publish to loopback (`-p 127.0.0.1:3000:3000`) unless you intend to expose the port.

## Quick audit

```bash
sudo sshd -T | grep -i -E "passwordauthentication|permitrootlogin|pubkeyauthentication"
sudo ufw status verbose
sudo fail2ban-client status sshd
sudo ss -tlnp
ls -l ~/.claude/settings.json
```
