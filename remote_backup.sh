#!/usr/bin/env bash

set -euo pipefail

# Description:
#   This script creates a remote backup of a Minecraft server.
#   It creates a 7z archive of the server directory and stores it in the remote backup directory.
#   Uses 7z or 7zz to create the archive, whichever is available. If both are installed, 7zz will be used.
#   The archive is named like: SERVER_NAME_YYYY-MM-DD_HH-MM-SS.7z
#
# Usage:
#   This script is not intended to be ran directly.
#   It should instead be run by the manager.sh script.

#? === SETUP ===

source "$(dirname "$0")/vars.sh"
cd "$SERVER_ROOT"

# check if the server directory exists
if [ ! -d "$SERVER_NAME" ]; then
    error "Server directory '$SERVER_NAME' does not exist, cannot make a remote backup."
    exit 1
fi

# check if the remote backup directory exists
if [ ! -d "$REMOTE_BACKUP_DIR" ]; then
    error "Remote backup directory '$REMOTE_BACKUP_DIR' does not exist, cannot make a remote backup."
    exit 1
fi

# check for either 7z or 7zz
# only one of them is required
# if both are installed, 7zz will be used
if command -v 7zz &>/dev/null; then
    SEVENZ=7zz
elif command -v 7z &>/dev/null; then
    SEVENZ=7z
else
    error "7zip (7z or 7zz) is not installed, cannot make a remote backup."
    exit 1
fi

#? === BACKUP ===

# create a 7z archive of the server directory
# file is named like: SERVER_NAME_YYYY-MM-DD_HH-MM-SS.7z
# -mx=7: "high" compression
"$SEVENZ" a -mx=7 "${REMOTE_BACKUP_DIR}/${SERVER_NAME}_$(date +%Y-%m-%d_%H-%M-%S).7z" "$SERVER_NAME"

# TODO: instead of just making an archive and leaving it up to the user to manage, utilize a cloud storage service API to upload the archive to the cloud automatically (for example: https://github.com/meganz/MEGAcmd)

exit 0
