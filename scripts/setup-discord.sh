#!/usr/bin/env bash
# Generate .discord.env (if absent) and push the Discord Integration config to
# the server.
#
# Usage: setup-discord.sh <host> <dir>
set -euo pipefail
if (($# != 2)) || [[ -z $1 || $1 == -* || -z $2 || $2 == -* ]]; then
	printf 'usage: setup-discord.sh HOST DIR\n' >&2
	exit 2
fi
host="$1"
dir="$2"
cd "$(dirname "$0")/.."

umask 077
if [[ -L .discord.env ]]; then
	echo 'error: .discord.env must not be a symlink' >&2
	exit 1
fi
if [[ ! -e .discord.env ]]; then
	read -rsp "Discord bot token: " tok && echo
	read -rsp "Discord channel ID: " ch && echo
	read -rsp "Discord admin role IDs (comma-separated): " roles && echo
	(
		set -C
		printf 'BOT_TOKEN=%s\nBOT_CHANNEL=%s\nADMIN_ROLE_IDS=%s\n' "$tok" "$ch" "$roles" >.discord.env
	)
	echo "wrote .discord.env"
fi
[[ -f .discord.env ]] || {
	echo 'error: .discord.env must be a regular file' >&2
	exit 1
}
chmod 600 .discord.env

template="config/Discord-Integration.toml.example"
test -f "$template" || {
	echo "error: template not found at $template" >&2
	exit 1
}
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
bash scripts/render-discord-config.sh .discord.env "$template" >"$tmp"

scripts/ssh.sh ssh "$host" "mkdir -p -- $(printf '%q' "$dir/config")"
scripts/ssh.sh scp "$tmp" "$host:$dir/config/Discord-Integration.toml"
echo "wrote $dir/config/Discord-Integration.toml on $host"
