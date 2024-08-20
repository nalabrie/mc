#!/usr/bin/env python

# Description:
#   This script will download the latest stable version of the Minecraft server.jar file.
#   It will check if the server is already up-to-date and will only download the server file if an update is needed.
#   The file "server_version.txt" will be created to store the currently installed server version.
#   The downloaded server file will be validated using the sha1 hash provided by Mojang.
#
# Usage:
#   This script is not intended to be ran directly.
#   The manager.sh script will call this script before starting the server.
#
#   However, the script can be ran manually from the command line with the following command:
#   python UpdateServer.py [version_id]
#
#   Things to keep in mind when running the script manually:
#     - "version_id" is optional. Specifies a server version to download by ID (default: latest stable version).
#     - Files will be downloaded to the current working directory.
#     - The script will exit with a return code of 0 on success and 1 on failure.

from hashlib import sha1
from sys import argv, exit

from requests import get

# ? === GLOBALS ===

server_version_manifest: dict
latest_version_id: str


# ? === FUNCTIONS ===


def generate_sha1(file) -> str:
    """
    Generates a sha1 hash of a file and returns it
    :param file: file to hash (must already be opened)
    :return: string of file's sha1 hash
    """

    file.seek(0)
    result_hash = sha1(file.read())
    return result_hash.hexdigest()


def update() -> bool:
    """
    Update the server
    :return: "True" on successful update
    """

    global server_version_manifest, latest_version_id

    # loop through dict entries in the version manifest json
    for i in range(len(server_version_manifest["versions"])):
        if server_version_manifest["versions"][i]["id"] == latest_version_id:
            # dict that stores server "url" and "sha1"
            server_info: dict = get(
                server_version_manifest["versions"][i]["url"]
            ).json()["downloads"]["server"]
            break

    # check if a download url was found
    if "server_info" in locals():
        with open("server.jar", "w+b") as f:
            # download the server jar file
            print(
                f"downloading server version {latest_version_id} from:\n{server_info['url']}"
            )
            f.write(get(server_info["url"]).content)
            print("download complete")

            # validate server file
            if generate_sha1(f) != server_info["sha1"]:
                print("[ERROR]: downloaded server file failed validation")
                return False
    else:
        print("[ERROR]: server file could not be downloaded")
        return False

    # update "current version" file
    with open("server_version.txt", "w+") as f:
        f.write(latest_version_id)

    # update successful
    return True


def check_for_update() -> bool:
    """
    Check if the server needs to be updated
    :return: "True" when an update is needed
    """

    global latest_version_id

    try:
        with open("server_version.txt", "r") as f:
            current_version: str = f.readline()
        if current_version == latest_version_id:
            return False
        else:
            return True
    except FileNotFoundError:
        return True


# ? === MAIN ===


def main(args: list[str]) -> int:
    """
    Main function. Checks if the Minecraft server needs to be updated and then performs the update.
    Optionally, user can provide a specific server version to download instead of the latest.
    :param args: server version ID (optional)
    :return: 0 = update success,
             1 = update failure
    """

    global server_version_manifest, latest_version_id

    # download version manifest json
    server_version_manifest = get(
        "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    ).json()

    if len(args) == 2:
        # use user-provided version ID
        latest_version_id = args[1]
    elif len(args) > 2:
        print("[ERROR]: user provided too many arguments (max: 1)\naborting")
        return 1
    else:
        # find latest stable version ID
        latest_version_id = server_version_manifest["latest"]["release"]

    # do update
    if check_for_update():
        print("server update required")
        if update():
            # update successful
            return 0
        else:
            # update failed
            return 1
    else:
        print("server already up to date")
        return 0


if __name__ == "__main__":
    # run main function and exit script with its return code
    exit(main(argv))
