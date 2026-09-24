#!/usr/bin/env bash
set -euo pipefail

[[ $# == 2 ]] || {
	printf 'usage: backup-on-host.sh DIR BACKUPS\n' >&2
	exit 2
}
dir=$1
backups=$2
[[ -d $dir ]] || {
	printf 'error: server directory does not exist: %s\n' "$dir" >&2
	exit 1
}
cd -P -- "$dir"

items=()
for item in world world_nether world_the_end config server.properties eula.txt \
	ops.json whitelist.json banned-players.json banned-ips.json usercache.json server-icon.png; do
	[[ -e $item ]] && items+=("$item")
done
if ((${#items[@]} == 0)); then
	printf 'error: nothing to back up in %s\n' "$dir" >&2
	exit 1
fi

mkdir -p -- "$backups"
ts=$(date +%Y-%m-%d-%H%M)
out=$backups/tfgm-$ts.tar.zst
if [[ -e $out ]]; then
	printf 'error: backup already exists: %s\n' "$out" >&2
	exit 1
fi
# A failed tar must not leave a completed-looking backup.
tmp=$(mktemp -- "$backups/.tfgm-backup.XXXXXXXX.tar.zst")
trap 'rm -f -- "$tmp"' EXIT
printf -v tar_command 'tar --zstd -cf %q' "$tmp"
for item in "${items[@]}"; do
	printf -v quoted '%q' "$item"
	tar_command+=" $quoted"
done
nix-shell -p zstd gnutar --run "$tar_command"
mv -- "$tmp" "$out"
printf 'backup: %s (%s)\n' "$out" "$(du -h -- "$out" | cut -f1)"

# Order by modification time without splitting filenames that contain spaces.
count=0
while IFS= read -r -d '' record; do
	((count += 1))
	((count <= 10)) && continue
	rm -f -- "${record#* }"
done < <(find "$backups" -maxdepth 1 -type f -name 'tfgm-*.tar.zst' -printf '%T@ %p\0' | sort -zrn)
