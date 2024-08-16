#!/usr/bin/env bash

set -euo pipefail

#? === CONSTANTS ===

# **********************************************
# *** CHANGE THESE VALUES TO SUIT YOUR SETUP ***
# ***      DO NOT CHANGE ANYTHING ELSE       ***
# **********************************************

SERVER_ROOT="$HOME/srv"     # root directory for all servers
SERVER_NAME="chubharbor"    # server name (server directory name)
RAM=10                      # server RAM (in GB)
LOCAL_BACKUP_DIR="DISABLE"  # local backup directory (set to DISABLE to disable local backups)
REMOTE_BACKUP_DIR="DISABLE" # remote backup directory (set to DISABLE to disable remote backups)

# **********************************************
# *** DO NOT CHANGE ANYTHING BELOW THIS LINE ***
# **********************************************

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

#? === MAIN ===

# cd to server directory
cd "$SERVER_ROOT/$SERVER_NAME"

# make tmux sessions for the server and the server manager
tmux new-session -d -s "$SERVER_NAME"
tmux new-session -d -s "${SERVER_NAME}_manager"
