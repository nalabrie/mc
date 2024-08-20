# shellcheck disable=SC2034

# Description:
#   This script contains variables, functions, and constants that are used by other scripts.
#   It should be sourced by other scripts, not ran directly.
#
# Usage:
#   Edit the "USER VARIABLES" section to suit your setup.

#? === USER VARIABLES ===

# **********************************************
# *** CHANGE THESE VALUES TO SUIT YOUR SETUP ***
# ***      DO NOT CHANGE ANYTHING ELSE       ***
# **********************************************

SERVER_ROOT="$HOME/.local/srv" # root directory for all servers (full path)
SERVER_NAME="chubharbor"       # server name (server directory name)
RAM=10                         # server RAM (in GB)
LOCAL_BACKUP_DIR="DISABLE"     # local backup directory (set to DISABLE to disable local backups)
REMOTE_BACKUP_DIR="DISABLE"    # remote backup directory (set to DISABLE to disable remote backups)

# **********************************************
# *** DO NOT CHANGE ANYTHING BELOW THIS LINE ***
# **********************************************

#? === CLEANUP ===

# make sure all user supplied paths do not contain a trailing slash
SERVER_ROOT="${SERVER_ROOT%/}"
SERVER_NAME="${SERVER_NAME%/}"
LOCAL_BACKUP_DIR="${LOCAL_BACKUP_DIR%/}"
REMOTE_BACKUP_DIR="${REMOTE_BACKUP_DIR%/}"

#? === CONSTANTS ===

# paths to scripts
cd "$(dirname "$0")" || exit 1
UPDATE_SERVER_SCRIPT_PATH="$(pwd)/UpdateServer.py"  # updates the server
LOCAL_BACKUP_SCRIPT_PATH="$(pwd)/local_backup.sh"   # local server backup script
REMOTE_BACKUP_SCRIPT_PATH="$(pwd)/remote_backup.sh" # remote server backup script
MANAGER_SCRIPT_PATH="$(pwd)/manager.sh"             # server manager script

# command that starts the Minecraft server
RUN_SERVER_COMMAND="java -Xms${RAM}G -Xmx${RAM}G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -jar server.jar nogui"

# define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

#? === FUNCTIONS ===

# start all tmux sessions with a given name
# pane will be 150x50 characters in size (to limit line wrapping when detached)
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
