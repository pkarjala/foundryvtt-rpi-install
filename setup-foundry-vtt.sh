#!/bin/bash

# setup-foundry-vtt.sh
# By Patrick Karjala
# MIT License
# This script will install all of the necessary components for running FoundryVTT as 
# a dedicated server, as well as set up a user and service to run it at the system level.
# If provided with a "foundryvtt.zip" file for installation, it will unpack it in the
# created directory. 

# This script is based on instructions in the following:
# https://foundryvtt.com/article/installation/
# https://foundryvtt.wiki/en/setup/linux-installation

# Set current directory for basis of script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#
script_name=$( cat <<EOF
Name: Setup Foundry VTT for Raspberry Pi
EOF
)
script_version=$( cat <<EOF
Version: 0.1
EOF
)
script_desc=$( cat <<EOF
Description:
	Sets up the necessary environment on a Raspberry Pi in order to run Foundry VTT.
	If the foundryvtt.zip file is also supplied, will install and configure Foundry VTT,
	and set it up as a service on the system.
EOF
)
script_usage=$( cat <<EOF
Usage:
	$ ./setup-foundry-vtt.sh [[--install-file|-i] installfile.zip] [--help|-h] [--version|-v]
EOF
)

# Rewrite gnu-style long options (command line arguments)
for arg
do
	delim=""
	case "$arg" in
		--install-file) args="${args}-i ";;
		--help) args="${args}-h ";;
		--version) args="${args}-v ";;
		*) [[ "${arg:0:1}" == "-" ]] || delim="\""
			args="${args}${delim}${arg}${delim} ";;
	esac
done
eval set -- $args

# Parse command line options
while getopts ":i:hv" OPTIONS; do
	case $OPTIONS in
		i) INSTALL_FILE=${OPTARG[@]};;
		h) echo -e "$script_name\n$script_version\n$script_desc\n$script_usage"
			exit 1;;
		v) echo -e "$script_version"
			exit 1;;
	esac
done

# Add in color sourcing
source ./lib/variables_colors

# Initial carriage return for setup.
echo -e "\n"

##########

# Perform a general update of all system services.
echo -e "${cyan}[INFO]${coloroff} Updating base system before install."
sudo apt-get update
sudo apt-get upgrade -y

# Setup and install the LTS of Node.js
# See https://nodejs.org/en/download/ for the latest LTS version
echo -e "Preparing to install Node.js."
# Determine if nodejs is already installed; if it is not, then install it.
if command -v node >/dev/null; then
	echo -e "${cyan}[INFO]${coloroff} Node.js is already installed; skipping."
else
	echo -e "${green}[OK]${coloroff} Installing the current LTS version of Node.js"
	curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
	sudo apt-get install -y nodejs
fi

##########

# Set up the foundry user to run the server
echo -e "Preparing the foundry user."
if id -u "foundry" >/dev/null 2>&1; then
	echo -e "${cyan}[INFO]${coloroff} User foundry already exists; skipping."
else
	echo -e "${green}[OK]${coloroff} Setting up foundry user."
	sudo useradd -r -U -s /usr/sbin/nologin foundry
fi 

# Set up the service to run the server
sudo cp ./lib/foundryvtt.service /etc/systemd/system/

##########

# Setup necessary directories to install Foundry.
echo -e "${cyan}[INFO]${coloroff} Setting up foundry directories in /opt"
if [ ! -d /opt/foundry ]; then
	sudo mkdir /opt/foundry /opt/foundry/foundryvtt /opt/foundry/foundrydata
fi

# Check for FoundryVTT file and set up if present.
if [[ -n $INSTALL_FILE ]]; then
	echo -e "${green}[OK]${coloroff} Foundry VTT zip file present, copying and extracting to /opt/foundry/foundryvtt."
	sudo unzip -d /opt/foundry/foundryvtt/ $INSTALL_FILE
	sudo chown -R foundry: /opt/foundry/foundryvtt /opt/foundry/foundrydata
fi

# Finished with install
echo -e "\n${green}Setup is complete!${coloroff}"
if [[ -n $INSTALL_FILE ]]; then
	echo -e "FoundryVTT has been set up in ${yellow}/opt/foundry/${coloroff}"
else
	echo -e "You will need to now download the FoundryVTT install file and place it in ${yellow}/opt/foundry/foundryvtt/${coloroff}"
	echo -e "Then, own the files by running ${yellow}sudo chown -R foundry: /opt/foundry/foundryvtt${coloroff}"
fi
echo -e "Start the server by running ${yellow}sudo service foundryvtt start${coloroff}"
echo -e "Then to access your site, please visit your Raspberry Pi's IP address at port 30000."
