#!/usr/bin/env bash
# Download and install the managed directories from a published serverpack.
set -euo pipefail

if (($# != 3)); then
	printf 'usage: deploy-serverpack.sh DIR URL ASSET\n' >&2
	exit 2
fi
dir=$1 url=$2 asset=$3
if [[ $url != https://github.com/* || ! $asset =~ ^[A-Za-z0-9._-]+-serverpack\.zip$ ]]; then
	printf 'error: expected a GitHub release serverpack URL and asset name\n' >&2
	exit 2
fi
if [[ ! -d $dir ]]; then
	printf 'error: server directory does not exist: %s\n' "$dir" >&2
	exit 1
fi
dir=$(cd -P -- "$dir" && pwd)
managed=(mods config defaultconfigs kubejs tacz DiscordIntegration-Data)
preserved=(config/Discord-Integration.toml config/bluemap/core.conf
	config/bluemap/webapp.conf DiscordIntegration-Data/Messages.toml)

tmp=$(mktemp -d -- "$dir/.deploy-serverpack.XXXXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
stage=$tmp/staged
mkdir -- "$stage"
curl -fSL --retry 3 -o "$tmp/serverpack.zip" "$url"
# libarchive rejects escaping paths; extract into a private directory before
# touching any existing server content.
bsdtar -xf "$tmp/serverpack.zip" -C "$stage"
if [[ -n $(find "$stage" -type l -print -quit) ]]; then
	printf 'error: serverpack contains a symbolic link\n' >&2
	exit 1
fi
if [[ ! -d $stage/mods || -z $(find "$stage/mods" -type f -print -quit) ]]; then
	printf 'error: serverpack has no mods/ files\n' >&2
	exit 1
fi

# Validate every destination and preserved setting before replacing anything.
for name in "${managed[@]}"; do
	[[ -d $stage/$name ]] || continue
	if [[ -L $dir/$name || (-e $dir/$name && ! -d $dir/$name) ]]; then
		printf 'error: managed path is not a directory: %s\n' "$name" >&2
		exit 1
	fi
done
for name in "${preserved[@]}"; do
	folder=${name%%/*}
	current=$dir/$name
	[[ -d $stage/$folder && -e $current ]] || continue
	if [[ -L $current || -L $dir/$folder || -L ${current%/*} ]]; then
		printf 'error: host setting is a symlink: %s\n' "$name" >&2
		exit 1
	fi
	[[ -f $current ]] || continue
	target=$stage/$name
	if [[ -e $target && ! -f $target ]]; then
		printf 'error: packaged setting is not a file: %s\n' "$name" >&2
		exit 1
	fi
	mkdir -p -- "${target%/*}"
	cp -p -- "$current" "$target"
done

swapped=()
for name in "${managed[@]}"; do
	[[ -d $stage/$name ]] || continue
	if [[ -e $dir/$name ]]; then
		rm -rf -- "${dir:?}/$name"
	fi
	mv -- "$stage/$name" "$dir/$name"
	swapped+=("$name")
done
printf 'swapped: %s from %s\n' "${swapped[*]}" "$asset"
