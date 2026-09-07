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

# shellcheck source=/dev/null
source .discord.env
test -n "${BOT_TOKEN:-}" || {
	echo "error: BOT_TOKEN is empty" >&2
	exit 1
}
test -n "${BOT_CHANNEL:-}" || {
	echo "error: BOT_CHANNEL is empty" >&2
	exit 1
}
test -n "${ADMIN_ROLE_IDS:-}" || {
	echo "error: ADMIN_ROLE_IDS is empty" >&2
	exit 1
}

template="config/Discord-Integration.toml.example"
test -f "$template" || {
	echo "error: template not found at $template" >&2
	exit 1
}
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
sed -e "s/__BOT_TOKEN__/$BOT_TOKEN/" \
	-e "s/__BOT_CHANNEL__/$BOT_CHANNEL/" \
	-e "s/__ADMIN_ROLE_IDS__/$ADMIN_ROLE_IDS/" \
	"$template" >"$tmp"
scp "$tmp" "$host:$dir/config/Discord-Integration.toml"
echo "wrote $dir/config/Discord-Integration.toml on $host"
