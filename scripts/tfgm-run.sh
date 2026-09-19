#!/usr/bin/env bash
# shellcheck disable=SC2016
# Run the server under bwrap (uid 65534, host net) on openjdk17.
set -euo pipefail
cd "@DIR@"

JVM_ARGS=()
if [ -f user_jvm_args.txt ]; then
	while IFS= read -r line; do
		line="${line%%#*}"
		for token in $line; do
			JVM_ARGS+=("$token")
		done
	done <user_jvm_args.txt
fi

exec "@BWRAP@/bin/bwrap" \
	--unshare-pid \
	--unshare-ipc \
	--unshare-uts \
	--unshare-cgroup \
	--unshare-user \
	--uid 65534 \
	--gid 65534 \
	--share-net \
	--die-with-parent \
	--ro-bind /nix /nix \
	--ro-bind /etc /etc \
	--ro-bind /sys /sys \
	--ro-bind /run /run \
	--dev /dev \
	--proc /proc \
	--tmpfs /tmp \
	--bind "@DIR@" /data \
	--chdir /data \
	"@BASH@/bin/bash" -c '
	set -euo pipefail
	forge_args_file=""
	for candidate in libraries/net/minecraftforge/forge/*/unix_args.txt; do
		[ -f "$candidate" ] || continue
		forge_args_file="$candidate"
		break
	done
	if [ -z "$forge_args_file" ]; then
		echo "error: Forge unix_args.txt is missing" >&2
		exit 1
	fi

	exec "@JAVA@/bin/java" "$@" "@$forge_args_file" nogui
	' -- "${JVM_ARGS[@]}"
