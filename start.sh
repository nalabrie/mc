#!/usr/bin/env bash

set -euo pipefail

# Description:
#   This script starts a Minecraft server and a server manager in tmux.
#   The server manager updates the server, starts the server, creates local backups, and creates remote backups.

# Usage:
#   Make sure to edit the "USER VARIABLES" section in vars.sh before running this script.
#   Run this script to start the Minecraft server and server manager.
#   They will run in separate tmux sessions. Use 'tmux a -t <session_name>' to attach to a session.

#? === SETUP ===

# cd to this script's directory
cd "$(dirname "$0")"

source vars.sh

# check if python virtual environment exists
# if not, create it
if [ ! -d ".venv" ]; then
    info "Creating python virtual environment..."
    python -m venv .venv --upgrade-deps
fi

# activate python virtual environment
# shellcheck disable=SC1091
source .venv/bin/activate

# install/update python dependencies
info "Installing/updating python dependencies..."
pip install --upgrade -r requirements.txt

# deactivate python virtual environment
deactivate

# if the scripts are not executable, make them executable
chmod +x "$UPDATE_SERVER_SCRIPT_PATH" "$LOCAL_BACKUP_SCRIPT_PATH" "$REMOTE_BACKUP_SCRIPT_PATH" "$MANAGER_SCRIPT_PATH"

# ? === START MANAGER ===

# cd to server directory
cd "$SERVER_ROOT/$SERVER_NAME"

info "Starting Minecraft server and server manager in tmux..."

# make tmux sessions for the server and the server manager
# they will inherit the working directory of this script
# if the sessions already exist, execution will end here
start_tmux_sessions "$SERVER_NAME"

# run the manager script
tmux send-keys -t "${SERVER_NAME}_manager" "$MANAGER_SCRIPT_PATH" Enter

info "Servers started."
info "Use 'tmux a -t $SERVER_NAME' to attach to the server console."
info "Use 'tmux a -t ${SERVER_NAME}_manager' to attach to the server manager console."
info "To detach from a tmux session, press 'Ctrl+b' then 'd'."
