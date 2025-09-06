#!/bin/bash

set -e

echo "removing snapd..."
echo
echo "script options:"
echo "reinstall_firefox: ${REINSTALL_FIREFOX:-false}"
echo "disable_man_db: ${DISABLE_MAN_DB:-false}"

if [ "$EUID" != "0" ]; then
  echo "error: this script must be run as root"
  exit 1
fi

#optionally disable man-db updating to speed up apt
if [ "$DISABLE_MAN_DB" = "true" ]; then
  echo 'set man-db/auto-update false' | debconf-communicate
  dpkg-reconfigure man-db
fi

#uninstall snapd
systemctl disable --now snapd
apt-get purge -y snapd
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap

#create a apt pref to avoid installing it
echo '
Package: snapd
Pin: release a=*
Pin-Priority: -10
' > /etc/apt/preferences.d/disable-snap.pref

#optionally install the mozilla apt repo to avoid using snap for firefox
if [ "$REINSTALL_FIREFOX" = "true" ]; then
  install -d -m 0755 /etc/apt/keyrings 
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- > /etc/apt/keyrings/packages.mozilla.org.asc
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
  ' > /etc/apt/preferences.d/mozilla 

  apt-get update
  apt-get install firefox -y --allow-downgrades
else
  apt-mark hold firefox
fi