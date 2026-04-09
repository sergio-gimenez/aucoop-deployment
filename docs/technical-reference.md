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
git submodule update --init --recursive
bash install.sh
```

## Architecture

AUCOOP Mint follows a Mint-first layering model:

1. **Base OS:** upstream Linux Mint remains responsible for installation, hardware support, kernel, drivers, repositories, and system upgrades.
2. **AUCOOP provisioning:** `install.sh` and `install/*.sh` apply the opinionated AUCOOP defaults on top of a fresh Mint install.
3. **First boot:** AUCOOP Welcome finishes the slow, hardware-sensitive, or optional steps after login, then removes its autostart entry once essential setup succeeds.
4. **Delivery:** `boot.sh` is the current delivery entrypoint; a future Mint-based AUCOOP ISO should trigger the same provisioning flow instead of replacing it. The Clonezilla ISO stays a separate recovery tool.

## What the provisioning script does

The provisioning script takes a stock Linux Mint 22.x Cinnamon install and applies the following:

### Apps removed
- Firefox (replaced by Chrome)
- LibreOffice (replaced by OnlyOffice)
- Thunderbird, HexChat, Mint Chat, Warpinator, Webapp Manager
- Transmission (torrent client), Seahorse (keyring GUI), Hypnotix

### Apps installed
- **Google Chrome** -- default browser
- **OnlyOffice Desktop Editors** -- default for all office document types (.doc, .docx, .xls, .xlsx, .ppt, .pptx, .odt, .ods, .odp, etc.)
- **Flathub** -- added as Flatpak remote for Software Manager

### First-boot tasks deferred to AUCOOP Welcome
- **System updates** -- bring the machine up to date after the desktop is usable
- **Multimedia codecs** -- install Mint codecs on first boot instead of during base provisioning
- **Recommended hardware drivers** -- run `ubuntu-drivers autoinstall` when available
- **Optional extras** -- Kiwix, local AI, and future modules
- **Workbench registration** -- register the device after the operator has credentials ready

### Desktop customization
- **Theme**: Mint-Y-Blue (light mode always)
- **Cursor**: DMZ-White (Windows-like white pointer)
- **Wallpaper**: AUCOOP wallpaper copied to `~/Pictures/joe-mcdaniel-ZdWhZTpd_Uw-unsplash.jpg`
- **User image**: AUCOOP avatar set for the `aucoop` user
- **Desktop and menu launchers**: `Word`, `Excel`, and `PowerPoint` with Microsoft-style icons and searchable keywords
- **Panel favorites**: Chrome, Word, Excel, PowerPoint, and Software Manager pinned; Terminal not pinned
- **Software Manager icon**: Replaced with a download-arrow icon (more intuitive)
- **Search aliases**: `app store`, `download`, `download apps`, etc. find Software Manager in the menu
- **Menu cleanup**: hides duplicate ONLYOFFICE entry, old Matrix webapp entry, KDE-only duplicates, and Welcome Screen
- **AUCOOP branding**: Logo installed system-wide

## Repository structure

```
.
├── boot.sh                        # curl|bash entry point
├── install.sh                     # Main AUCOOP provisioning entrypoint
├── install/                       # Base provisioning modules for fresh Mint installs
│   ├── remove-apps.sh             #   Remove unwanted default apps
│   ├── chrome.sh                  #   Install Chrome, set as default
│   ├── onlyoffice.sh              #   Install OnlyOffice, set MIME defaults
│   ├── flathub.sh                 #   Configure Flathub remote
│   ├── theme.sh                   #   Set Mint-Y-Blue light theme
│   ├── wallpaper.sh               #   Set wallpaper
│   ├── cursor.sh                  #   Set cursor theme
│   ├── software-manager-icon.sh   #   Replace Software Manager icon
│   ├── desktop-shortcuts.sh       #   Word/Excel/PowerPoint launchers
│   ├── panel.sh                   #   Panel favorites
│   ├── search-aliases.sh          #   Menu search aliases
│   ├── menu-cleanup.sh            #   Hide duplicate/clutter launchers
│   ├── branding.sh                #   AUCOOP logo and user avatar
│   ├── aucoop-workbench.sh        #   Install Workbench
│   └── aucoop-welcome.sh          #   Install Welcome app and first-login autostart
├── assets/                        # Icons, wallpaper, logo
│   ├── software-manager-icon.png  #   Download-arrow icon (512x512)
│   ├── AUCOOP_logotip.png         #   AUCOOP logo banner
│   ├── user-image.jpg             #   AUCOOP user avatar
│   ├── wallpaper.jpg              #   AUCOOP wallpaper
│   └── icons/                     #   Office-style launcher icons
│       ├── onlyoffice-document.png
│       ├── onlyoffice-spreadsheet.png
│       └── onlyoffice-presentation.png
├── aucoop-welcome/                # First-login setup UI and optional modules
├── aucoop-workbench/              # Pinned upstream Workbench submodule
├── configs/                       # ISO/PXE deployment configs
│   ├── grub.cfg                   #   UEFI boot menu (USB ISO)
│   ├── syslinux.cfg               #   Legacy BIOS boot menu (USB ISO)
│   ├── custom-ocs                 #   Clonezilla restore script
│   ├── grub-pxe.cfg               #   GRUB config for PXE server
│   └── auto-restore.sh            #   Auto-detect disk for PXE
├── build-iso.sh                   # Clonezilla-based recovery ISO builder
└── README.md
```

## Deployment workflow

### Current provisioning flow

1. **Install** Linux Mint 22.3 Cinnamon
2. **Run** `boot.sh` or `install.sh` to apply the AUCOOP provisioning layer
3. **Log in** and let AUCOOP Welcome complete updates, codecs, drivers, and optional extras
4. **Reboot** once first-boot setup is complete

### Recovery flow

1. **Install** Linux Mint 22.3 Cinnamon on one reference machine
2. **Run** `boot.sh` to apply all AUCOOP customizations
3. **Finish** first-boot tasks in AUCOOP Welcome
4. **Capture** a Clonezilla image from the configured machine
5. **Deploy** the image to all target machines via USB ISO or PXE

### Future public installer flow

1. **Remaster** the official Mint ISO, not a machine image
2. **Bundle** AUCOOP assets and provisioning entrypoints into the live/install environment
3. **Trigger** the same AUCOOP provisioning flow automatically after Mint is installed
4. **Finish** with AUCOOP Welcome on first login

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
