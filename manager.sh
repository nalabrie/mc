#!/usr/bin/env bash

set -euo pipefail

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
        error "Failed to update the server."
        return 1
    fi
    return 0
}

# start the server
# server starts in a tmux session named $SERVER_NAME
start_server() {
    info "Starting server with $RAM GB of RAM..."
    tmux send-keys -t "$SERVER_NAME" "$RUN_SERVER_COMMAND" Enter
}

# stop the server
stop_server() {
    info "Stopping server..."
    tmux send-keys -t "$SERVER_NAME" "stop" Enter
}

# create a local backup
# returns 0 if successful, 1 if failed
local_backup() {
    if [ "$LOCAL_BACKUP_DIR" = "DISABLE" ]; then
        warn "Local backups are disabled."
        return 0
    fi

    if ! "$LOCAL_BACKUP_SCRIPT_PATH"; then
        error "Failed to create a local backup."
        return 1
    fi
    return 0
}

# create a remote backup
# returns 0 if successful, 1 if failed
remote_backup() {
    if [ "$REMOTE_BACKUP_DIR" = "DISABLE" ]; then
        warn "Remote backups are disabled."
        return 0
    fi

    if ! "$REMOTE_BACKUP_SCRIPT_PATH"; then
        error "Failed to create a remote backup."
        return 1
    fi
    return 0
}

# sleep until 4am
sleep_until_4am() {
    # get the current time
    current_time=$(date +%s)

    # get the time for 4am
    # if it's already past 4am, set the time for 4am tomorrow
    if [ "$(date +%H)" -ge 4 ]; then
        target_time=$(date -d "tomorrow 4:00" +%s)
    else
        target_time=$(date -d "today 4:00" +%s)
    fi

    # calculate the time to sleep
    sleep_time=$((target_time - current_time))

    # calculate the wait time
    wait_time=$(date -u -d @"$sleep_time" +'%-H hours, %-M minutes, %-S seconds')

    # sleep until 4am
    info "Sleeping until 4 AM... ($wait_time from now)"
    sleep "$sleep_time"
}

#? === MAIN LOOP ===

# update the server
# if the update fails, exit
if ! update_server; then
    exit 1
fi

# start the server
start_server
