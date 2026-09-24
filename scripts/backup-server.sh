#!/usr/bin/env bash
# Run locally; the backup routine is streamed to the host over SSH.
set -euo pipefail

if (($# != 3)) || [[ -z $1 || -z $2 || -z $3 ]]; then
	printf 'usage: backup-server.sh HOST DIR BACKUPS\n' >&2
	exit 2
fi
host=$1 dir=$2 backups=$3
if [[ $host == -* ]]; then
	printf 'error: HOST must not begin with a dash\n' >&2
	exit 2
fi

# ssh passes a command string through the remote login shell first.
shell_quote() {
	local value=${1//\'/\'\\\'\'}
	printf "'%s'" "$value"
}

cd "$(dirname "$0")/.."
remote="bash -s -- $(shell_quote "$dir") $(shell_quote "$backups")"
scripts/ssh.sh ssh "$host" "$remote" <scripts/backup-on-host.sh
