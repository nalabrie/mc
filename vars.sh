# shellcheck disable=SC2034

# Description:
#   This script contains variables, functions, and constants that are used by most other scripts in this project.
#   It also performs checks to ensure that all user supplied input is valid and all needed files/folders exist.
#   It should be sourced by other scripts, not ran directly.
#
# Usage:
#   Edit the "USER VARIABLES" section to suit your setup.

#? === USER VARIABLES ===

# **********************************************
# *** CHANGE THESE VALUES TO SUIT YOUR SETUP ***
# ***      DO NOT CHANGE ANYTHING ELSE       ***
# **********************************************

SERVER_ROOT="$HOME/.local/srv" # root directory for all servers (parent directory of your server directory)
SERVER_NAME="example_name"     # server name (server directory name)
RAM=10                         # server RAM (in GB)
LOCAL_BACKUP_DIR="DISABLE"     # local backup directory (set to DISABLE to disable local backups)
REMOTE_BACKUP_DIR="DISABLE"    # remote backup directory (set to DISABLE to disable remote backups)

# **********************************************
# *** DO NOT CHANGE ANYTHING BELOW THIS LINE ***
# **********************************************

#? === CONSTANTS ===

# set paths to scripts
cd "$(dirname "$0")" || exit 1
UPDATE_SERVER_SCRIPT_PATH="$(pwd)/UpdateServer.py"  # updates the server
LOCAL_BACKUP_SCRIPT_PATH="$(pwd)/local_backup.sh"   # local server backup script
REMOTE_BACKUP_SCRIPT_PATH="$(pwd)/remote_backup.sh" # remote server backup script
MANAGER_SCRIPT_PATH="$(pwd)/manager.sh"             # server manager script

# command that starts the Minecraft server
# using Aikar's recommended JVM startup flags
# https://docs.papermc.io/paper/aikars-flags
RUN_SERVER_COMMAND="java -Xms${RAM}G -Xmx${RAM}G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -jar server.jar nogui"

# define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

#? === CLEANUP ===

# make sure all user supplied paths do not contain a trailing slash
SERVER_ROOT="${SERVER_ROOT%/}"
SERVER_NAME="${SERVER_NAME%/}"
LOCAL_BACKUP_DIR="${LOCAL_BACKUP_DIR%/}"
REMOTE_BACKUP_DIR="${REMOTE_BACKUP_DIR%/}"

#? === CHECKS ===

# make sure all user supplied paths are not empty
if [ -z "$SERVER_ROOT" ] || [ -z "$SERVER_NAME" ] || [ -z "$RAM" ] || [ -z "$LOCAL_BACKUP_DIR" ] || [ -z "$REMOTE_BACKUP_DIR" ]; then
    error "One or more user variables are empty in vars.sh"
    exit 1
fi

# make sure the server RAM is a number
if ! [[ "$RAM" =~ ^[0-9]+$ ]]; then
    error "Server RAM must be a number. Current value: $RAM"
    exit 1
fi

# make sure all user supplied paths exist
# unless they are set to DISABLE, which is a valid value
if [ "$LOCAL_BACKUP_DIR" != "DISABLE" ] && [ ! -d "$LOCAL_BACKUP_DIR" ]; then
    error "Local backup directory '$LOCAL_BACKUP_DIR' does not exist."
    exit 1
fi

if [ "$REMOTE_BACKUP_DIR" != "DISABLE" ] && [ ! -d "$REMOTE_BACKUP_DIR" ]; then
    error "Remote backup directory '$REMOTE_BACKUP_DIR' does not exist."
    exit 1
fi

if [ ! -d "$SERVER_ROOT" ] || [ ! -d "$SERVER_ROOT/$SERVER_NAME" ]; then
    error "Server directory '$SERVER_ROOT/$SERVER_NAME' does not exist."
    exit 1
fi

# ensure all scripts exist
for path in "$UPDATE_SERVER_SCRIPT_PATH" "$LOCAL_BACKUP_SCRIPT_PATH" "$REMOTE_BACKUP_SCRIPT_PATH" "$MANAGER_SCRIPT_PATH"; do
    if [ ! -f "$path" ]; then
        error "Script '$path' does not exist."
        exit 1
    fi
done

# if local backups are enabled, check for either 7z or 7zz
# only one of them is required
# if both are installed, 7zz will be used
if [ "$LOCAL_BACKUP_DIR" != "DISABLE" ]; then
    if ! command -v 7z &>/dev/null && ! command -v 7zz &>/dev/null; then
        error "Local backups are enabled but 7zip (7z or 7zz) is not installed. Either install 7zip or disable local backups."
        exit 1
    fi
fi

# if remote backups are enabled, check for rsync
if [ "$REMOTE_BACKUP_DIR" != "DISABLE" ] && ! command -v rsync &>/dev/null; then
    error "Remote backups are enabled but rsync is not installed. Either install rsync or disable remote backups."
    exit 1
fi

#? === FUNCTIONS ===

# start all tmux sessions with a given name
# pane will be 150x50 characters in size (to limit line wrapping when detached)
# IMPORTANT: the pane will resize to the size of the terminal when attached and will not resize back when detached
# $1: session name
start_tmux_sessions() {
    tmux new-session -d -s "$1" -x 150 -y 50
    tmux new-session -d -s "${1}_manager" -x 150 -y 50
}

# stop all tmux sessions with a given name
# $1: session name
# stop_tmux_sessions() {
#     tmux kill-session -t "$1"
#     tmux kill-session -t "${1}_manager"
# }

# define simple logging functions with color
warn() {
    echo -e "${YELLOW}[WARNING]: $1${RESET}"
}
error() {
    echo -e "${RED}[ERROR]: $1${RESET}"
}
info() {
    echo -e "${GREEN}[INFO]: $1${RESET}"
}
