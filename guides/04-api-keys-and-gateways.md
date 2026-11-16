# API keys and third-party gateways

Last updated: 2026-11

How to point Claude Code (and Codex CLI) at your own API key, a gateway, or OpenRouter, and how to check what is actually in effect. Variable behavior below is from Anthropic's Claude Code documentation as of November 2026; check it if something looks different on your version.

## First, the trade-off

Anthropic's cloud sessions and Remote Control require a claude.ai subscription login. Per the docs, Remote Control does not support API keys and is unavailable while `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, or an `apiKeyHelper` is active, or when `ANTHROPIC_BASE_URL` points away from `api.anthropic.com`. Cloud sessions "always use your subscription credentials". So if you use a key or gateway, run Claude Code on a machine you control ([guide 01](01-run-claude-code-on-a-vps.md)).

## Which variable holds the credential?

| Variable | Sent as | Use when |
| --- | --- | --- |
| `ANTHROPIC_API_KEY` | `X-Api-Key` header | Anthropic Console key, or a gateway that says "x-api-key" |
| `ANTHROPIC_AUTH_TOKEN` | `Authorization: Bearer ...` | Gateways and relays that say "bearer token". Anthropic: if you weren't told which kind, use this |
| `apiKeyHelper` (setting) | Script prints the key | Keys that rotate or live in a secret store |
| `ANTHROPIC_BASE_URL` | Where requests go | Gateway or proxy URL. It changes where requests go, not which model answers |

Putting the credential in the wrong variable gives a 401.

## Option 1: Anthropic Console API key

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "YOUR_API_KEY"
  }
}
```

Save as `~/.claude/settings.json`, then:

```bash
chmod 600 ~/.claude/settings.json
```

When set, the key is used instead of your subscription "even if you are logged in". In interactive mode you approve it once. To go back to the subscription: `unset ANTHROPIC_API_KEY`, remove it from your shell profile and settings, relaunch.

## Option 2: gateway or relay

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://llm-gateway.example.com",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_GATEWAY_TOKEN"
  }
}
```

Use the exact URL the provider documents. An extra `/v1` or a stale value causes connection errors, 404s, or auth failures. Slow gateways may need a larger `API_TIMEOUT_MS`. If you were logged in with claude.ai, run `/logout` first to avoid an auth-conflict warning. Setting only the base URL without a credential variable keeps your saved login in use.

## Where to put it

The documented places are `~/.claude/settings.json` (all projects) and `.claude/settings.local.json` (one project). Claude Code reads the `env` block directly from the file, so it works no matter how `claude` was launched, including background agents and systemd units. Shell-only exports do not reliably reach those.

Never put credentials in a project's committed `.claude/settings.json`. Anthropic warns that file is shared with everyone who clones the repository. If you use `.claude/settings.local.json`, add it to `.gitignore` first.

If the same variable is set both by a shell export and in the settings `env` block, docs from different vendors disagree on which wins. Configure it in one place only.

## Verify

Inside Claude Code run `/status`. You should see an `API key` or `Auth token` row, and an `Anthropic base URL` row if you set one. In the same shell:

```bash
env | grep ANTHROPIC
```

shows what the process inherited. Tools like direnv can load a stale key from a project `.env` file.

Credential precedence, highest first (from Anthropic's authentication docs): cloud-provider credentials (Bedrock/Vertex/Foundry), `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_API_KEY`, `apiKeyHelper` output, `CLAUDE_CODE_OAUTH_TOKEN`, then the `/login` subscription. A gateway credential variable beats a saved login; the login stays saved and unused while the variable is set.

## apiKeyHelper (keys from a secret store)

```json
{
  "apiKeyHelper": "/usr/local/bin/print-anthropic-key"
}
```

The script must print only the key to stdout and exit 0. A banner or log line breaks it. `/login` does nothing while a helper is set, because the helper outranks a saved login.
