#!/usr/bin/env bash

set -euo pipefail

# Description:  Server manager script.
#       Usage:  manager.sh <path to vars.sh>

#? === MAIN ===

# source given path to vars.sh (hacky, but whatever)
# shellcheck disable=SC1090
source "$1"

# update the server
# run the server if the update is successful
if "$UPDATE_SERVER_SCRIPT_PATH"; then
    tmux send-keys -t "$SERVER_NAME" "\"$RUN_SERVER_SCRIPT_PATH\" $RAM" Enter
else
    echo "Failed to update the server. Server not started."
    stop_tmux_sessions "$SERVER_NAME"
    exit 1
fi
