# AUCOOP Mint

A lightweight, no-nonsense Linux Mint image for non-tech users with low-end refurbished hardware in mind. Built by [AUCOOP](https://aucoop.eu). 

## The idea

We take donated laptops, generally by the awesome [Labdoo](https://labdoo.org) project, refurbish them, and send them [where they're needed](https://aucoop.upc.edu/projectes-internacionals/). The software should get out of the way -- boot fast, feel familiar, and not confuse anyone. That's AUCOOP Mint.

## Principles

1. **Less is more.** No bloat, no clutter, no apps that don't add value. The fastest adoption curve is the one with the fewest surprises.
2. **Lightweight.** It has to run comfortably on every machine we deploy -- old and new alike.
3. **Windows-like UI.** Most of the people receiving these laptops know Windows. The desktop should feel familiar from day one.

## Why Linux Mint?

| | Windows | Ubuntu | Linux Mint |
|---|---|---|---|
| Open Source | No | Yes | Yes |
| Lightweight | No | Yes | Yes |
| Windows-like UI | Yes | No | Yes |
| Office Desktop tools | Yes | Possible (open source) | Possible (open source) |

Linux Mint checks every box. It's open source, lightweight, and the Cinnamon desktop is the closest thing to Windows without being Windows. That makes it the right choice for our use case.

## Quick start

On a fresh Linux Mint 22.x (Cinnamon) install, run:

```bash
wget -qO- https://raw.githubusercontent.com/sergio-gimenez/aucoop-deployment/master/boot.sh | bash
```

That's it. The script will clone this repo and apply all AUCOOP customizations.

Alternatively, clone and run manually:

```bash
git clone https://github.com/sergio-gimenez/aucoop-deployment.git
cd aucoop-deployment
bash install.sh
```

## What the script does

The install script takes a stock Linux Mint 22.x Cinnamon install and applies the following:

### Apps removed
- Firefox (replaced by Chrome)
- LibreOffice (replaced by OnlyOffice)
- Thunderbird, HexChat, Mint Chat, Warpinator, Webapp Manager
- Transmission (torrent client), Seahorse (keyring GUI)

### Apps installed
- **Google Chrome** -- default browser
- **OnlyOffice Desktop Editors** -- default for all office document types (.doc, .docx, .xls, .xlsx, .ppt, .pptx, .odt, .ods, .odp, etc.)
- **Flathub** -- added as Flatpak remote for Software Manager

### Desktop customization
- **Theme**: Mint-Y-Blue (light mode always)
- **Cursor**: DMZ-White (Windows-like white pointer)
- **Wallpaper**: Default Mint wallpaper (joe-mcdaniel)
- **Desktop shortcuts**: OnlyOffice Document, Spreadsheet, and Presentation with Microsoft-style icons
- **Software Manager icon**: Replaced with a download-arrow icon (more intuitive)
- **Search aliases**: "app store", "download", etc. find Software Manager in the menu
- **AUCOOP branding**: Logo installed system-wide

## Repository structure

```
.
├── boot.sh                        # curl|bash entry point
├── install.sh                     # Main orchestrator
├── install/                       # Modular install scripts
│   ├── remove-apps.sh             #   Remove unwanted default apps
│   ├── chrome.sh                  #   Install Chrome, set as default
│   ├── onlyoffice.sh              #   Install OnlyOffice, set MIME defaults
│   ├── flathub.sh                 #   Configure Flathub remote
│   ├── theme.sh                   #   Set Mint-Y-Blue light theme
│   ├── wallpaper.sh               #   Set wallpaper
│   ├── cursor.sh                  #   Set cursor theme
│   ├── software-manager-icon.sh   #   Replace Software Manager icon
│   ├── desktop-shortcuts.sh       #   OnlyOffice desktop shortcuts
│   ├── search-aliases.sh          #   Menu search aliases
│   └── branding.sh                #   AUCOOP logo
├── assets/                        # Icons, wallpaper, logo
│   ├── software-manager-icon.png  #   Download-arrow icon (512x512)
│   ├── AUCOOP_logotip.png         #   AUCOOP logo banner
│   └── icons/                     #   OnlyOffice shortcut icons (TODO)
│       ├── onlyoffice-document.png
│       ├── onlyoffice-spreadsheet.png
│       └── onlyoffice-presentation.png
├── configs/                       # ISO/PXE deployment configs
│   ├── grub.cfg                   #   UEFI boot menu (USB ISO)
│   ├── syslinux.cfg               #   Legacy BIOS boot menu (USB ISO)
│   ├── custom-ocs                 #   Clonezilla restore script
│   ├── grub-pxe.cfg               #   GRUB config for PXE server
│   └── auto-restore.sh            #   Auto-detect disk for PXE
├── build-iso.sh                   # ISO build script
└── README.md
```

## Deployment workflow

1. **Install** Linux Mint 22.3 Cinnamon on one machine (user: `aucoop`, password: `aucoop`)
2. **Run** `boot.sh` to apply all customizations
3. **Capture** a Clonezilla image from the configured machine
4. **Deploy** the image to all target machines via USB ISO or PXE

## Testing in QEMU

Use the real Linux Mint desktop ISO for testing, not a cloud image.

Why:

- AUCOOP Mint changes Cinnamon desktop settings, icon themes, `.desktop` launchers, MIME defaults, wallpaper, and user-facing UI
- A cloud image would not represent the real install path or desktop session used on the Lenovo laptops
- Linux Mint does not provide an official cloud image tailored to this workflow anyway

Recommended flow:

1. Create a clean base QCOW2 disk
2. Install Mint 22.3 Cinnamon from `linuxmint-22.3-cinnamon-64bit.iso`
3. Create disposable overlay disks for each test run
4. Run `install.sh` inside the overlay VM
5. Delete the overlay and repeat as needed

Helper scripts live in `vm/`:

```bash
./vm/create-base-disk.sh ~/vms/mint22.3-base.qcow2 40G
./vm/install-mint.sh ~/Downloads/linuxmint-22.3-cinnamon-64bit.iso ~/vms/mint22.3-base.qcow2
./vm/create-overlay.sh ~/vms/mint22.3-base.qcow2 ~/vms/mint22.3-test1.qcow2
./vm/run-overlay.sh ~/vms/mint22.3-test1.qcow2 2222
```

See `vm/README.md` for the full workflow.

### Building the recovery ISO

```bash
sudo apt-get install squashfs-tools xorriso syslinux-common isolinux clonezilla drbl partclone

sudo ./build-iso.sh \
    /path/to/clonezilla-images/aucoop-mint22.3-small \
    /path/to/debian-live-for-ocs.iso \
    /path/to/output/aucoop-recovery.iso
```

### PXE network deployment

For deploying to many machines at once over an isolated Ethernet network. Full guide: [Community Network Handbook -- Laptop Deployment Guide](https://github.com/aucoop/Community-Network-Handbook)

## Base image specs

- Linux Mint 22.3 "Xia" (Cinnamon edition)
- Default user: `aucoop` / password: `aucoop`
- ~12GB disk usage, compresses to ~3.6GB Clonezilla image

## License

The scripts and configuration in this repository are released under the MIT License.
The Linux Mint operating system and all included software retain their original licenses.
