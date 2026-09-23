#!/usr/bin/env bash
# Generate .discord.env (if absent) and push the Discord Integration config to
# the server.
#
# Usage: setup-discord.sh <host> <dir>
set -euo pipefail
host="$1"
dir="$2"
cd "$(dirname "$0")/.."

if [ ! -f .discord.env ]; then
	read -rsp "Discord bot token: " tok && echo
	read -rsp "Discord channel ID: " ch && echo
	read -rsp "Discord admin role IDs (comma-separated): " roles && echo
	printf 'BOT_TOKEN=%s\nBOT_CHANNEL=%s\nADMIN_ROLE_IDS=%s\n' "$tok" "$ch" "$roles" >.discord.env
	chmod 600 .discord.env
	echo "wrote .discord.env"
fi

template="config/Discord-Integration.toml.example"
test -f "$template" || {
	echo "error: template not found at $template" >&2
	exit 1
}
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
bash scripts/render-discord-config.sh .discord.env "$template" >"$tmp"

scripts/ssh.sh scp "$tmp" "$host:$dir/config/Discord-Integration.toml"
echo "wrote $dir/config/Discord-Integration.toml on $host"
