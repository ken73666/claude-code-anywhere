# claude-code-anywhere

> Practical, vendor-neutral guides and copy-paste configs for running Claude Code (and other terminal coding agents) 24/7 on a server, reaching it from your phone, and wiring it to your own API key or gateway.

Last updated: 2026-11

Claude Code is a terminal program: it runs where you start it. Close the laptop and the task stops. This repo collects what is needed to move it somewhere that stays on, keep sessions alive, reach them from a phone, and lock the box down. Everything here is plain Linux, `tmux`, `systemd`, and `ssh`. No account with any vendor is required to use it.

Facts about Anthropic's features (Remote Control, cloud sessions) come from Anthropic's public documentation as of November 2026. Plan names and limits change, so check the linked docs before you commit.

## Which guide do I need?

| I want to... | Read |
| --- | --- |
| Keep Claude Code running after I close my laptop | [01 Run Claude Code on a VPS](guides/01-run-claude-code-on-a-vps.md) |
| Check on or steer a session from my phone | [02 Claude Code on your phone](guides/02-claude-code-on-your-phone.md) |
| Stop sessions dying on SSH drops or reboots | [03 Keep sessions alive: tmux and systemd](guides/03-keep-sessions-alive-tmux-systemd.md) |
| Use an API key, OpenRouter, or a company gateway | [04 API keys and gateways](guides/04-api-keys-and-gateways.md) |
| Harden a fresh server before putting credentials on it | [05 Server hardening checklist](guides/05-server-hardening-checklist.md) |
| Reach the server only over a private network | [06 Private SSH with Tailscale](guides/06-private-ssh-with-tailscale.md) |
| Just copy a working config | [templates/](templates/) |

### Decision tree

1. **Is your work on GitHub, and do you have a paid Claude plan with a claude.ai login?**
   Start with Anthropic's cloud sessions. Nothing to maintain. Limits: GitHub-centric, no API keys or gateways, idle sessions pause.
2. **Do you only need to steer a session on a machine that stays on?**
   Use Remote Control from your own computer. It needs a claude.ai subscription login, and the `claude` process must keep running.
3. **Do you pay per token, use OpenRouter or a gateway, need root, Docker, or long-running services?**
   Run Claude Code on a server you control. Follow guides 01, 03, 05, then 04.
4. **Do you want a server but not the sysadmin work?**
   Use a prepared managed server (see the table below), or do guides 01 to 05 yourself on any VPS.

## Contents

- [guides/](guides/) - step-by-step walkthroughs
  - [01 Run Claude Code on a VPS](guides/01-run-claude-code-on-a-vps.md)
  - [02 Claude Code on your phone](guides/02-claude-code-on-your-phone.md)
  - [03 Keep sessions alive: tmux and systemd](guides/03-keep-sessions-alive-tmux-systemd.md)
  - [04 API keys and gateways](guides/04-api-keys-and-gateways.md)
  - [05 Server hardening checklist](guides/05-server-hardening-checklist.md)
  - [06 Private SSH with Tailscale](guides/06-private-ssh-with-tailscale.md)
- [templates/](templates/) - configs you can copy as-is ([index with install locations](templates/README.md))
  - [`tmux.conf`](templates/tmux.conf), [`claude-session.sh`](templates/claude-session.sh)
  - [`claude-tmux.service`](templates/claude-tmux.service) (systemd user unit), [`claude-nightly.service`](templates/claude-nightly.service) and [`.timer`](templates/claude-nightly.timer)
  - [`00-hardening.conf`](templates/00-hardening.conf) (sshd), [`ufw-setup.sh`](templates/ufw-setup.sh), [`jail.local`](templates/jail.local) (fail2ban)
  - [`settings.user.example.jsonc`](templates/settings.user.example.jsonc), [`settings.gateway.example.jsonc`](templates/settings.gateway.example.jsonc), [`settings.openrouter.example.jsonc`](templates/settings.openrouter.example.jsonc)
  - [`codex-config.example.toml`](templates/codex-config.example.toml)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CHANGELOG.md](CHANGELOG.md)

## Where can Claude Code run? Comparison

Tags: **[always-on]** keeps running with your laptop closed. **[any-key]** works with API keys and gateways. **[claude.ai-login]** requires a claude.ai subscription login. **[you-maintain]** you patch and secure it.

| Option | Where the session runs | Laptop can be off | API key / gateway | Phone access | Tags |
| --- | --- | --- | --- | --- | --- |
| Anthropic cloud sessions (claude.ai/code) | Anthropic-managed VM | Yes | No | Claude app, claude.ai/code | [always-on] [claude.ai-login] |
| Remote Control | Your own computer | No | No | Claude app, claude.ai/code | [claude.ai-login] |
| Self-managed VPS + tmux | Your server | Yes | Yes | SSH app, Tailscale | [always-on] [any-key] [you-maintain] |
| Managed dedicated server with browser workspace (for example AlwaysAgent, see below) | Provider-hosted Linux VM | Yes | Yes, bring your own | Browser | [always-on] [any-key] |
| Home PC or spare machine + SSH | Your machine | Only if it stays on | Yes | SSH app, Tailscale | [any-key] [you-maintain] |
| GitHub Codespaces | Cloud dev container | Stops when idle (default idle timeout 30 min, configurable 5 to 240 min; 12 h max lifetime per GitHub docs) | Yes | Browser | [any-key] |
| Claude Code GitHub Actions | CI runner | Yes | Yes | Via GitHub (`@claude` comments) | Event-driven, ephemeral |

Notes on the table:

- Remote Control and cloud sessions both need a claude.ai login. Per Anthropic's docs, API keys are not supported for Remote Control, and cloud sessions "aren't available through third-party providers". Setting `ANTHROPIC_BASE_URL` to a non-Anthropic host also disables Remote Control.
- Codespaces and GitHub Actions rows are summarized from GitHub's documentation. Check GitHub's docs for current limits and billing.
- A managed server and a self-managed VPS are the same thing technically. The difference is who does the setup and maintenance.

## Contributing

Contributions are welcome, especially corrections. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

- Open an issue if a command no longer works, a limit changed, or a statement is out of date. Include the OS/version you tested on.
- Pull requests should be small and focused: one guide fix, one new template, or one new troubleshooting entry.
- Every command should be copy-pasteable and tested on a clean Debian or Ubuntu machine. Say which version you tested on.
- Claims about third-party products need a link to their official documentation.
- Keep it neutral. No referral links, no price lists that will go stale, no marketing copy.
- Put "Last updated: YYYY-MM" at the top of any guide you change.

## About / Maintainer

This repo is maintained by the team behind [AlwaysAgent](https://alwaysagent.app), a hosted option in the "managed dedicated server" row above: a dedicated cloud Linux server with Claude Code and Codex preinstalled and a browser workspace. AlwaysAgent is not open for sign-ups yet; see the site for current status. It is an independent product and is not affiliated with Anthropic or OpenAI. The guides here work on any VPS and do not require it.

## License

Text: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Code and config templates: [MIT](LICENSE).
