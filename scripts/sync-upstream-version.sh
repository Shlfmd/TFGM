#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

check_only=false
if [ "${1:-}" = "--check" ]; then
	check_only=true
elif [ "${1:-}" != "" ]; then
	echo "usage: $0 [--check]" >&2
	exit 2
fi

changelog=.pakku/parent/CHANGELOG.md
[ -f "$changelog" ] || {
	echo "error: $changelog missing; run: java -jar pakku.jar fork sync" >&2
	exit 1
}

upstream_version=$(sed -nE 's/^## \[([^]]+)\] - .*/\1/p' "$changelog" | sed -n '1p')
[ -n "$upstream_version" ] || {
	echo "error: no released version heading found in $changelog" >&2
	exit 1
}

current_version=$(jq -r '.version // empty' pakku.json)
[ -n "$current_version" ] || {
	echo "error: pakku.json has no version" >&2
	exit 1
}

if [ "$current_version" = "$upstream_version" ]; then
	echo "upstream version: $upstream_version (already synchronized)"
	exit 0
fi

if "$check_only"; then
	echo "error: pakku.json version is $current_version; upstream is $upstream_version" >&2
	exit 1
fi

PAKKU_JAVA=${PAKKU_JAVA:-java}
"$PAKKU_JAVA" -jar pakku.jar cfg --version "$upstream_version"
echo "synchronized pakku.json version: $current_version -> $upstream_version"
