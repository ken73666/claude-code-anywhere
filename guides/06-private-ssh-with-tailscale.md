# Private SSH with Tailscale

Last updated: 2026-11

A public SSH port is scanned constantly. If you reach your server only from your own devices, you can put them on a private network with Tailscale and close port 22 to the internet. [Guide 05](05-server-hardening-checklist.md) has the short version as an optional step. This guide walks through it with checks at each stage, so you do not lock yourself out.

Prerequisites: a server set up as in [guide 01](01-run-claude-code-on-a-vps.md), key-based SSH working, and a Tailscale account.

## 1. Install Tailscale on the server

```bash
# On the server
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

`tailscale up` prints a login URL. Open it on your own computer and sign in. Then `tailscale status` lists the machines on your network and their Tailscale names.

## 2. Install it on your devices

Install Tailscale on your computer and phone, and sign in to the same account. Then connect through the server's Tailscale name instead of its public IP:

```bash
ssh dev@YOUR_SERVER_TAILSCALE_NAME
```

On a phone, add the Tailscale name as the host in your SSH app (see [guide 02](02-claude-code-on-your-phone.md)). Do not continue until this works from every device you use.

## 3. Optional: Tailscale SSH

Tailscale can authenticate SSH connections itself, instead of SSH keys:

```bash
sudo tailscale set --ssh
```

Per [Tailscale's documentation](https://tailscale.com/kb/1193/tailscale-ssh), this requires an access-control policy that allows SSH to the machine; the default policy covers your own devices. Your regular `sshd` configuration is left untouched, so this step is optional and you can keep using keys.

## 4. Close the public SSH port

Only after step 2 works. These are the same commands as in guide 05:

```bash
sudo ufw allow in on tailscale0 to any port 22 proto tcp
sudo ufw delete limit 22/tcp
sudo ufw status numbered
```

Keep your current SSH session open and test a new login through the Tailscale name before you close anything. If your provider has a web console, find out how to open it first, in case you lock yourself out.

## 5. Check it from outside

From a machine that is not on your tailnet (a phone on mobile data, for example), try the public IP:

```bash
ssh -o ConnectTimeout=10 dev@YOUR_SERVER_IP
```

It should time out. On the server, `sudo ss -tlnp` still shows sshd listening, because ufw blocks the traffic rather than the service, and `sudo ufw status verbose` shows the rules in effect.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| The Tailscale name does not resolve | Run `tailscale status` on both machines and check that they are signed in to the same account |
| Tailscale SSH refuses the connection | The access-control policy does not allow SSH to this machine. Check the policy in the Tailscale admin console |
| Locked out after closing port 22 | Use your provider's web console, then re-add the rule with `sudo ufw limit 22/tcp` |
| Docker ports still reachable from outside | ufw does not filter published container ports. See the Docker note in [guide 05](05-server-hardening-checklist.md) |
