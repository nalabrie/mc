# shellcheck disable=SC2034

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

#? === CONSTANTS ===

cd "$(dirname "$0")" || exit 1
UPDATE_SERVER_SCRIPT_PATH="$(pwd)/UpdateServer.py"  # updates the server
LOCAL_BACKUP_SCRIPT_PATH="$(pwd)/local_backup.sh"   # local server backup script
REMOTE_BACKUP_SCRIPT_PATH="$(pwd)/remote_backup.sh" # remote server backup script
RUN_SERVER_SCRIPT_PATH="$(pwd)/run_server.sh"       # runs the server
MANAGER_SCRIPT_PATH="$(pwd)/manager.sh"             # server manager script

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
stop_tmux_sessions() {
    tmux kill-session -t "$1"
    tmux kill-session -t "${1}_manager"
}
