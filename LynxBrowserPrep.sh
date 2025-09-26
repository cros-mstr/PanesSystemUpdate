#!/bin/bash
# Script to Enable Lynx for Panes
PANESType=StatefulApplicationThirdPartySource
PANESSource=ThirdParty
UPDATE_TITLE="Lynx-Panes Linker"
UPDATE_DESC="First Update of Lynx Command."
VERSION=1
echo "This app is purely to link Lynx to work with Panes. Lynx is not made or maintained by the Panes team."
sudo apt install lynx
mkdir Applications
cd Applications
curl -L -o LYNXer.sh "https://github.com/cros-mstr/PanesSystemUpdate/raw/main/LYNXer.sh"
echo "Lynx is now installed!"
echo "To use, type lynx frogfind.com  or any other website."}
sleep 2
echo "Early-Call Initialization Variables"
echo "Early-Bird Initializer Prepped."}