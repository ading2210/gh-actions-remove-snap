#!/bin/bash

sudo systemctl disable --now snapd
sudo apt purge -y snapd
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap

echo '
Package: snapd
Pin: release a=*
Pin-Priority: -10
' | sudo tee -a /etc/apt/preferences.d/disable-snap.pref

sudo chown root:root /etc/apt/preferences.d/disable-snap.pref

if [ "$USE_MOZILLA_REPO" ]; then
  #install the mozilla apt repo to avoid using snap for firefox
  sudo install -d -m 0755 /etc/apt/keyrings 
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' > /etc/apt/preferences.d/mozilla 
fi

sudo apt-get update