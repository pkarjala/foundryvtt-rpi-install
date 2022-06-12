# Foundry VTT Dedicated Server Rasberry Pi Install Script

This script sets up the FoundryVTT Dedicated Server software [https://foundryvtt.com/](https://foundryvtt.com/) to run as a service
on a Raspberry Pi running the Raspberry Pi operating system.

It has been tested on a Raspberry Pi 4 with 8 GB of RAM running the Raspberry Pi 'Bullseye' release.

## Instructions

To begin, clone this repository by running `git clone https://github.com/pkarjala/foundryvtt-rpi-install.git`

To run, navigate to the directory where you have cloned down the repo, and run the script by typing

`setup-foundry-vtt.sh`

The user may optionally supply the filename of the .ZIP file for the FoundryVTT linux install file, and the script will
automatically expand the file in the requisite directory. 

`setup-foundry-vtt.sh -i FoundryVTT.zip`

For help, run `setup-foundry-vtt.sh --help`

## Feedback, Bugs, or Enhancements

Please leave any feedback or bugs using the Issues tab on Github.  Pull requests are welcome for enhancements.


## Technical Explanation

This script installs and creates the following:

1. Node.js LTS (16.x as of this writing)
2. A service script at `/etc/systemd/system/foundryvtt.service`
3. The directory `/opt/foundry/` which contains the `foundryvtt` and `foundrydata` folders.
4. A service user, `foundry`, which is used to run the server.
