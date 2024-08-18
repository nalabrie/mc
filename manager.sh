#!/usr/bin/env bash

set -euo pipefail

# Description:  Server manager script.

#? === SETUP ===

# source variables, functions, and constants
source "$(dirname "$0")/vars.sh"

# cd to server directory
cd "$SERVER_ROOT/$SERVER_NAME"

#? === FUNCTIONS ===

# update the server
# returns 0 if successful, 1 if failed
update_server() {
    if ! "$UPDATE_SERVER_SCRIPT_PATH"; then
        echo "Failed to update the server."
        return 1
    fi
    return 0
}

# start the server
# server starts in a tmux session named $SERVER_NAME
start_server() {
    echo "Starting server with $RAM GB of RAM..."
    tmux send-keys -t "$SERVER_NAME" "$RUN_SERVER_COMMAND" Enter
}

# stop the server
stop_server() {
    echo "Stopping server..."
    tmux send-keys -t "$SERVER_NAME" "stop" Enter
}

# create a local backup
# returns 0 if successful, 1 if failed
local_backup() {
    if [ "$LOCAL_BACKUP_DIR" = "DISABLE" ]; then
        echo "Local backups are disabled."
        return 0
    fi

    if ! "$LOCAL_BACKUP_SCRIPT_PATH"; then
        echo "Failed to create a local backup."
        return 1
    fi
    return 0
}

# create a remote backup
# returns 0 if successful, 1 if failed
remote_backup() {
    if [ "$REMOTE_BACKUP_DIR" = "DISABLE" ]; then
        echo "Remote backups are disabled."
        return 0
    fi

    if ! "$REMOTE_BACKUP_SCRIPT_PATH"; then
        echo "Failed to create a remote backup."
        return 1
    fi
    return 0
}

#? === MAIN LOOP ===

# update the server
# if the update fails, exit
if ! update_server; then
    exit 1
fi

# start the server
start_server
