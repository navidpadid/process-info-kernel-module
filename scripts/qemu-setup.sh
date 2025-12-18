#!/bin/bash
# QEMU Testing Environment Setup Script
# This script downloads and configures a QEMU VM for safe kernel module testing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QEMU_DIR="$SCRIPT_DIR/qemu-env"
UBUNTU_VERSION="24.04"
IMAGE_URL="https://cloud-images.ubuntu.com/releases/${UBUNTU_VERSION}/release/ubuntu-${UBUNTU_VERSION}-server-cloudimg-amd64.img"

echo "==================================================="
echo "QEMU Testing Environment Setup"
echo "==================================================="

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "ERROR: QEMU is not installed!"
    echo ""
    echo "Install QEMU with:"
    echo "  Ubuntu/Debian: sudo apt-get install qemu-system-x86 qemu-utils cloud-image-utils"
    echo "  macOS:         brew install qemu"
    echo "  Fedora:        sudo dnf install qemu-system-x86 qemu-img cloud-utils"
    exit 1
fi

# Create QEMU directory
mkdir -p "$QEMU_DIR"
cd "$QEMU_DIR"

# Download Ubuntu cloud image if not exists
if [ ! -f "ubuntu-${UBUNTU_VERSION}.img" ]; then
    echo "Downloading Ubuntu ${UBUNTU_VERSION} cloud image..."
    wget -O "ubuntu-${UBUNTU_VERSION}.img" "$IMAGE_URL"
    echo "Resizing image to 20GB..."
    qemu-img resize "ubuntu-${UBUNTU_VERSION}.img" 20G
else
    echo "Ubuntu image already exists, skipping download..."
fi

# Create cloud-init user-data
echo "Creating cloud-init configuration..."
cat > user-data.yaml << 'EOF'
#cloud-config
hostname: kernel-test-vm
manage_etc_hosts: true

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    # Default password: ubuntu (change after first login)
    passwd: $6$rounds=4096$saltsalt$IjcDQqnK7H8e4Bm5nLz0.ZJNnPkF/0Qd.2Y9xNJ9R0B9dAr1e5E4zJ2Q3B6Q8Q9B3B6Q8Q9B3B6Q8Q9B3B6Q8Q.

packages:
  - build-essential
  - linux-headers-generic
  - kmod
  - git
  - vim
  - net-tools

runcmd:
  - echo "ubuntu:ubuntu" | chpasswd
  - apt-get update
  - apt-get install -y linux-headers-$(uname -r) || true
  - systemctl enable serial-getty@ttyS0.service
  - systemctl start serial-getty@ttyS0.service

write_files:
  - path: /etc/ssh/sshd_config.d/90-testing.conf
    content: |
      PermitRootLogin no
      PasswordAuthentication yes
      PubkeyAuthentication yes

power_state:
  mode: reboot
  timeout: 300
  condition: True
EOF

# Generate cloud-init ISO
echo "Generating cloud-init seed image..."
if command -v cloud-localds &> /dev/null; then
    cloud-localds seed.img user-data.yaml
elif command -v genisoimage &> /dev/null; then
    # Fallback method
    genisoimage -output seed.img -volid cidata -joliet -rock user-data.yaml
else
    echo "WARNING: cloud-localds not found. You may need to install cloud-image-utils"
    echo "Creating minimal seed image..."
    # Create a minimal ISO with user-data
    mkdir -p seed
    cp user-data.yaml seed/
    genisoimage -output seed.img -volid cidata -joliet -rock seed/ 2>/dev/null || \
        echo "ERROR: Could not create seed image. Please install cloud-image-utils or genisoimage"
fi

echo ""
echo "==================================================="
echo "Setup Complete!"
echo "==================================================="
echo ""
echo "VM Details:"
echo "  - OS: Ubuntu ${UBUNTU_VERSION}"
echo "  - Username: ubuntu"
echo "  - Password: ubuntu"
echo "  - SSH Port: 2222 (forwarded from host)"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/qemu-run.sh"
echo "  2. Login with username 'ubuntu' and password 'ubuntu'"
echo "  3. Copy your module and test it safely!"
echo ""
echo "Note: First boot may take 1-2 minutes for cloud-init setup"
echo "==================================================="
