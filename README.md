# claude-code-anywhere

> Practical, vendor-neutral guides and copy-paste configs for running Claude Code (and other terminal coding agents) 24/7 on a server, reaching it from your phone, and wiring it to your own API key or gateway.

Last updated: 2026-11

Claude Code is a terminal program: it runs where you start it. Close the laptop and the task stops. This repo collects what is needed to move it somewhere that stays on, keep sessions alive, reach them from a phone, and lock the box down. Everything here is plain Linux, `tmux`, `systemd`, and `ssh`. No account with any vendor is required to use it.

Facts about Anthropic's features (Remote Control, cloud sessions) come from Anthropic's public documentation as of November 2026. Plan names and limits change, so check the linked docs before you commit.

## What's here (work in progress)

Guides are being added over the next two weeks, each tested before it lands:

1. [Run Claude Code on a VPS](guides/01-run-claude-code-on-a-vps.md)
2. Claude Code on your phone
3. Keep sessions alive: tmux and systemd
4. API keys and gateways (OpenRouter, company gateways, Codex providers)
5. Server hardening checklist

Plus copy-paste templates: [tmux config](templates/tmux.conf), [session script](templates/claude-session.sh), systemd units, sshd drop-in, ufw script, fail2ban jail, Claude Code settings examples, and Codex config example.

Watch or star the repo to follow along. Issues with requests and corrections are welcome.

## Contributing

Contributions are welcome, especially corrections.

- Open an issue if a command no longer works, a limit changed, or a statement is out of date. Include the OS/version you tested on.
- Pull requests should be small and focused: one guide fix, one new template, or one new troubleshooting entry.
- Every command should be copy-pasteable and tested on a clean Debian or Ubuntu machine. Say which version you tested on.
- Claims about third-party products need a link to their official documentation.
- Keep it neutral. No referral links, no price lists that will go stale, no marketing copy.
- Put "Last updated: YYYY-MM" at the top of any guide you change.

## About / Maintainer

This repo is maintained by the team behind [AlwaysAgent](https://alwaysagent.app), a hosted option for running coding agents on a dedicated cloud Linux server with Claude Code and Codex preinstalled and a browser workspace. AlwaysAgent is not open for sign-ups yet; see the site for current status. It is an independent product and is not affiliated with Anthropic or OpenAI. The guides here work on any VPS and do not require it.

## License

Text: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Code and config templates: [MIT](LICENSE).
