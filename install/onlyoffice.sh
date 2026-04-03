#!/bin/bash
# Install OnlyOffice Desktop Editors and set as default for office documents

if command -v onlyoffice-desktopeditors &>/dev/null; then
  echo "  OnlyOffice is already installed."
else
  echo "  Adding OnlyOffice GPG key and repository..."

  # Add the GPG key
  sudo mkdir -p /usr/share/keyrings
  wget -qO- https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | \
    sudo gpg --dearmor -o /usr/share/keyrings/onlyoffice.gpg

  # Add the repository
  echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" | \
    sudo tee /etc/apt/sources.list.d/onlyoffice.list > /dev/null

  sudo apt-get update -qq
  echo "  Installing OnlyOffice Desktop Editors..."
  sudo apt-get install -y onlyoffice-desktopeditors
fi

# Set OnlyOffice as default for all office document types
echo "  Setting OnlyOffice as default for office documents..."

OFFICE_MIMETYPES=(
  # Word
  application/msword
  application/vnd.openxmlformats-officedocument.wordprocessingml.document
  application/vnd.openxmlformats-officedocument.wordprocessingml.template
  application/vnd.ms-word.document.macroEnabled.12
  application/vnd.oasis.opendocument.text
  application/vnd.oasis.opendocument.text-template
  application/rtf

  # Excel
  application/vnd.ms-excel
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  application/vnd.openxmlformats-officedocument.spreadsheetml.template
  application/vnd.ms-excel.sheet.macroEnabled.12
  application/vnd.oasis.opendocument.spreadsheet
  application/vnd.oasis.opendocument.spreadsheet-template
  text/csv

  # PowerPoint
  application/vnd.ms-powerpoint
  application/vnd.openxmlformats-officedocument.presentationml.presentation
  application/vnd.openxmlformats-officedocument.presentationml.slideshow
  application/vnd.openxmlformats-officedocument.presentationml.template
  application/vnd.ms-powerpoint.presentation.macroEnabled.12
  application/vnd.oasis.opendocument.presentation
  application/vnd.oasis.opendocument.presentation-template
)

for mime in "${OFFICE_MIMETYPES[@]}"; do
  xdg-mime default onlyoffice-desktopeditors.desktop "$mime"
done
