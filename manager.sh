#!/usr/bin/env bash

set -euo pipefail

# Description:  Server manager script.
#       Usage:  WIP

source vars.sh

# update the server
# run the server if the update is successful
if "$UPDATE_SERVER_SCRIPT_PATH"; then
    tmux send-keys -t "$SERVER_NAME" "\"$RUN_SERVER_SCRIPT_PATH\" $RAM" Enter
else
    echo "Failed to update the server. Server not started."
    stop_tmux_sessions "$SERVER_NAME"
    exit 1
fi
