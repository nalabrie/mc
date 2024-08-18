#!/usr/bin/env bash

set -euo pipefail

#? === FUNCTIONS ===

# start all tmux sessions with a given name
# pane will be 150x50 characters in size (to limit line wrapping when detached)
# $1: session name
start_tmux_sessions() {
    tmux new-session -d -s "$1" -x 150 -y 50
    tmux new-session -d -s "${1}_manager" -x 150 -y 50
}

# stop all tmux sessions with a given name
# $1: session name
stop_tmux_sessions() {
    tmux kill-session -t "$1"
    tmux kill-session -t "${1}_manager"
}

#? === SETUP ===

# cd to this script's directory
cd "$(dirname "$0")"

# source variables
source vars.sh

# check if python virtual environment exists
# if not, create it
if [ ! -d ".venv" ]; then
    python -m venv .venv --upgrade-deps
fi

# activate python virtual environment
# shellcheck disable=SC1091
source .venv/bin/activate

# install/update python dependencies
pip install --upgrade -r requirements.txt

# ensure all paths exist (sourced from vars.sh)
# if they are not executable, make them executable
for path in "$UPDATE_SERVER_SCRIPT_PATH" "$LOCAL_BACKUP_SCRIPT_PATH" "$REMOTE_BACKUP_SCRIPT_PATH" "$RUN_SERVER_SCRIPT_PATH" "$MANAGER_SCRIPT_PATH"; do
    if [ ! -f "$path" ]; then
        echo "Error: $path does not exist."
        exit 1
    fi
done
chmod +x "$UPDATE_SERVER_SCRIPT_PATH" "$LOCAL_BACKUP_SCRIPT_PATH" "$REMOTE_BACKUP_SCRIPT_PATH" "$RUN_SERVER_SCRIPT_PATH" "$MANAGER_SCRIPT_PATH"

#? === UPDATE & START SERVER ===

# cd to server directory
cd "$SERVER_ROOT/$SERVER_NAME"

# make tmux sessions for the server and the server manager
start_tmux_sessions "$SERVER_NAME"

# update the server
# run the server if the update is successful
if "$UPDATE_SERVER_SCRIPT_PATH" "$SERVER_ROOT/$SERVER_NAME"; then
    tmux send-keys -t "$SERVER_NAME" "\"$RUN_SERVER_SCRIPT_PATH\" $RAM" Enter
else
    echo "Failed to update the server. Server not started."
    stop_tmux_sessions "$SERVER_NAME"
    exit 1
fi

# ? === START MANAGER ===

# run the manager script
tmux send-keys -t "${SERVER_NAME}_manager" "$MANAGER_SCRIPT_PATH" Enter
