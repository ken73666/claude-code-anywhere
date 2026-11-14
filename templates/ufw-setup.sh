#!/usr/bin/env bash
# ufw-setup.sh - minimal firewall: deny incoming, allow outgoing, rate-limited SSH.
# Purpose: first-run firewall for a fresh Debian/Ubuntu server.
# Usage:   sudo bash ufw-setup.sh
# SSH is allowed BEFORE enabling, otherwise you would lock yourself out.
# Uncomment the 80/443 lines only if you serve a website from this machine.

set -euo pipefail

# Deny incoming by default, allow outgoing
ufw default deny incoming
ufw default allow outgoing

# Allow SSH with rate limiting (an IP making many connections quickly is temporarily denied) before enabling
ufw limit 22/tcp

# ufw allow 80/tcp
# ufw allow 443/tcp

# --force skips the interactive confirmation
ufw --force enable
ufw status verbose
