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

## Option 3: OpenRouter

OpenRouter documents a Claude Code integration. Using shell exports:

```bash
export OPENROUTER_API_KEY="YOUR_OPENROUTER_KEY"
export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
export ANTHROPIC_API_KEY=""     # must be explicitly empty
```

Points that matter:

- The base URL is `https://openrouter.ai/api`, without `/v1`.
- Define the key variable before the line that references it, or the token expands to empty and you get auth errors.
- `/logout` first if you were signed in to Anthropic, then restart `claude`.
- Do not use a project `.env` file; the native install does not read it.
- OpenRouter states Claude Code "is only guaranteed to work with the Anthropic first-party provider". Anthropic's docs say it does not support routing Claude Code to non-Claude models through any gateway. Test any non-Claude model on a small task first.
- OpenRouter routes between providers behind one model name. Its provider-routing settings (`provider.order`, `provider.only`) can pin one; check OpenRouter's docs for how to apply them in your setup.

See [`templates/settings.openrouter.example.jsonc`](../templates/settings.openrouter.example.jsonc) for the settings-file form.

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

## Model variables

To pin models, use `ANTHROPIC_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, and `CLAUDE_CODE_SUBAGENT_MODEL`. `ANTHROPIC_SMALL_FAST_MODEL` is deprecated; use the Haiku variable. Model IDs change often and differ per provider. Copy them from your provider's current documentation rather than from a blog post. A `[1m]` suffix on a model ID selects a 1M context window where the model supports it.

Some vendors publish an Anthropic-compatible endpoint and a Claude Code page in their docs (DeepSeek, Kimi/Moonshot, Zhipu GLM, Alibaba Model Studio, and MiniMax all do). Those endpoints are provided by the vendors, not by Anthropic. Use their docs for URLs and model names.

## Codex CLI

Codex has its own config. Log in with an API key:

```bash
printenv OPENAI_API_KEY | codex login --with-api-key
```

For a custom provider, edit `~/.codex/config.toml` (see [`templates/codex-config.example.toml`](../templates/codex-config.example.toml)). Project-level `.codex/config.toml` cannot set providers. To change the address of the built-in OpenAI provider, set `openai_base_url` instead of defining a new provider. Codex cloud requires signing in with ChatGPT; API-key login covers local CLI use.

## Keep the key safe

- Treat it like a password. Keep it out of git.
- Set a spend limit. In the Anthropic Console, use workspaces and a workspace spend limit; OpenRouter lets you set a credit limit on an individual API key.
- Use one key per purpose so you can revoke one without breaking the others.
- Rotate: create a new key, update the server, then revoke the old one. A revoked key surfaces as "Invalid API key".
- If a key lands in a log, screenshot, or repo, revoke it immediately.
- On shared machines, `chmod 600` on every file that holds a key.

## Troubleshooting

| Symptom | Likely cause and fix |
| --- | --- |
| Auth-conflict warning | Login plus environment credential. `/status`, then unset the variable or `/logout` |
| Old key keeps coming back | It is exported in `~/.bashrc`, `~/.zshrc`, or `~/.profile`. Remove it there too |
| "Invalid API key" | Typo, trailing whitespace or newline, revoked key, or a stale key from a `.env` file |
| 401 behind a gateway | Wrong variable. Try `ANTHROPIC_AUTH_TOKEN` vs `ANTHROPIC_API_KEY` as the provider says |
| 403 | Inactive subscription, missing Console role, corporate proxy, or unsupported region |
| "This organization has been disabled" | An old `ANTHROPIC_API_KEY` from another employer or project is overriding your login. Unset it |
| 404 or connection errors | Wrong `ANTHROPIC_BASE_URL` (extra `/v1`, wrong path) |
| 400 about unrecognized fields | Upstream rejects fields Claude Code sends. Anthropic documents `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` for gateways |
| Asked to log in even though the key works | The `env` block is in a project settings file. Move it to `~/.claude/settings.json` |

## Official documentation

Check these first when something here no longer matches your version:

- Claude Code authentication: https://code.claude.com/docs/en/authentication.md
- Claude Code environment variables: https://code.claude.com/docs/en/env-vars.md
- Claude Code model configuration: https://code.claude.com/docs/en/model-config.md
- LLM gateway requirements: https://code.claude.com/docs/en/llm-gateway
- Connecting Claude Code to a gateway: https://code.claude.com/docs/en/llm-gateway-connect.md
- OpenRouter's Claude Code integration: https://openrouter.ai/docs/guides/guides/claude-code-integration
- Codex authentication: https://developers.openai.com/codex/auth
- Codex advanced configuration: https://developers.openai.com/codex/config-advanced
