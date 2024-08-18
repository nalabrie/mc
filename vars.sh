# shellcheck disable=SC2034

# **********************************************
# *** CHANGE THESE VALUES TO SUIT YOUR SETUP ***
# ***      DO NOT CHANGE ANYTHING ELSE       ***
# **********************************************

SERVER_ROOT="$HOME/.local/srv" # root directory for all servers
SERVER_NAME="chubharbor"       # server name (server directory name)
RAM=10                         # server RAM (in GB)
LOCAL_BACKUP_DIR="DISABLE"     # local backup directory (set to DISABLE to disable local backups)
REMOTE_BACKUP_DIR="DISABLE"    # remote backup directory (set to DISABLE to disable remote backups)

# **********************************************
# *** DO NOT CHANGE ANYTHING BELOW THIS LINE ***
# **********************************************

cd "$(dirname "$0")" || exit 1
UPDATE_SERVER_SCRIPT_PATH="$(pwd)/UpdateServer.py"  # updates the server
LOCAL_BACKUP_SCRIPT_PATH="$(pwd)/local_backup.sh"   # local server backup script
REMOTE_BACKUP_SCRIPT_PATH="$(pwd)/remote_backup.sh" # remote server backup script
RUN_SERVER_SCRIPT_PATH="$(pwd)/run_server.sh"       # runs the server
MANAGER_SCRIPT_PATH="$(pwd)/manager.sh"             # server manager script
