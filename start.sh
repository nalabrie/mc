#!/usr/bin/env bash

set -euo pipefail

#? === SETUP ===

# cd to this script's directory
cd "$(dirname "$0")"

# source variables, functions, and constants
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

# ensure all paths exist (sourced from vars.sh)
# if they are not executable, make them executable
for path in "$UPDATE_SERVER_SCRIPT_PATH" "$LOCAL_BACKUP_SCRIPT_PATH" "$REMOTE_BACKUP_SCRIPT_PATH" "$MANAGER_SCRIPT_PATH"; do
    if [ ! -f "$path" ]; then
        error "'$path' does not exist."
        exit 1
    fi
done
chmod +x "$UPDATE_SERVER_SCRIPT_PATH" "$LOCAL_BACKUP_SCRIPT_PATH" "$REMOTE_BACKUP_SCRIPT_PATH" "$MANAGER_SCRIPT_PATH"

# ? === START MANAGER ===

# cd to server directory
cd "$SERVER_ROOT/$SERVER_NAME"

info "Starting server and server manager in tmux..."

# make tmux sessions for the server and the server manager
# they will inherit the current shell's environment (e.g. virtual environment, CWD, etc.)
# if the sessions already exist, execution will end here
start_tmux_sessions "$SERVER_NAME"

# run the manager script
tmux send-keys -t "${SERVER_NAME}_manager" "$MANAGER_SCRIPT_PATH" Enter

info "Server started.
Use 'tmux a -t $SERVER_NAME' to attach to the server console.
Use 'tmux a -t ${SERVER_NAME}_manager' to attach to the server manager console."
