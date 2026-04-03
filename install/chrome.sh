#!/bin/bash
# Install Google Chrome and set as default browser

if command -v google-chrome-stable &>/dev/null; then
  echo "  Google Chrome is already installed."
else
  echo "  Downloading Google Chrome..."
  CHROME_DEB="/tmp/google-chrome-stable.deb"
  wget -q -O "$CHROME_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

  echo "  Installing Google Chrome..."
  sudo dpkg -i "$CHROME_DEB" || sudo apt-get install -f -y
  rm -f "$CHROME_DEB"
fi

# Set Chrome as default browser
echo "  Setting Chrome as default browser..."
xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null || true
xdg-mime default google-chrome.desktop x-scheme-handler/http
xdg-mime default google-chrome.desktop x-scheme-handler/https
xdg-mime default google-chrome.desktop text/html
