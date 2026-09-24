export TFGM_HOST := env_var_or_default("TFGM_HOST", "poseidon")
export TFGM_REPO := env_var_or_default("TFGM_REPO", "Shlfmd/TFGM")
export TFGM_DIR := env_var_or_default("TFGM_DIR", "/home/notashelf/tfg")
export TFGM_BACKUPS := env_var_or_default("TFGM_BACKUPS", "/home/notashelf/backups/tfgm")
export TFGM_USER := env_var_or_default("TFGM_USER", "notashelf")
export TFGM_SERVICE := env_var_or_default("TFGM_SERVICE", "tfgm")
export TFGM_JAVA := env_var_or_default("TFGM_JAVA", "java")
export TFGM_FORGE := env_var_or_default("TFGM_FORGE", "1.20.1-47.4.13")
export TFGM_RCON_PORT := env_var_or_default("TFGM_RCON_PORT", "25575")
export TFGM_SYSTEMCTL := env_var_or_default("TFGM_SYSTEMCTL", "sudo systemctl")
export TFGM_JOURNALCTL := env_var_or_default("TFGM_JOURNALCTL", "journalctl")

default:
    @just --list

# Sync the pinned parent and mirror its latest released version in pakku.json.
sync-upstream:
    java -jar pakku.jar fork sync
    PAKKU_JAVA="$TFGM_JAVA" bash scripts/sync-upstream-version.sh

# Export the pack and check the serverpack for junk.
export:
    bash scripts/export-pack.sh

# Pakku export ignores .gitignore, so fail if it bundled cache/history dirs.
scan-export:
    bash scripts/scan-export.sh

# Host downloads a released serverpack and swaps the content dirs it ships.
# mods is mandatory; world*/ and launcher files stay. Restart after.
[positional-arguments]
deploy tag="latest":
    bash scripts/deploy-release.sh "$TFGM_HOST" "$TFGM_DIR" "$TFGM_REPO" "$1"

# SSH to the host and start.
start:
    bash scripts/server-service.sh start

# Stop the unit if running, then re-spawn it.
restart:
    bash scripts/server-service.sh restart

stop:
    bash scripts/server-service.sh stop

[positional-arguments]
status *args:
    bash scripts/server-service.sh status "$@"

# Tail the server journal (last N lines, then follow).
[positional-arguments]
logs lines="80":
    bash scripts/server-service.sh logs "$1"

# Archive world + server state into the backups dir on the host, keeping the 10
# newest. Run `just stop` first for a cold, consistent snapshot.
backup:
    bash scripts/backup-server.sh "$TFGM_HOST" "$TFGM_DIR" "$TFGM_BACKUPS"

# One RCON command via the harness, e.g. `just cmd list`.
[positional-arguments]
cmd +command:
    bash scripts/server-service.sh cmd "$@"

# Restart the JVM in place; the unit and firewall stay up.
mc-restart:
    bash scripts/server-service.sh mc-restart

# RCON console (tfgmctl over the SSH relay).
console:
    bin/tfgmctl --host "$TFGM_HOST" --service "$TFGM_SERVICE" --rcon-port "$TFGM_RCON_PORT"

# Install the Forge dedicated server runtime on the host (once).
bootstrap:
    bash scripts/bootstrap-forge.sh "$TFGM_HOST" "$TFGM_DIR" "$TFGM_JAVA" "$TFGM_FORGE"

# Push Discord Integration config to the host (prompts for secrets on first run).
setup-discord:
    bash scripts/setup-discord.sh "$TFGM_HOST" "$TFGM_DIR"

# Enable RCON in server.properties, generating ./.rcon-secret if absent.
setup-rcon:
    bash scripts/setup-rcon.sh "$TFGM_HOST" "$TFGM_DIR" "$TFGM_RCON_PORT"

# Render host scripts with Nix store paths and install the harness.
stage:
    bash scripts/stage-server.sh "$TFGM_HOST" "$TFGM_DIR" "$TFGM_RCON_PORT" "$TFGM_FORGE"
