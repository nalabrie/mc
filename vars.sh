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

UPDATE_SERVER_SCRIPT_PATH="$(dirname "$0")/UpdateServer.py"  # updates the server
LOCAL_BACKUP_SCRIPT_PATH="$(dirname "$0")/local_backup.sh"   # local server backup script
REMOTE_BACKUP_SCRIPT_PATH="$(dirname "$0")/remote_backup.sh" # remote server backup script
RUN_SERVER_SCRIPT_PATH="$(dirname "$0")/run_server.sh"       # runs the server
MANAGER_SCRIPT_PATH="$(dirname "$0")/manager.sh"             # server manager script
