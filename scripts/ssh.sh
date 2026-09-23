#!/usr/bin/env bash
# SSH/SCP wrapper used by the pack's imperative operations.
set -euo pipefail

command_name=${1:-}
shift || true
case $command_name in
ssh | scp) ;;
*)
	printf 'usage: ssh.sh ssh|scp ARG...\n' >&2
	exit 2
	;;
esac

args=(-o ControlMaster=auto -o ControlPersist=60s)
if [[ -n ${TFGM_SSH_IDENTITY_FILE:-} ]]; then
	args+=(-o IdentitiesOnly=yes -i "$TFGM_SSH_IDENTITY_FILE")
fi
if [[ -n ${TFGM_SSH_CONFIG:-} ]]; then
	args+=(-F "$TFGM_SSH_CONFIG")
fi
exec "$command_name" "${args[@]}" "$@"
