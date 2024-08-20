#!/usr/bin/env bash

set -euo pipefail

#? === SETUP ===

RSYNC_COMMAND="rsync --archive -hh --partial --delete --info=stats1,progress2"
LAYERS=6 # number of backup levels

source "$(dirname "$0")/vars.sh"
cd "$SERVER_ROOT"

# check if the server directory exists
if [ ! -d "$SERVER_NAME" ]; then
    error "Server directory '$SERVER_NAME' does not exist, cannot make a local backup."
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
    info "Creating backup level $i from level $((i - 1))..."
    $RSYNC_COMMAND "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_$((i - 1))/" "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_$i"
done

info "Creating backup level 1 (latest backup)..."
$RSYNC_COMMAND "$SERVER_NAME/" "$LOCAL_BACKUP_DIR/$SERVER_NAME/lvl_1"

exit 0
