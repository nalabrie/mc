#!/usr/bin/env bash

set -euo pipefail

# Description:
#   This script creates a local backup of a Minecraft server.
#   It creates a backup of the server directory and stores it in a series of backup levels.
#   The number of backup levels is defined by the LAYERS variable.
#   The script uses rsync to create the backups.
#
# Usage:
#   This script is not intended to be ran directly.
#   It should instead be run by the manager.sh script.

#? === SETUP ===

RSYNC_COMMAND="rsync --archive -hhh --partial --delete --info=stats1,progress2"
LAYERS=6 # number of backup levels

source "$(dirname "$0")/vars.sh"
cd "$SERVER_ROOT"

# check if the server directory exists
if [ ! -d "$SERVER_NAME" ]; then
    error "Server directory '$SERVER_NAME' does not exist, cannot make a local backup."
    exit 1
fi

# check if the local backup directory exists
if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
    error "Local backup directory '$LOCAL_BACKUP_DIR' does not exist, cannot make a local backup."
    exit 1
fi

# ensure local backup directories exist
for i in $(seq 1 $LAYERS); do
    if [ ! -d "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_$i" ]; then
        mkdir -p "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_$i"
    fi
done

#? === BACKUP ===

for i in $(seq $LAYERS -1 2); do
    info "Creating backup level $i (from level $((i - 1)))..."
    $RSYNC_COMMAND "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_$((i - 1))/" "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_$i"
done

info "Creating backup level 1 (from server directory)..."
$RSYNC_COMMAND "$SERVER_NAME/" "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_1"

exit 0
