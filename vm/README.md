# QEMU Test VM

Use a real Linux Mint desktop install for testing. A cloud image is not a good fit here because AUCOOP Mint customizes Cinnamon, desktop files, icon themes, dconf keys, MIME defaults, and the user desktop.

## Why not a cloud image?

- Linux Mint does not provide an official cloud image for this use case
- Cloud images are optimized for headless/server workflows
- They do not represent the actual Cinnamon desktop session we need to validate
- They would skip the exact installer path used on the refurbished laptops

## Recommended workflow

1. Create a clean base disk once
2. Install Linux Mint 22.3 Cinnamon from the ISO into that base disk
3. Create disposable overlays from the clean base disk for every test run
4. Run the AUCOOP installer inside an overlay VM
5. Throw the overlay away and make a new one for the next test

## Commands

Create the base disk:

```bash
./vm/create-base-disk.sh ~/vms/mint22.3-base.qcow2 40G
```

Install Mint into it:

```bash
./vm/install-mint.sh ~/Downloads/linuxmint-22.3-cinnamon-64bit.iso ~/vms/mint22.3-base.qcow2
```

During installation:

- Create the `aucoop` user
- Set the password to `aucoop`
- Enable OpenSSH after first boot: `sudo apt-get update && sudo apt-get install -y openssh-server`

Create a disposable overlay:

```bash
./vm/create-overlay.sh ~/vms/mint22.3-base.qcow2 ~/vms/mint22.3-test1.qcow2
```

Run the test overlay:

```bash
./vm/run-overlay.sh ~/vms/mint22.3-test1.qcow2 2222
```

Then connect from the host:

```bash
sshpass -p 'aucoop' ssh -p 2222 -o StrictHostKeyChecking=no aucoop@127.0.0.1
```

Example test run:

```bash
sshpass -p 'aucoop' scp -P 2222 -o StrictHostKeyChecking=no -r . aucoop@127.0.0.1:/home/aucoop/aucoop-deployment
sshpass -p 'aucoop' ssh -p 2222 -o StrictHostKeyChecking=no aucoop@127.0.0.1 'cd /home/aucoop/aucoop-deployment && bash install.sh'
```

## Existing image note

There is already a local image at:

```bash
/home/sergio/clonezilla-images/rebuild/aucoop-mint22.3.qcow2
```

It is a 466 GiB virtual disk captured from previous work, so it is not the best clean baseline for repeatable installer testing. Prefer a fresh small base disk created from the Mint ISO.
