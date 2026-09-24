#!/usr/bin/env bash
# Render Discord Integration's TOML configuration from its narrowly-scoped env
# file. Helps us do it without evaluating secret data as shell code.
set -euo pipefail

usage() {
	printf '%s\n' 'usage: render-discord-config.sh ENV_FILE [TEMPLATE]' >&2
}

normalise_env_value() {
	local value=$1
	value=${value#"${value%%[![:space:]]*}"}
	value=${value%"${value##*[![:space:]]}"}
	if [[ $value == \"* ]]; then
		[[ ${#value} -gt 1 && ${value: -1} == \" ]] || {
			printf 'error: unterminated double-quoted Discord env value\n' >&2
			return 1
		}
		value=${value:1:${#value}-2}
	elif [[ $value == \'* ]]; then
		[[ ${#value} -gt 1 && ${value: -1} == \' ]] || {
			printf 'error: unterminated single-quoted Discord env value\n' >&2
			return 1
		}
		value=${value:1:${#value}-2}
	fi
	printf '%s' "$value"
}

source_file=${1:-}
template=${2:-config/Discord-Integration.toml.example}
[[ -n $source_file ]] || {
	usage
	exit 2
}
[[ -f $source_file && ! -L $source_file ]] || {
	printf 'error: Discord env file must be a regular file: %s\n' "$source_file" >&2
	exit 1
}
[[ -f $template ]] || {
	printf 'error: template not found: %s\n' "$template" >&2
	exit 1
}

token=''
channel=''
roles=''
while IFS= read -r line || [[ -n $line ]]; do
	[[ $line =~ ^[[:space:]]*$ || $line =~ ^[[:space:]]*# ]] && continue
	[[ $line =~ ^(BOT_TOKEN|BOT_CHANNEL|ADMIN_ROLE_IDS)=(.*)$ ]] || {
		printf 'error: invalid Discord env line\n' >&2
		exit 1
	}
	key=${BASH_REMATCH[1]}
	value=${BASH_REMATCH[2]}
	value=$(normalise_env_value "$value") || exit 1
	case $key in
	BOT_TOKEN)
		[[ -z $token ]] || {
			printf 'error: duplicate BOT_TOKEN\n' >&2
			exit 1
		}
		token=$value
		;;
	BOT_CHANNEL)
		[[ -z $channel ]] || {
			printf 'error: duplicate BOT_CHANNEL\n' >&2
			exit 1
		}
		channel=$value
		;;
	ADMIN_ROLE_IDS)
		[[ -z $roles ]] || {
			printf 'error: duplicate ADMIN_ROLE_IDS\n' >&2
			exit 1
		}
		roles=$value
		;;
	esac
done <"$source_file"

[[ -n $token ]] || {
	printf 'error: BOT_TOKEN is empty\n' >&2
	exit 1
}
[[ $token != *$'\t'* && $token != *$'\r'* ]] || {
	printf 'error: BOT_TOKEN contains an unsupported control character\n' >&2
	exit 1
}
[[ $channel =~ ^[0-9]{17,20}$ ]] || {
	printf 'error: BOT_CHANNEL must be a Discord channel ID\n' >&2
	exit 1
}
[[ -n $roles ]] || {
	printf 'error: ADMIN_ROLE_IDS is empty\n' >&2
	exit 1
}

role_toml=''
IFS=, read -r -a role_ids <<<"$roles"
for role in "${role_ids[@]}"; do
	[[ $role =~ ^[0-9]{17,20}$ ]] || {
		printf 'error: ADMIN_ROLE_IDS must be comma-separated Discord role IDs\n' >&2
		exit 1
	}
	if [[ -n $role_toml ]]; then role_toml+=', '; fi
	role_toml+="\"$role\""
done

toml_token=$(printf '%s' "$token" | sed 's/[\\"]/\\&/g')
while IFS= read -r line || [[ -n $line ]]; do
	case $line in
	*__BOT_TOKEN__*) printf '%s%s%s\n' "${line%%__BOT_TOKEN__*}" "$toml_token" "${line#*__BOT_TOKEN__}" ;;
	*__BOT_CHANNEL__*) printf '%s%s%s\n' "${line%%__BOT_CHANNEL__*}" "$channel" "${line#*__BOT_CHANNEL__}" ;;
	*__ADMIN_ROLE_IDS__*) printf '%s%s%s\n' "${line%%__ADMIN_ROLE_IDS__*}" "$role_toml" "${line#*__ADMIN_ROLE_IDS__}" ;;
	*) printf '%s\n' "$line" ;;
	esac
done <"$template"
