#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --harness ]]; then
	[[ $# -ge 3 ]] || exit 2
	dir=$2
	action=$3
	shift 3
	if [[ $action == cmd ]]; then
		secret="$dir/.harness-env"
		[[ -f $secret && ! -L $secret ]] || {
			printf 'error: missing harness environment\n' >&2
			exit 1
		}
		IFS= read -r line <"$secret" || [[ -n $line ]]
		[[ $line == TFGM_RCON_PASSWORD=?* ]] || {
			printf 'error: invalid harness environment\n' >&2
			exit 1
		}
		export TFGM_RCON_PASSWORD=${line#TFGM_RCON_PASSWORD=}
	fi
	exec env "TFGM_HARNESS_CONFIG=$dir/harness.json" "$dir/tfgm-harness" "$action" "$@"
fi

[[ $# -ge 1 ]] || {
	printf 'usage: server-service.sh start|restart|stop|status|logs|cmd|mc-restart [ARGS]\n' >&2
	exit 2
}
action=$1
shift
host=${TFGM_HOST:?TFGM_HOST is required}
dir=${TFGM_DIR:?TFGM_DIR is required}
service=${TFGM_SERVICE:-tfgm}
run_user=${TFGM_USER:-notashelf}
cd "$(dirname "$0")/.."

remote() {
	local args
	printf -v args '%q ' "$@"
	scripts/ssh.sh ssh "$host" "$args"
}
remote_tty() {
	local args
	printf -v args '%q ' "$@"
	scripts/ssh.sh ssh -t "$host" "$args"
}
harness() {
	local args
	printf -v args '%q ' --harness "$dir" "$@"
	scripts/ssh.sh ssh "$host" "bash -s -- $args" <scripts/server-service.sh
}
spawn() {
	remote_tty sudo systemd-run \
		"--unit=$service" --collect \
		-p 'Description=TFGM Minecraft server' -p Type=simple \
		-p "User=$run_user" -p "WorkingDirectory=$dir" \
		-p "Environment=TFGM_HARNESS_CONFIG=$dir/harness.json" \
		-p "EnvironmentFile=-$dir/.harness-env" \
		-p "ExecStartPre=+$dir/tfgm-firewall.sh open" \
		-p "ExecStopPost=+$dir/tfgm-firewall.sh close" \
		-p Restart=on-failure -p RestartSec=5 -p KillSignal=SIGTERM \
		-p TimeoutStopSec=120 -p 'SuccessExitStatus=0 143' \
		"$dir/tfgm-harness" run
}

case $action in
start)
	[[ $# == 0 ]] || exit 2
	spawn
	;;
restart)
	[[ $# == 0 ]] || exit 2
	if remote systemctl is-active --quiet "$service"; then
		remote_tty sudo systemctl stop "$service"
	else
		rc=$?
		((rc == 3)) || exit "$rc"
	fi
	spawn
	;;
stop)
	[[ $# == 0 ]] || exit 2
	read -r -a systemctl_args <<<"${TFGM_SYSTEMCTL:-sudo systemctl}"
	remote_tty "${systemctl_args[@]}" stop "$service"
	;;
status)
	[[ $# == 0 || ($# == 1 && $1 == --follow) ]] || {
		printf 'usage: just status [--follow]\n' >&2
		exit 2
	}
	harness status
	if [[ ${1:-} == --follow ]]; then
		read -r -a journalctl_args <<<"${TFGM_JOURNALCTL:-journalctl}"
		remote_tty "${journalctl_args[@]}" -u "$service" -f
	fi
	;;
logs)
	[[ $# == 1 && $1 =~ ^[0-9]+$ ]] || {
		printf 'usage: just logs [LINES]\n' >&2
		exit 2
	}
	read -r -a journalctl_args <<<"${TFGM_JOURNALCTL:-journalctl}"
	remote_tty "${journalctl_args[@]}" -u "$service" -n "$1" -f
	;;
cmd)
	[[ $# -gt 0 ]] || {
		printf 'usage: just cmd COMMAND\n' >&2
		exit 2
	}
	harness cmd "$*"
	;;
mc-restart)
	[[ $# == 0 ]] || exit 2
	harness restart
	;;
*)
	printf 'unknown service action: %s\n' "$action" >&2
	exit 2
	;;
esac
