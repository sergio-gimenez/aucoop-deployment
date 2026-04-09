# AUCOOP Mint

A lightweight, no-nonsense, windows-like OS for non-tech users with low-end refurbished hardware in mind. Built by [AUCOOP](https://aucoop.eu).

---

## What is AUCOOP Mint?

We take donated laptops, refurbish them, and send them [where they're needed](https://aucoop.upc.edu/projectes-internacionals/). AUCOOP Mint turns a stock Linux Mint install into a clean, familiar desktop that works out of the box -- no setup guides, no decisions to make.

One command, and the laptop is ready to hand over.

## What you get

- **Familiar desktop.** Looks and feels like Windows. Taskbar, start menu, wallpaper -- everything where you'd expect it.
- **Chrome + OnlyOffice.** A real browser and a full office suite (Word, Excel, PowerPoint compatible), pre-configured.
- **No bloat.** Unused apps removed. Only what matters stays.
- **AUCOOP Welcome.** A simple app that runs on first boot to finish essential setup (updates, codecs, drivers) and offers optional extras.
- **Offline Wikipedia.** One click to download a full copy of Wikipedia via [Kiwix](https://www.kiwix.org/), usable without internet.
- **Offline AI assistant.** A local AI chat powered by [llamafile](https://github.com/Mozilla-Ocho/llamafile) -- runs entirely on the laptop, no cloud needed.
- **Device registration.** Register the laptop in [Devicehub](https://www.ereuse.org/) for traceability and circular economy tracking.

## Quick start

On a fresh Linux Mint 22.x (Cinnamon) install, run:

```bash
wget -qO- https://raw.githubusercontent.com/sergio-gimenez/aucoop-deployment/master/boot.sh | bash
```

That's it. The script clones this repo and applies everything.

Or clone manually:

```bash
git clone https://github.com/sergio-gimenez/aucoop-deployment.git
cd aucoop-deployment
git submodule update --init --recursive
bash install.sh
```

## Architecture

AUCOOP Mint stays layered on top of upstream Linux Mint:

- **Base OS:** Linux Mint provides the installer, kernel, drivers, repos, and update path.
- **AUCOOP provisioning:** `install.sh` and `install/*.sh` turn a vanilla Mint install into AUCOOP Mint.
- **First boot:** AUCOOP Welcome finishes machine-specific setup after the first login.
- **Delivery:** today this is `boot.sh`; later it can also be a Mint-based AUCOOP ISO. The Clonezilla ISO remains a separate recovery path.

## How it works

The provisioning layer is a set of small shell scripts, each doing one thing:

| Script | What it does |
|---|---|
| `remove-apps.sh` | Removes Firefox, LibreOffice, Thunderbird, and other unused apps |
| `chrome.sh` | Installs Google Chrome as default browser |
| `onlyoffice.sh` | Installs OnlyOffice with familiar Word/Excel/PowerPoint icons |
| `theme.sh` | Sets light theme with Windows-like cursor |
| `wallpaper.sh` | Applies AUCOOP wallpaper to desktop and login screen |
| `panel.sh` | Pins Chrome, Files, and Office apps to the taskbar |
| `branding.sh` | Installs AUCOOP logo and menu icon |
| `aucoop-welcome.sh` | Installs the Welcome app for first-boot setup |
| `aucoop-workbench.sh` | Installs Workbench for device registration |

After `install.sh` completes, AUCOOP Welcome autostarts on first login to handle:

- system updates
- multimedia codecs
- recommended hardware drivers
- optional extras such as Kiwix and local AI
- device registration in Workbench

Once essential setup succeeds, the autostart entry removes itself and the launcher remains available from the desktop and app menu.

See [`docs/technical-reference.md`](docs/technical-reference.md) for the full repository structure and deployment workflow.

## Testing

Helper scripts in `vm/` let you test in QEMU with disposable overlay disks:

```bash
./vm/create-base-disk.sh ~/vms/mint-base.qcow2 40G
./vm/install-mint.sh ~/Downloads/linuxmint-22.3-cinnamon-64bit.iso ~/vms/mint-base.qcow2
./vm/create-overlay.sh ~/vms/mint-base.qcow2 ~/vms/test.qcow2
./vm/run-overlay.sh ~/vms/test.qcow2 2222
```

See [`vm/README.md`](vm/README.md) for details.

## Acknowledgments

AUCOOP Mint builds on great open-source work:

- [Linux Mint](https://linuxmint.com/) and the Cinnamon desktop
- [Kiwix](https://www.kiwix.org/) and the [Wikimedia Foundation](https://wikimediafoundation.org/) for offline knowledge
- [llamafile](https://github.com/Mozilla-Ocho/llamafile) by Mozilla for local AI inference
- [OnlyOffice](https://www.onlyoffice.com/) for a solid open-source office suite
- [eReuse / Devicehub](https://www.ereuse.org/) for circular electronics traceability
- [Labdoo](https://labdoo.org/) for the laptop donation network

## License

The scripts and configuration in this repository are released under the MIT License.
Linux Mint and all included software retain their original licenses.
