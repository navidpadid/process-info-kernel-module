# QEMU Testing Scripts

Scripts for safely testing the Linux Process Information Kernel Module in an isolated QEMU virtual machine.

## Overview

These scripts provide a complete QEMU-based testing environment that isolates kernel module testing from your host system. This is the recommended approach for testing kernel modules as it prevents potential system crashes or instability from affecting your development machine.

## Quick Start

```bash
# 1. Setup QEMU environment (one-time setup)
./scripts/qemu-setup.sh

# 2. Start the QEMU VM
./scripts/qemu-run.sh

# 3. In another terminal, run automated tests
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
- Automated end-to-end testing script (run from host)
- Builds kernel module and user program locally
- Copies files to VM via SCP
- Installs module, runs tests, and uninstalls cleanly
- Shows kernel logs and test results
- Verifies module functionality in isolated environment

**Prerequisites:**
- VM must be running (`qemu-run.sh`)
- SSH must be accessible on port 2222

### `quick-reference.sh`
- Quick reference guide for common QEMU commands
- Display usage: `./scripts/quick-reference.sh`
- Includes setup, testing, and troubleshooting commands

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

# Run unit tests (no kernel required)
make unit

# Test kernel module
sudo make install
lsmod | grep elf_det
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

Testing kernel modules in QEMU provides critical safety benefits:

- **Complete Isolation**: Host kernel remains untouched
- **Safe Crash Recovery**: Simply restart the VM if module crashes
- **No Risk to Host**: System instability won't affect your machine
- **Kernel Version Control**: Test on specific kernel versions
- **Easy Reset**: Delete VM and start fresh anytime
- **Reproducible Environment**: Consistent testing across systems
- **CI/CD Integration**: Automate testing in isolated environments

## Testing Workflow

1. **Unit Tests First**: Run `make unit` to test pure functions locally (no kernel required)
2. **QEMU Integration**: Use QEMU scripts to test full kernel module in isolation
3. **Dev Container**: Use provided dev container for consistent build environment
4. **Production**: Only deploy to production systems after thorough QEMU testing

## File Locations

- VM images: `scripts/qemu-env/`
- Cloud-init: `scripts/qemu-env/user-data.yaml`
- Disk image: `scripts/qemu-env/ubuntu-24.04.img`

## Additional Resources

- **Main README**: [../README.md](../README.md) - Complete project documentation
- **Quick Reference**: Run `./scripts/quick-reference.sh` for command cheat sheet
- **Makefile Targets**: See main README for all available build and test targets

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

## Notes

- First boot takes 1-2 minutes for cloud-init to complete
- VM uses Ubuntu 24.04 LTS with Kernel 6.8+
- KVM acceleration is automatically enabled if available
- Default credentials: ubuntu/ubuntu (change after first login)
- SSH port forwarding: Host port 2222 → VM port 22
