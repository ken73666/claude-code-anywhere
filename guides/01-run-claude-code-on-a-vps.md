# Run Claude Code on a VPS

Last updated: 2026-11

A small Linux server, the official installer, and tmux are enough to keep Claude Code working after you close your laptop. This guide takes a fresh Debian/Ubuntu VPS to a working session. Phone access is in guide 02, keep-alive in 03, credentials in 04, hardening in 05.

## Why a server

Claude Code runs on the machine where you start it. If that machine sleeps or shuts down, the task stops. An always-on server fixes that, and you can reach the session from any device. Anthropic's own options have limits: Remote Control sessions run on your machine ("your computer has to stay on"), and cloud sessions need a claude.ai account and do not accept API keys or third-party providers. A server you control has neither restriction. See the comparison in the README.

## 1. Pick a server

Any regular Linux VPS works. Anthropic's system requirements list Ubuntu 20.04+, Debian 10+, or Alpine 3.19+, 4 GB+ RAM, x64 or ARM64, and internet access. Size beyond that for your own builds, test suites, and containers.

| Workload | Starting point |
| --- | --- |
| Scripts, small web apps, light refactors | 2 vCPU, 4 GB RAM, 40 GB disk |
| Full-stack project with a database or Docker | 4 vCPU, 8 GB RAM, 75 GB+ disk |

Check whether your provider bills powered-off servers. Many do until you delete them.

## 2. Create a non-root user

Log in once as root (or the default user your provider created):

```bash
# On the server, as root
adduser dev
usermod -aG sudo dev
```

From your own computer, copy your SSH key to the new user:

```bash
# On your computer
ssh-keygen -t ed25519          # only if you have no key pair yet
ssh-copy-id dev@YOUR_SERVER_IP
ssh dev@YOUR_SERVER_IP
```

Keep the private key on your machine only.

## 3. Install Claude Code

Use Anthropic's native installer. It needs no Node.js and installs to your home directory:

```bash
# On the server, as your normal user
curl -fsSL https://claude.ai/install.sh | bash
claude --version
claude doctor      # read-only health check
```

Alternatives from the official setup guide: signed apt/dnf/apk repositories, or `npm install -g @anthropic-ai/claude-code` (needs Node.js 22+, do not use `sudo`).

If `claude: command not found`, the binary is in `~/.local/bin`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

If the installer prints `Killed` (exit code 137), the server ran out of memory. Add swap or use a bigger plan:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## 4. Sign in

You can use a claude.ai subscription or an Anthropic Console API key.

**Subscription login.** Run `claude`. There is no browser on the server, so copy the login URL (press `c` in the prompt), open it on your own computer, sign in, and paste the code back at the `Paste code here` prompt. If pasting does nothing, run `claude auth login` instead. Claude Code requires a Pro, Max, Ultra, Team, Enterprise, or Console account; the free claude.ai plan does not include it.

**API key.** Put it in the user-level settings file, not in a project:

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "YOUR_API_KEY"
  }
}
```

Save that as `~/.claude/settings.json`, then `chmod 600 ~/.claude/settings.json`. Run `/status` inside Claude Code to confirm which credential is active. More in guide 04.

## 5. Run it inside tmux

A plain SSH session kills your process when the connection drops. Use tmux:

```bash
sudo apt install tmux
tmux new -A -s work     # attach if "work" exists, create it if not
claude
# Ctrl+b, then d, to detach
tmux ls
tmux attach -t work
```

tmux survives disconnects but not a server reboot. For auto-start after a reboot, see guide 03.

## 6. Lock it down

Before you put credentials on the box, do at least: key-only SSH, a firewall, fail2ban, non-root user. Follow guide 05.

## 7. Estimate the cost

Total = server rental + model usage. The server is a flat rate that accrues while it exists, not while you use it. With a subscription, usage counts against your plan limits. With an API key you pay per token, and heavy autonomous runs can cost more than the server. Run your real workflow for a week, record the two bills separately, and extrapolate.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `claude: command not found` | Add `~/.local/bin` to PATH (above) |
| `Killed` during install | Add swap or move to a bigger plan |
| Install script returns HTML or 403 | Proxy, network filter, or unsupported region. Set `HTTPS_PROXY` if behind a proxy |
| OAuth "Invalid code" | Code expired or truncated. Retry quickly, copy the whole URL with `c` |
| Auth errors after a while | Run `/login` again, check the server clock, run `/status` to see if `ANTHROPIC_API_KEY` overrides your subscription |
| Session gone after reconnecting | You ran `claude` outside tmux |
| Remote Control will not start | Check login and base-URL limits, then `claude remote-control --verbose` |

## Prefer not to run the server yourself?

Everything above works on any VPS. If you would rather skip the server administration, a managed dedicated server is the same idea with the setup done. One example is [AlwaysAgent](https://alwaysagent.app) (not open for sign-ups yet), which is maintained by the authors of this repo.
