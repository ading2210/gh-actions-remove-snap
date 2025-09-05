#!/bin/bash

set -e

if [ "$EUID" != "0" ]; then
  echo "error: this script must be run as root"
  exit 1
fi

#uninstall snapd
systemctl disable --now snapd
apt purge -y snapd
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap

#create a apt pref to avoid installing it
echo '
Package: snapd
Pin: release a=*
Pin-Priority: -10
' > /etc/apt/preferences.d/disable-snap.pref

#install the mozilla apt repo to avoid using snap for firefox
install -d -m 0755 /etc/apt/keyrings 
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- > /etc/apt/keyrings/packages.mozilla.org.asc
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' > /etc/apt/preferences.d/mozilla 

#update the apt indexes to apply all of our changes 
apt-get update
apt-get install firefox -y --allow-downgrades