#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .pakku/parent/pakku-lock.json ]]; then
	printf 'error: .pakku/parent missing; run java -jar pakku.jar fork sync\n' >&2
	exit 1
fi

java -jar pakku.jar export
bash scripts/scan-export.sh
