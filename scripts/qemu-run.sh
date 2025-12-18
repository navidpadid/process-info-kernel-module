#!/bin/bash
# QEMU VM Runner Script
# Launches the QEMU VM for kernel module testing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QEMU_DIR="$SCRIPT_DIR/qemu-env"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
UBUNTU_VERSION="24.04"

# Check if setup was run
if [ ! -f "$QEMU_DIR/ubuntu-${UBUNTU_VERSION}.img" ]; then
    echo "ERROR: QEMU environment not set up!"
    echo "Run: ./scripts/qemu-setup.sh first"
    exit 1
fi

cd "$QEMU_DIR"

echo "==================================================="
echo "Starting QEMU VM for Kernel Module Testing"
echo "==================================================="
echo ""
echo "VM will start with:"
echo "  - 2GB RAM"
echo "  - 2 CPU cores"
echo "  - SSH accessible at localhost:2222"
echo ""
echo "Login credentials:"
echo "  - Username: ubuntu"
echo "  - Password: ubuntu"
echo ""
echo "To copy files to VM:"
echo "  scp -P 2222 file ubuntu@localhost:~/"
echo ""
echo "To SSH into VM:"
echo "  ssh -p 2222 ubuntu@localhost"
echo ""
echo "Press Ctrl+A then X to exit QEMU"
echo "==================================================="
echo ""

# Wait a moment for user to read
sleep 2

# Run QEMU with appropriate settings
qemu-system-x86_64 \
  -name "kernel-module-test" \
  -m 2048 \
  -smp 2 \
  -cpu host \
  -enable-kvm 2>/dev/null || true \
  -hda "ubuntu-${UBUNTU_VERSION}.img" \
  -drive file=seed.img,format=raw,if=virtio \
  -device e1000,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -serial mon:stdio \
  -display none \
  "$@"
