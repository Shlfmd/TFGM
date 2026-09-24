#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

name=$(jq -er '.name | strings' pakku.json)
version=$(jq -er '.version | strings' pakku.json)
archive="build/serverpack/$name-$version.zip"
if [[ ! -f $archive ]]; then
	printf 'error: no serverpack at %s\n' "$archive" >&2
	exit 1
fi

entries=$(unzip -Z -1 "$archive")
if printf '%s\n' "$entries" | grep -Ei '(^|/)(cache|history)/'; then
	printf 'error: %s contains cache/history paths; clean config/ and re-export\n' "$archive" >&2
	exit 1
fi

printf 'clean: %s (%s)\n' "$archive" "$(du -h "$archive" | cut -f1)"
