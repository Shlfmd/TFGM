#!/usr/bin/env bash
# shellcheck disable=SC2016
# Run the server under bwrap (uid 65534, host net) on openjdk17.
set -euo pipefail
cd "@DIR@"

JVM_ARGS=()
if [[ -f user_jvm_args.txt ]]; then
	JVM_ARGS+=("@user_jvm_args.txt")
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
	forge_args_file="libraries/net/minecraftforge/forge/@FORGE_VERSION@/unix_args.txt"
	if [ ! -f "$forge_args_file" ]; then
		echo "error: Forge unix_args.txt is missing for @FORGE_VERSION@" >&2
		exit 1
	fi
	exec "@JAVA@/bin/java" "$@" "@$forge_args_file" nogui
	' -- "${JVM_ARGS[@]}"
