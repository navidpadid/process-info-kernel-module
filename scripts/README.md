# QEMU Testing Scripts

Scripts for safely testing the kernel module in an isolated QEMU virtual machine.

## Quick Start

```bash
# 1. Setup QEMU environment (one-time setup)
./scripts/qemu-setup.sh

# 2. Start the QEMU VM
./scripts/qemu-run.sh

# 3. In another terminal, test the module
./scripts/qemu-test.sh
```

## Script Descriptions

### `qemu-setup.sh`
- Downloads Ubuntu 24.04 cloud image
- Creates cloud-init configuration
- Sets up VM with kernel headers pre-installed
- Only needs to be run once

**Requirements:**
- `qemu-system-x86_64`
- `qemu-img`
- `cloud-localds` (from cloud-image-utils package)

### `qemu-run.sh`
- Starts the QEMU VM with appropriate settings
- Forwards SSH port 2222 to VM's port 22
- Allocates 2GB RAM and 2 CPU cores
- Enables KVM acceleration if available

**VM Access:**
- SSH: `ssh -p 2222 ubuntu@localhost`
- Password: `ubuntu`
- Exit QEMU: Press `Ctrl+A` then `X`

### `qemu-test.sh`
- Automated testing script (run from host)
- Builds module locally
- Copies files to VM via SCP
- Installs, tests, and uninstalls module
- Shows kernel logs and test results

**Prerequisites:**
- VM must be running (`qemu-run.sh`)
- SSH must be accessible

## Manual Testing

If you prefer manual testing:

```bash
# Start VM
./scripts/qemu-run.sh

# In another terminal, copy files
scp -P 2222 -r build src/Kbuild Makefile ubuntu@localhost:~/

# SSH into VM
ssh -p 2222 ubuntu@localhost

# Inside VM
cd ~/
make clean && make all
sudo make install
./build/proc_elf_ctrl
sudo make uninstall
```

## Troubleshooting

**VM won't start:**
- Ensure QEMU is installed
- Run setup script first: `./scripts/qemu-setup.sh`

**Can't connect via SSH:**
- Wait 1-2 minutes after first boot for cloud-init
- Check VM is running: `ps aux | grep qemu`

**KVM not available:**
- Normal on macOS or nested virtualization
- VM will run slower but still work

**Module won't load:**
- Check kernel headers: `uname -r` and `ls /lib/modules/$(uname -r)/build`
- Rebuild inside VM: `make clean && make all`

## Why QEMU Testing?

- Complete isolation from host kernel
- Safe crash recovery (just restart VM)
- No risk to host system stability
- Test on exact kernel version
- Easy to reset to clean state
- Reproducible testing environment

## File Locations

- VM images: `scripts/qemu-env/`
- Cloud-init: `scripts/qemu-env/user-data.yaml`
- Disk image: `scripts/qemu-env/ubuntu-24.04.img`

## Cleanup

To remove QEMU environment:
```bash
rm -rf scripts/qemu-env/
```

To start fresh:
```bash
rm -rf scripts/qemu-env/
./scripts/qemu-setup.sh
```
