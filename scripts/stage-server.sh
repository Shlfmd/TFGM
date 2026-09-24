#!/usr/bin/env bash
# Resolve host packages and stage the rendered server launcher and harness.
set -euo pipefail

if (($# != 4)); then
	printf 'usage: %s HOST DIR RCON_PORT FORGE_VERSION\n' "$0" >&2
	exit 2
fi
host=$1
dir=$2
rcon_port=$3
forge_version=$4
if [[ -z $host || $host == -* || -z $dir || $dir == -* || $dir == *$'\n'* || $dir == *$'\r'* || ! $rcon_port =~ ^[0-9]+$ || ! $forge_version =~ ^[A-Za-z0-9._+-]+$ ]]; then
	printf 'error: expected a host, directory, numeric RCON port, and Forge version\n' >&2
	exit 2
fi

cd "$(dirname "$0")/.."
for file in scripts/ssh.sh scripts/tfgm-run.sh scripts/tfgm-firewall.sh bin/tfgm-harness; do
	if [[ ! -f $file ]]; then
		printf 'error: missing %s\n' "$file" >&2
		exit 1
	fi
done
for command_name in ssh scp sed jq mktemp; do
	if ! command -v "$command_name" >/dev/null; then
		printf 'error: missing %s\n' "$command_name" >&2
		exit 1
	fi
done

# ssh joins its command arguments into a remote shell command. Quote each
# argument before it reaches that shell; the script itself travels on stdin.
remote_quote() {
	printf '%q' "$1"
}

printf 'resolving store paths on %s (openjdk17, bubblewrap, nftables, gawk, bash)\n' "$host"
paths=$(
	scripts/ssh.sh ssh "$host" 'bash -s' <<'REMOTE'
set -euo pipefail
command -v nix >/dev/null || { echo 'error: nix is missing on host' >&2; exit 1; }
mkdir -p ~/.tfgm-gcroots
# Pin only the out output: multi-output packages otherwise produce extra lines.
j=$(nix build --extra-experimental-features 'nix-command flakes' --print-out-paths --out-link ~/.tfgm-gcroots/jdk17 'nixpkgs#openjdk17^out')
b=$(nix build --extra-experimental-features 'nix-command flakes' --print-out-paths --out-link ~/.tfgm-gcroots/bwrap 'nixpkgs#bubblewrap^out')
n=$(nix build --extra-experimental-features 'nix-command flakes' --print-out-paths --out-link ~/.tfgm-gcroots/nft 'nixpkgs#nftables^out')
g=$(nix build --extra-experimental-features 'nix-command flakes' --print-out-paths --out-link ~/.tfgm-gcroots/gawk 'nixpkgs#gawk^out')
s=$(nix build --extra-experimental-features 'nix-command flakes' --print-out-paths --out-link ~/.tfgm-gcroots/bash 'nixpkgs#bash^out')
printf '%s\n' "$j" "$b" "$n" "$g" "$s"
REMOTE
)
mapfile -t store_paths <<<"$paths"
if ((${#store_paths[@]} != 5)); then
	printf 'error: expected five remote store paths, got %s\n' "${#store_paths[@]}" >&2
	exit 1
fi
for path in "${store_paths[@]}"; do
	if [[ ! $path =~ ^/nix/store/[a-zA-Z0-9._+-]+$ ]]; then
		printf 'error: invalid remote store path\n' >&2
		exit 1
	fi
done
java=${store_paths[0]}
bwrap=${store_paths[1]}
nft=${store_paths[2]}
gawk=${store_paths[3]}
bash_store=${store_paths[4]}
printf '  jdk17=%s\n' "$java"

# Escape the directory for the double-quoted strings in tfgm-run.sh, then
# escape sed's replacement metacharacters.
sed_replacement() {
	local value=$1
	value=${value//\\/\\\\}
	value=${value//\"/\\\"}
	value=${value//\$/\\$}
	value=${value//\`/\\\`}
	value=${value//&/\\&}
	value=${value//|/\\|}
	printf '%s' "$value"
}
render_dir=$(sed_replacement "$dir")
tmp=$(mktemp -d)
remote_bin=
cleanup() {
	rm -rf -- "$tmp"
	if [[ -n $remote_bin ]]; then
		scripts/ssh.sh ssh "$host" "rm -f -- $(remote_quote "$remote_bin")" || true
	fi
}
trap cleanup EXIT
sed -e "1s|^#!/usr/bin/env bash$|#!$bash_store/bin/bash|" \
	-e "s|@DIR@|$render_dir|g" -e "s|@JAVA@|$java|g" \
	-e "s|@BWRAP@|$bwrap|g" -e "s|@FORGE_VERSION@|$forge_version|g" \
	scripts/tfgm-run.sh >"$tmp/tfgm-run.sh"
sed -e "1s|^#!/usr/bin/env bash$|#!$bash_store/bin/bash|" \
	-e "s|@NFT@|$nft|g" -e "s|@GAWK@|$gawk|g" \
	scripts/tfgm-firewall.sh >"$tmp/tfgm-firewall.sh"
jq -n --arg dir "$dir" --arg port "$rcon_port" '{
	server_root: $dir,
	state_dir: ($dir + "/harness-state"),
	snapshot_dir: ($dir + "/harness-snapshot"),
	rail_data_dir: $dir,
	jvm_command: ($dir + "/tfgm-run.sh"),
	rcon_addr: ("127.0.0.1:" + $port),
	cors_origin: ["http://localhost:5173"]
}' >"$tmp/harness.json"

# The Forge bootstrap creates the server directory; staging must not guess one.
scripts/ssh.sh ssh "$host" "bash -s -- $(remote_quote "$dir")" <<'REMOTE'
set -euo pipefail
test -d "$1" || { printf 'error: server directory does not exist: %s\n' "$1" >&2; exit 1; }
REMOTE
scripts/ssh.sh scp "$tmp/tfgm-run.sh" "$tmp/tfgm-firewall.sh" "$tmp/harness.json" "$host:$dir/"
remote_bin=$(
	scripts/ssh.sh ssh "$host" 'bash -s' <<'REMOTE'
set -euo pipefail
mktemp /tmp/tfgm-harness.XXXXXXXXXX
REMOTE
)
[[ $remote_bin == /tmp/tfgm-harness.* ]] || {
	echo 'error: invalid remote temporary path' >&2
	exit 1
}
scripts/ssh.sh scp bin/tfgm-harness "$host:$remote_bin"
# sudo may prompt on the controlling terminal. Keep the installation as the
# existing interactive ssh -t command, rather than piping a script into sudo.
scripts/ssh.sh ssh -t "$host" "sudo install -m 755 $(remote_quote "$remote_bin") $(remote_quote "$dir/tfgm-harness") && rm -f -- $(remote_quote "$remote_bin")"
remote_bin=
scripts/ssh.sh ssh "$host" "bash -s -- $(remote_quote "$dir")" <<'REMOTE'
set -euo pipefail
chmod +x -- "$1/tfgm-run.sh" "$1/tfgm-firewall.sh"
REMOTE

if [[ -L .rcon-secret ]]; then
	printf 'error: .rcon-secret must not be a symlink\n' >&2
	exit 1
fi
if [[ -f .rcon-secret ]]; then
	password=$(<.rcon-secret)
	[[ -n $password && $password != *$'\n'* && $password != *$'\r'* ]] || {
		printf 'error: invalid .rcon-secret\n' >&2
		exit 1
	}
	# The password travels on stdin, not as shell code or an SSH argument.
	# shellcheck disable=SC2016 # This is literal code executed by the remote Bash.
	remote_code='set -euo pipefail; umask 077; IFS= read -r password; printf "TFGM_RCON_PASSWORD=%s\n" "$password" >"$1/.harness-env"'
	printf '%s\n' "$password" | scripts/ssh.sh ssh "$host" "bash -c $(remote_quote "$remote_code") bash $(remote_quote "$dir")"
else
	printf 'no .rcon-secret; run just setup-rcon, then just stage again\n'
fi
printf 'staged %s:%s\n' "$host" "$dir"
