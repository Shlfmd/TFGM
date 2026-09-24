#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --remote ]]; then
	[[ $# == 3 ]] || exit 2
	cd -- "$2"
	port=$3
	IFS= read -r password || [[ -n $password ]]
	[[ -n $password ]] || {
		printf 'error: empty RCON password\n' >&2
		exit 1
	}
	umask 077
	properties=$(mktemp ./server.properties.XXXXXXXX)
	trap 'rm -f -- "$properties"' EXIT
	if [[ -f server.properties ]]; then
		sed '/^enable-rcon=/d; /^rcon\.port=/d; /^rcon\.password=/d; /^broadcast-rcon-to-ops=/d' server.properties >"$properties"
	fi
	printf 'enable-rcon=true\nrcon.port=%s\nrcon.password=%s\nbroadcast-rcon-to-ops=false\n' "$port" "$password" >>"$properties"
	mv -f -- "$properties" server.properties
	exit
fi

[[ $# == 3 ]] || {
	printf 'usage: setup-rcon.sh HOST DIR PORT\n' >&2
	exit 2
}
host=$1
dir=$2
port=$3
if [[ ! $port =~ ^[0-9]{1,5}$ ]] || ((10#$port < 1 || 10#$port > 65535)); then
	printf 'error: invalid RCON port\n' >&2
	exit 2
fi
cd "$(dirname "$0")/.."
umask 077
if [[ -L .rcon-secret ]]; then
	printf 'error: .rcon-secret must not be a symlink\n' >&2
	exit 1
fi
if [[ ! -e .rcon-secret ]]; then
	(
		set -C
		openssl rand -hex 24 >.rcon-secret
	)
	printf 'generated .rcon-secret\n'
fi
[[ -f .rcon-secret ]] || {
	printf 'error: .rcon-secret must be a file\n' >&2
	exit 1
}
chmod 600 .rcon-secret
password=$(<.rcon-secret)
[[ -n $password && $password != *$'\n'* && $password != *$'\r'* ]] || {
	printf 'error: invalid RCON password in .rcon-secret\n' >&2
	exit 1
}

remote_script=$(scripts/ssh.sh ssh "$host" 'mktemp /tmp/tfgm-setup-rcon.XXXXXXXX')
[[ $remote_script =~ ^/tmp/tfgm-setup-rcon\.[A-Za-z0-9]+$ ]] || {
	printf 'error: invalid remote temporary path\n' >&2
	exit 1
}
remote_args=''
printf -v remote_args '%q ' "$remote_script" --remote "$dir" "$port"
cleanup() { scripts/ssh.sh ssh "$host" "rm -f -- $(printf '%q' "$remote_script")" || true; }
trap cleanup EXIT
scripts/ssh.sh scp scripts/setup-rcon.sh "$host:$remote_script"
printf '%s\n' "$password" | scripts/ssh.sh ssh "$host" "bash $remote_args"
printf 'RCON enabled on %s (port %s); restart to apply\n' "$host" "$port"
