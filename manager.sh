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
    # TODO: check if the server has stopped before continuing
    # for now just wait a minute
    sleep 60
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

# function to warn the user on the server about the upcoming restart
warn_restart() {
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 1 minute for scheduled maintenance." Enter
    sleep 30
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 30 seconds." Enter
    sleep 20
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 10 seconds." Enter
    sleep 5
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 5 seconds." Enter
    sleep 1
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 4 seconds." Enter
    sleep 1
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 3 seconds." Enter
    sleep 1
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 2 seconds." Enter
    sleep 1
    tmux send-keys -t "$SERVER_NAME" "say Server will restart in 1 second." Enter
    sleep 1
}

# checks if it is Monday (remote backup day)
# returns 0 if true, 1 if false
is_it_monday() {
    if [ "$(date +%u)" -eq 1 ]; then
        return 0
    else
        return 1
    fi
}

# checks if the server has been idle since boot
# (nobody has played since the server started, so no need to backup)
# returns 0 if true, 1 if false
is_server_idle_since_boot() {
    pane_output=$(tmux capture-pane -t "$SERVER_NAME" -p)

    # get the last line of the output
    last_line=$(echo "$pane_output" | tail -n 1)

    # check if the last line contains the "done message"
    if [[ "$last_line" == *"[Server thread/INFO]: Done"* ]]; then
        return 0
    else
        return 1
    fi
}

#? === MAIN LOOP ===

while true; do
    update_server
    start_server
    sleep_until_4am
    if is_server_idle_since_boot; then
        stop_server
        if is_it_monday; then
            remote_backup
        fi
        continue
    else
        warn_restart
        stop_server
        local_backup
        if is_it_monday; then
            remote_backup
        fi
    fi
done
