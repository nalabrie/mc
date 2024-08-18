#!/usr/bin/env bash

set -euo pipefail

# Description:  Server manager script.

#? === MAIN ===

source "$(dirname "$0")/vars.sh"
cd "$SERVER_ROOT/$SERVER_NAME"

# update the server
# run the server if the update is successful
if ! "$UPDATE_SERVER_SCRIPT_PATH"; then
    echo "Failed to update the server. Server not started."
    stop_tmux_sessions "$SERVER_NAME"
    exit 1
else
    echo "Server updated successfully."
fi
