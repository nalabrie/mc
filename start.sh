#!/usr/bin/env bash

set -euo pipefail

#? === CONSTANTS ===

# **********************************************
# *** CHANGE THESE VALUES TO SUIT YOUR SETUP ***
# ***      DO NOT CHANGE ANYTHING ELSE       ***
# **********************************************

SERVER_ROOT="$HOME/.local/srv" # root directory for all servers
SERVER_NAME="chubharbor"       # server name (server directory name)
RAM=10                         # server RAM (in GB)
LOCAL_BACKUP_DIR="DISABLE"     # local backup directory (set to DISABLE to disable local backups)
REMOTE_BACKUP_DIR="DISABLE"    # remote backup directory (set to DISABLE to disable remote backups)

# **********************************************
# *** DO NOT CHANGE ANYTHING BELOW THIS LINE ***
# **********************************************

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

# cd to script directory
cd "$(dirname "$0")"

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

# get paths to scripts
UPDATE_SERVER_SCRIPT_PATH="$(pwd)/UpdateServer.py"  # updates the server
LOCAL_BACKUP_SCRIPT_PATH="$(pwd)/local_backup.sh"   # local server backup script
REMOTE_BACKUP_SCRIPT_PATH="$(pwd)/remote_backup.sh" # remote server backup script
RUN_SERVER_SCRIPT_PATH="$(pwd)/run_server.sh"       # runs the server
MANAGER_SCRIPT_PATH="$(pwd)/manager.py"             # server manager script

# ensure all paths exist
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

# ? === BACKUPS ===

# start the server manager
# TODO: unsure if I want to do it the "Windows way" or move everything to bash scripts & cron jobs
