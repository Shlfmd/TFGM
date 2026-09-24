#!/usr/bin/env bash
# Resolve a published serverpack locally; the host downloads and stages it.
set -euo pipefail

if (($# != 4)) || [[ -z $1 || -z $2 || -z $3 || -z $4 ]]; then
	printf 'usage: deploy-release.sh HOST DIR REPO TAG\n' >&2
	exit 2
fi
host=$1 dir=$2 repo=$3 tag=$4
if [[ $host == -* ]]; then
	printf 'error: HOST must not begin with a dash\n' >&2
	exit 2
fi

cd "$(dirname "$0")/.."

# ssh joins its command arguments into a remote shell command. Quote each
# argument for that shell before invoking bash on the other end.
shell_quote() {
	local value=${1//\'/\'\\\'\'}
	printf "'%s'" "$value"
}

if [[ $tag == latest ]]; then
	tag=$(gh release view --repo "$repo" --json tagName -q .tagName)
fi
[[ -n $tag ]] || {
	printf 'error: no release tag found\n' >&2
	exit 1
}
asset=$(gh release view "$tag" --repo "$repo" --json assets \
	-q '[.assets[].name | select(endswith("-serverpack.zip"))][0] // empty')
[[ -n $asset ]] || {
	printf 'error: no serverpack asset in release %s\n' "$tag" >&2
	exit 1
}

# GitHub release download paths must be URL path segments, not shell input.
for segment in "${repo%%/*}" "${repo#*/}" "$tag" "$asset"; do
	if [[ ! $segment =~ ^[a-zA-Z0-9._-]+$ ]]; then
		printf 'error: unsafe release path segment: %s\n' "$segment" >&2
		exit 1
	fi
done
if [[ $repo != */* || $repo == */*/* ]]; then
	printf 'error: expected REPO as owner/name\n' >&2
	exit 2
fi
url="https://github.com/$repo/releases/download/$tag/$asset"
printf 'deploying %s (%s), downloaded on %s\n' "$tag" "$asset" "$host"
remote_script="bash -s -- $(shell_quote "$dir") $(shell_quote "$url") $(shell_quote "$asset")"
remote="nix-shell -p libarchive curl --run $(shell_quote "$remote_script")"
scripts/ssh.sh ssh "$host" "$remote" <scripts/deploy-serverpack.sh
printf 'deployed %s on %s, start or restart to apply\n' "$tag" "$host"
