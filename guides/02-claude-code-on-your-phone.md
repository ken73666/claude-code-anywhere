# Claude Code on your phone

Last updated: 2026-11

Claude Code has no separate mobile app. Per Anthropic's docs, "The Claude app for iOS and Android is a client for Claude Code sessions rather than a place where code runs." Cloud sessions and Remote Control both live in the **Code** tab of the Claude app (and at claude.ai/code). This guide covers the four realistic ways to work from a phone.

## Pick one

| Your situation | Use |
| --- | --- |
| Laptop stays on, you have a claude.ai plan | Remote Control |
| Code on GitHub, laptop will be closed, claude.ai plan | Cloud sessions |
| API key, OpenRouter, or gateway; or you want root and long-running jobs | Your own server over SSH (or a browser workspace) |

Remote Control and cloud sessions need a claude.ai login. They are not reachable with a Console API key or a third-party provider such as Amazon Bedrock.

## A. Remote Control (your own machine)

Your phone becomes a window into a session on your computer. The computer must stay on and the `claude` process must keep running.

```bash
claude remote-control          # server mode; press the spacebar for a QR code
claude --remote-control        # normal interactive session you can also drive remotely
# or, inside an existing session:
/remote-control                # (or /rc)
```

Then open the session from the Code tab in the Claude app, or claude.ai/code. Inside a session, `/mobile` prints a QR code that opens the app store link.

Requirements: Pro, Max, Ultra, Team, or Enterprise plan, signed in with claude.ai. On Team and Enterprise an owner must enable it. Outbound HTTPS only; no inbound ports are opened.

Limits:

- It does not work with API keys, Bedrock, Vertex, Foundry, or when `ANTHROPIC_BASE_URL` points anywhere other than `api.anthropic.com`.
- In server mode, an extended network outage (roughly ten minutes) makes the process exit.
- Terminal-only commands such as `/plugin` and `/resume` do not work from the app, and you cannot choose Bypass permissions there.

Running it on a remote server: start it inside tmux so an SSH drop does not kill it.

```bash
tmux new -A -s rc
claude remote-control
```

## B. Cloud sessions (Anthropic-hosted)

Open claude.ai/code or the Code tab, connect GitHub, pick a repo and branch, describe the task. From a terminal: `claude --cloud "your task"` (push your commits first) and `claude --teleport` to pull a session back.

Limits: GitHub is the main path; network access is allowlisted by default; idle sessions pause and VMs can be reclaimed (the conversation is restored on reopen, but running shell commands and subagents are not). Usage counts toward your plan; there is no separate charge for the VM.

## C. SSH + tmux (your own server)

Works with any credentials, at the cost of typing in a terminal on glass.

1. Install an SSH client on your phone (Termux on Android; Blink Shell or Prompt on iOS are commonly used) and add your private key.
2. Connect and run:

```bash
tmux new -A -s work
claude
```

3. After a dropped connection, reconnect and run the same `tmux new -A -s work`.

Tips:

- Mobile OSes suspend background sockets, so expect to reconnect. Mosh handles roaming better if you install it on both ends.
- Keep prompts short and lean on the approve-or-reject flow. Reading long diffs in tmux on a small screen is slow.
- Use `set -g mouse on` (see `templates/tmux.conf`) for touch scrolling.

### Private access with Tailscale

Tailscale puts your phone and server on a private network, so SSH need not face the public internet.

```bash
# On the server
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Install Tailscale on the phone, sign in to the same account, and connect to the server's Tailscale name. Optionally enable Tailscale SSH with `sudo tailscale set --ssh` (requires an access-control policy that allows SSH to the machine; the default policy covers your own devices). Once it works you can close port 22 to the public internet, see [guide 05](05-server-hardening-checklist.md).

## D. Browser workspace on a managed server

A browser workspace puts chat, files, a terminal, and preview on a server you do not administer, so no SSH client is needed. [AlwaysAgent](https://alwaysagent.app) is one such product (not open for sign-ups yet; maintained by the authors of this repo). Read its limits like any other: if you use an API key or gateway on the server, Remote Control is unavailable, and you reach the session through the browser or SSH instead.

## FAQ

**Can I use an API key or OpenRouter from the official mobile app?** No. Both official mobile paths require a claude.ai subscription login.

**Does my laptop need to stay on?** For Remote Control, yes. For cloud sessions and servers, no.

**What if I just want to approve a prompt while away?** Any of the above works. SSH + tmux is the lowest-friction fallback.

## Official documentation

Plan requirements and limits for Remote Control and cloud sessions change. Check Anthropic's pages before relying on them:

- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Cloud sessions (Claude Code on the web): https://code.claude.com/docs/en/claude-code-on-the-web.md
- Mobile app: https://code.claude.com/docs/en/mobile.md
- Authentication: https://code.claude.com/docs/en/authentication.md
