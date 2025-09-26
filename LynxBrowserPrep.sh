#!/bin/bash
# Script to Enable Lynx for Panes
PANESType=StatefulApplicationThirdPartySource
PANESSource=ThirdParty
UPDATE_TITLE="Lynx-Panes Linker"
UPDATE_DESC="First Update of Lynx Command."
VERSION=1
echo "This app is purely to link Lynx to work with Panes. Lynx is not made or maintained by the Panes team."

if ! command -v lynx >/dev/null 2>&1; then
	read -p "Lynx is not installed. Would you like to install it now? (y/n): " install_choice
	if [[ $install_choice =~ ^[Yy]$ ]]; then
		sudo apt update
		sudo apt install lynx -y
		echo "Lynx has been installed."
		mkdir -p Applications
		cd Applications
		curl -L -o LYNXer.sh "https://github.com/cros-mstr/PanesSystemUpdate/raw/main/LYNXer.sh"
		echo "Lynx is now installed!"
		echo "To use, type lynx frogfind.com or any other website."
	else
		echo "Installation cancelled. Exiting."
		exit 1
	fi
else
	echo "Lynx is already installed."
	read -p "Would you like to uninstall Lynx? (y/n): " uninstall_choice
	if [[ $uninstall_choice =~ ^[Yy]$ ]]; then
		sudo apt remove lynx -y
		echo "Lynx has been uninstalled."
	else
		echo "Lynx will remain installed."
	fi
fi

sleep 2
echo "Early-Call Initialization Variables"
echo "Early-Bird Initializer Prepped."