#!/bin/bash
# Quick reference for common QEMU testing commands

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║            QEMU Testing - Quick Reference                    ║
╚══════════════════════════════════════════════════════════════╝

SETUP (Run once)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ./scripts/qemu-setup.sh


START VM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ./scripts/qemu-run.sh

  Login: ubuntu / ubuntu
  Exit:  Ctrl+A then X


AUTO TEST (from host, in another terminal)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ./scripts/qemu-test.sh


CONNECT TO VM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # SSH
  ssh -p 2222 ubuntu@localhost

  # Copy files TO VM
  scp -P 2222 file.txt ubuntu@localhost:~/

  # Copy files FROM VM
  scp -P 2222 ubuntu@localhost:~/file.txt ./


MANUAL TESTING (inside VM)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # Build
  make clean && make all

  # Install module
  sudo insmod build/elf_det.ko

  # Check loaded
  lsmod | grep elf_det

  # Test with user program
  ./build/proc_elf_ctrl

  # Or test manually
  echo "1" | sudo tee /proc/elf_det/pid
  sudo cat /proc/elf_det/det

  # Check logs
  sudo dmesg | tail -20

  # Unload
  sudo rmmod elf_det


CLEANUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # Remove QEMU environment
  rm -rf scripts/qemu-env/

  # Start fresh
  ./scripts/qemu-setup.sh


TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  - First boot takes 1-2 minutes for cloud-init
  - VM is completely isolated - crash won't affect host
  - KVM acceleration used if available
  - Change default password after first login


MORE INFO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  See: scripts/README.md

EOF
