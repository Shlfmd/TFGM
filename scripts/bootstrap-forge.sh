#!/usr/bin/env bash
# Download and install the Forge dedicated-server runtime on the selected host.
set -euo pipefail

if (($# != 4)); then
	printf 'usage: %s HOST DIR JAVA FORGE_VERSION\n' "$0" >&2
	exit 2
fi
host=$1
dir=$2
java=$3
forge_version=$4
if [[ -z $host || $host == -* || -z $dir || $dir == -* || -z $java || ! $forge_version =~ ^[A-Za-z0-9._+-]+$ ]]; then
	printf 'error: expected a host, directory, Java command, and Forge version\n' >&2
	exit 2
fi

cd "$(dirname "$0")/.."
if [[ ! -f scripts/ssh.sh ]] || ! command -v ssh >/dev/null; then
	printf 'error: scripts/ssh.sh and ssh are required\n' >&2
	exit 1
fi

# ssh joins its arguments into a remote shell command, so quote each one.
remote_quote() {
	printf '%q' "$1"
}

scripts/ssh.sh ssh "$host" "bash -s -- $(remote_quote "$dir") $(remote_quote "$java") $(remote_quote "$forge_version")" <<'REMOTE'
set -euo pipefail
dir=$1
java=$2
forge_version=$3
command -v "$java" >/dev/null || { printf 'error: Java is unavailable: %s\n' "$java" >&2; exit 1; }
if ! command -v curl >/dev/null && ! command -v wget >/dev/null; then
	echo 'error: curl or wget is required on the host' >&2
	exit 1
fi
mkdir -p -- "$dir"
cd "$dir"
tmp=$(mktemp -d .forge-install.XXXXXXXXXX)
trap 'rm -rf -- "$tmp"' EXIT
installer="$tmp/forge-installer.jar"
url="https://maven.minecraftforge.net/net/minecraftforge/forge/$forge_version/forge-$forge_version-installer.jar"
if command -v curl >/dev/null; then
	curl -fSL -o "$installer" "$url" || { command -v wget >/dev/null && wget -O "$installer" "$url"; }
else
	wget -O "$installer" "$url"
fi
"$java" -jar "$installer" --installServer
rm -f -- run.bat
printf 'eula=true\n' >eula.txt
printf 'installed\n'
REMOTE
printf 'Forge %s installed on %s. Next: just setup-rcon && just setup-discord && just stage && just deploy && just start\n' "$forge_version" "$host"
