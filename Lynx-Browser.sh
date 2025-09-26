#!/bin/bash
# Script to launch a text-based document editor (nano by default)
PANESType=StatefulApplicationThirdPartySource
PANESSource=ThirdParty
UPDATE_TITLE="Lynx-Panes Linker"
UPDATE_DESC="First Update of Lynx Command."
VERSION=1
echo "This app is purely to link Lynx to work with Panes. Lynx is not made or maintained by the Panes team."
sudo apt install Lynx
mkdir Applications
cd Applications
git clone
echo "Lynx is now installed!"
echo "To use, type lynx frogfind.com  or any other website."