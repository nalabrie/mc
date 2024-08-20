# mc

Linux port of the Minecraft server scripts that I used on Windows.

_Use at your own risk_. I maintain this for my own use, and I trust it to work for me, but I make no guarantees that it will work for you.

## What It Does

Runs a Minecraft server in its own tmux session. Also runs a "server manager" in another tmux session that will perform the following tasks each day at 4 AM:

- Stop the server
- Make a local backup of the server (_optional_)
  - Keeps 6 layers of backups using `rsync`
  - Runs daily
- Make a remote backup of the server (_optional_)
  - Makes a `7z` archive of the server to use with cloud storage
  - Runs each Monday
- Update the server
- Start the server

Output of these tasks is logged to the tmux session of the server manager.

## Dependencies

### Required

- bash
- java
  - JRE or JDK
  - Can be headless
  - Latest LTS version is recommended
- python 3
- tmux

### Optional

- 7zip (for remote backups)
- rsync (for local backups)

## Usage

### Setup

1. Clone this repository (**NOT** in your server directory).
2. Edit `vars.sh`. Only edit the section at the top of the file labeled `USER VARIABLES`.
3. ...
   - **WIP** - More detailed instructions will be added later.

### Starting

1. Run `./start.sh` to start the Minecraft server and the server manager.
2. Both the server and the manager will run in tmux sessions.
3. ...
   - **WIP** - More detailed instructions will be added later.

### Stopping

1. Attach to the Minecraft server tmux session.
2. Stop the server as you normally would (e.g. `stop`).
3. Close the tmux session with `exit`.
4. Attach to the server manager tmux session.
5. Stop the server manager with `Ctrl+C`.
   - Only do this when the manager is sleeping (i.e. not running a backup).
6. Close the tmux session with `exit`.

<!-- TODO: a stop.sh script -->
