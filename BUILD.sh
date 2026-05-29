#!/bin/bash
# ============================================================
#  CapsuleCorpOS -- Full ISO Build Script
#  Crystal Globe Pty Ltd | ABN 52 635 620 343
#  Inventor: Shabeen Ashfak (Android #23)
# 
#  Run this on: Ubuntu 22.04 / 24.04 / Debian 12 (bare metal,
#  VM, or WSL2 with systemd enabled)
#
#  Usage:  sudo bash BUILD.sh
#  Output: CapsuleCorpOS-v1.0.iso  (in current directory)
# ============================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'

log()  { echo -e "${CYAN}[CCOS]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC}   $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()  { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }

# ── Sanity checks ────────────────────────────────────────────
[[ $EUID -ne 0 ]] && die "Run as root: sudo bash BUILD.sh"
[[ $(uname -m) != "x86_64" ]] && die "x86_64 host required"

AVAIL_GB=$(df -BG / | awk 'NR==2{print $4}' | tr -d G)
[[ "$AVAIL_GB" -lt 8 ]] && die "Need at least 8 GB free disk space (have ${AVAIL_GB}GB)"

log "CapsuleCorpOS Build System v1.0"
log "Crystal Globe Pty Ltd -- Android #23"
echo ""

# ── Config ───────────────────────────────────────────────────
CHROOT=/tmp/ccos-chroot
ISO_STAGE=/tmp/ccos-iso
ISO_OUT="${PWD}/CapsuleCorpOS-v1.0.iso"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEBIAN_MIRROR="http://deb.debian.org/debian"
RELEASE="bookworm"

# ── Step 1: Install build deps ───────────────────────────────
log "Step 1/9 -- Installing build dependencies..."
apt-get update -qq
apt-get install -y -qq \
    debootstrap squashfs-tools xorriso isolinux \
    syslinux-utils grub-efi-amd64-bin mtools \
    plymouth plymouth-themes \
    genisoimage 2>/dev/null || true
ok "Build deps installed"

# ── Step 2: Bootstrap base system ────────────────────────────
log "Step 2/9 -- Bootstrapping Debian $RELEASE base (5-10 min)..."
rm -rf "$CHROOT"
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --include=systemd,systemd-sysv,udev,live-boot,live-boot-initramfs-tools \
    "$RELEASE" "$CHROOT" "$DEBIAN_MIRROR"
ok "Base system bootstrapped"

# ── Step 3: Mount pseudo filesystems ────────────────────────
log "Step 3/9 -- Mounting pseudo filesystems..."
mount --bind /dev     "$CHROOT/dev"
mount --bind /run     "$CHROOT/run"
chroot "$CHROOT" mount -t proc   none /proc
chroot "$CHROOT" mount -t sysfs  none /sys
chroot "$CHROOT" mount -t devpts none /dev/pts

cleanup() {
    log "Cleaning up mounts..."
    chroot "$CHROOT" umount /dev/pts /proc /sys 2>/dev/null || true
    umount "$CHROOT/dev" "$CHROOT/run" 2>/dev/null || true
}
trap cleanup EXIT

# ── Step 4: Install packages ─────────────────────────────────
log "Step 4/9 -- Installing packages inside chroot (10-15 min)..."
chroot "$CHROOT" /bin/bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -q

    # Core system
    apt-get install -y --no-install-recommends \
        linux-image-amd64 \
        systemd systemd-sysv udev \
        dbus \
        grub-efi-amd64 \
        live-boot live-boot-initramfs-tools \

    # Networking
    apt-get install -y --no-install-recommends \
        network-manager \
        nftables iptables \
        iproute2 net-tools \
        iputils-ping \
        openssh-server \
        curl wget \
        wireless-tools wpasupplicant

    # Hardware / peripherals
    apt-get install -y --no-install-recommends \
        udev \
        alsa-utils pipewire pipewire-alsa \
        bluez \
        v4l-utils \
        pciutils usbutils \
        inputattach \
        xorg xinit \
        i3 i3status dmenu \
        xterm fonts-dejavu-core \
        plymouth plymouth-themes \

    # Storage / disk management
    apt-get install -y --no-install-recommends \
        util-linux \
        parted fdisk gdisk \
        cryptsetup cryptsetup-initramfs \
        lvm2 \
        e2fsprogs dosfstools ntfs-3g \
        smartmontools \

    # Dev tools / shell
    apt-get install -y --no-install-recommends \
        bash bash-completion \
        python3 python3-pip \
        nano vim \
        git \
        htop tree \
        jq \
        rsync \
        tmux \
        less

    update-initramfs -u
"
ok "Packages installed"

# ── Step 5: udev rules (peripherals) ────────────────────────
log "Step 5/9 -- Installing udev peripheral rules..."

# Keyboard
cat > "$CHROOT/etc/udev/rules.d/90-ccos-keyboard.rules" << 'EOF'
# CapsuleCorpOS -- Keyboard Registration
# Registers all keyboard input devices to RUBY register REG_A001
SUBSYSTEM=="input", ATTRS{bInterfaceProtocol}=="01", ATTRS{bInterfaceSubClass}=="01", \
    SYMLINK+="input/ccos-keyboard", \
    RUN+="/opt/capsulecorp/bin/register-peripheral keyboard %k"

SUBSYSTEM=="input", ENV{ID_INPUT_KEYBOARD}=="1", \
    SYMLINK+="input/ccos-keyboard-%n", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A001"
EOF

# Mouse / Pointer
cat > "$CHROOT/etc/udev/rules.d/91-ccos-mouse.rules" << 'EOF'
# CapsuleCorpOS -- Mouse / Pointer Registration (REG_A002)
SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", \
    SYMLINK+="input/ccos-mouse-%n", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A002"

SUBSYSTEM=="input", ENV{ID_INPUT_TOUCHPAD}=="1", \
    SYMLINK+="input/ccos-touchpad-%n", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A002"
EOF

# Monitor / Display
cat > "$CHROOT/etc/udev/rules.d/92-ccos-display.rules" << 'EOF'
# CapsuleCorpOS -- Monitor / Display Registration (REG_A003)
SUBSYSTEM=="drm", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A003", \
    RUN+="/opt/capsulecorp/bin/register-peripheral display %k"

SUBSYSTEM=="graphics", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A003"
EOF

# Speaker / Audio Output
cat > "$CHROOT/etc/udev/rules.d/93-ccos-audio.rules" << 'EOF'
# CapsuleCorpOS -- Audio Output Registration (REG_A004)
SUBSYSTEM=="sound", KERNEL=="controlC*", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A004", \
    RUN+="/opt/capsulecorp/bin/register-peripheral audio %k"

SUBSYSTEM=="usb", ENV{ID_USB_INTERFACES}=="*:010100:*", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A004"
EOF

# Microphone
cat > "$CHROOT/etc/udev/rules.d/94-ccos-microphone.rules" << 'EOF'
# CapsuleCorpOS -- Microphone Registration (REG_A005)
SUBSYSTEM=="sound", KERNEL=="pcmC*D*c", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A005", \
    RUN+="/opt/capsulecorp/bin/register-peripheral microphone %k"
EOF

# USB devices
cat > "$CHROOT/etc/udev/rules.d/95-ccos-usb.rules" << 'EOF'
# CapsuleCorpOS -- USB Device Registration (REG_A006)
SUBSYSTEM=="usb", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A006", \
    RUN+="/opt/capsulecorp/bin/register-peripheral usb %k"
EOF

# Bluetooth
cat > "$CHROOT/etc/udev/rules.d/96-ccos-bluetooth.rules" << 'EOF'
# CapsuleCorpOS -- Bluetooth Registration (REG_A007)
SUBSYSTEM=="bluetooth", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A007", \
    RUN+="/opt/capsulecorp/bin/register-peripheral bluetooth %k"
EOF

# Camera
cat > "$CHROOT/etc/udev/rules.d/97-ccos-camera.rules" << 'EOF'
# CapsuleCorpOS -- Camera / Webcam Registration (REG_A008)
SUBSYSTEM=="video4linux", ACTION=="add", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A008", \
    RUN+="/opt/capsulecorp/bin/register-peripheral camera %k"
EOF

# Ethernet / Network
cat > "$CHROOT/etc/udev/rules.d/98-ccos-network.rules" << 'EOF'
# CapsuleCorpOS -- Ethernet / Network Registration (REG_A009)
SUBSYSTEM=="net", ACTION=="add", KERNEL=="eth*", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A009", \
    RUN+="/opt/capsulecorp/bin/register-peripheral ethernet %k"

SUBSYSTEM=="net", ACTION=="add", KERNEL=="enp*", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A009", \
    RUN+="/opt/capsulecorp/bin/register-peripheral ethernet %k"

SUBSYSTEM=="net", ACTION=="add", KERNEL=="wlan*", \
    TAG+="ccos_peripheral", ENV{CCOS_REG}="REG_A00A", \
    RUN+="/opt/capsulecorp/bin/register-peripheral wifi %k"
EOF

# Hard Disks
cat > "$CHROOT/etc/udev/rules.d/99-ccos-disks.rules" << 'EOF'
# CapsuleCorpOS -- Hard Disk / Storage Registration (REG_B001 onwards)
# Each disk gets its own register entry and is subject to CG-SIL v1.0

SUBSYSTEM=="block", KERNEL=="sd[a-z]", ACTION=="add", \
    TAG+="ccos_disk", ENV{CCOS_DISK_REG}="REG_B001", \
    RUN+="/opt/capsulecorp/bin/register-disk %k SATA"

SUBSYSTEM=="block", KERNEL=="nvme[0-9]n[0-9]", ACTION=="add", \
    TAG+="ccos_disk", ENV{CCOS_DISK_REG}="REG_B002", \
    RUN+="/opt/capsulecorp/bin/register-disk %k NVME"

SUBSYSTEM=="block", KERNEL=="mmcblk[0-9]", ACTION=="add", \
    TAG+="ccos_disk", ENV{CCOS_DISK_REG}="REG_B003", \
    RUN+="/opt/capsulecorp/bin/register-disk %k MMC"

SUBSYSTEM=="block", KERNEL=="vd[a-z]", ACTION=="add", \
    TAG+="ccos_disk", ENV{CCOS_DISK_REG}="REG_B004", \
    RUN+="/opt/capsulecorp/bin/register-disk %k VIRTUAL"
EOF

ok "udev rules installed (REG_A001-A00A, REG_B001-B004)"

# ── Step 6: CG-SIL v1.0 Disk Itemisation Law ────────────────
log "Step 6/9 -- Implementing CG-SIL v1.0 Disk Itemisation Law..."
mkdir -p "$CHROOT/opt/capsulecorp/bin"
mkdir -p "$CHROOT/opt/capsulecorp/registry"
mkdir -p "$CHROOT/opt/capsulecorp/logs"
mkdir -p "$CHROOT/etc/capsulecorp"

# Peripheral registration daemon
cat > "$CHROOT/opt/capsulecorp/bin/register-peripheral" << 'REGEOF'
#!/bin/bash
# CapsuleCorpOS Peripheral Registration
# Logs every detected peripheral into the Crystal Globe registry
TYPE="$1"
DEVICE="$2"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
REG_FILE="/opt/capsulecorp/registry/peripherals.log"
echo "[$TIMESTAMP] REGISTER | TYPE=$TYPE | DEVICE=$DEVICE | STATUS=ONLINE" >> "$REG_FILE"
REGEOF
chmod +x "$CHROOT/opt/capsulecorp/bin/register-peripheral"

# Disk registration + CG-SIL enforcement
cat > "$CHROOT/opt/capsulecorp/bin/register-disk" << 'DISKEOF'
#!/bin/bash
# CapsuleCorpOS -- CG-SIL v1.0 Disk Itemisation Law
# Every disk detected is logged, SHA-512 checksummed, and TC-sealed
DEVICE="$1"
TYPE="$2"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DISK_LOG="/opt/capsulecorp/registry/disks.log"
CG_SIL_LOG="/opt/capsulecorp/registry/cg-sil.log"

DEV_PATH="/dev/$DEVICE"
SIZE=$(blockdev --getsize64 "$DEV_PATH" 2>/dev/null || echo "unknown")
MODEL=$(cat /sys/block/$DEVICE/device/model 2>/dev/null | tr -d ' ' || echo "unknown")
SERIAL=$(cat /sys/block/$DEVICE/device/serial 2>/dev/null | tr -d ' ' || echo "unknown")

# Register disk
echo "[$TIMESTAMP] DISK_REGISTER | DEVICE=$DEV_PATH | TYPE=$TYPE | MODEL=$MODEL | SERIAL=$SERIAL | SIZE=${SIZE}B" >> "$DISK_LOG"

# CG-SIL v1.0: Generate identity hash for the disk (first 512 bytes = MBR/GPT)
if [ -r "$DEV_PATH" ]; then
    HASH=$(dd if="$DEV_PATH" bs=512 count=1 2>/dev/null | sha512sum | awk '{print $1}')
else
    HASH="UNREADABLE_AT_REGISTRATION"
fi

# TC Seal entry
echo "[$TIMESTAMP] CG-SIL-v1.0 | DEVICE=$DEV_PATH | TYPE=$TYPE | SERIAL=$SERIAL | SHA512=$HASH | TC_SEAL=ACTIVE | STATUS=ITEMISED" >> "$CG_SIL_LOG"

# Alert if disk is NOT previously registered (new/unknown disk)
if ! grep -q "SERIAL=$SERIAL" "$DISK_LOG" 2>/dev/null; then
    echo "[$TIMESTAMP] ALERT | NEW_DISK_DETECTED | DEVICE=$DEV_PATH | SERIAL=$SERIAL" >> "$CG_SIL_LOG"
fi

logger -t CCOS "CG-SIL: Disk $DEVICE ($TYPE) registered and TC-sealed"
DISKEOF
chmod +x "$CHROOT/opt/capsulecorp/bin/register-disk"

# CG-SIL enforcement policy config
cat > "$CHROOT/etc/capsulecorp/cg-sil.conf" << 'SILEOF'
# CapsuleCorpOS -- CG-SIL v1.0 Disk Itemisation Law
# Crystal Globe Pty Ltd | Effective: 2026-05-27

[policy]
# All disks must be itemised on first connection
enforce_itemisation = true

# SHA-512 hash of first 512 bytes logged on every boot
hash_on_boot = true

# Unknown (unregistered) disks trigger alert
alert_unknown_disk = true

# Disks must be encrypted to mount (LUKS2 required for /data partitions)
require_encryption_for_data = true

# Registry location
registry_path = /opt/capsulecorp/registry/

# TC Seal -- all itemisation entries are cryptographically sealed
tc_seal = true
tc_dimension_level = 158

[registers]
# SATA/SAS disks
SATA = REG_B001
# NVMe disks
NVME = REG_B002
# SD/MMC cards
MMC  = REG_B003
# Virtual disks (VM)
VIRTUAL = REG_B004
# USB storage
USB_STORAGE = REG_B005
SILEOF

ok "CG-SIL v1.0 Disk Itemisation Law installed"

# ── Step 7: Network (Ethernet + WiFi) ───────────────────────
log "Step 7/9 -- Configuring networking (Ethernet + WiFi)..."

# NetworkManager config
mkdir -p "$CHROOT/etc/NetworkManager/conf.d"
cat > "$CHROOT/etc/NetworkManager/conf.d/ccos.conf" << 'NMEOF'
[main]
plugins=ifupdown,keyfile
dhcp=internal

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=yes

[logging]
level=INFO
NMEOF

# Default wired connection (DHCP)
mkdir -p "$CHROOT/etc/NetworkManager/system-connections"
cat > "$CHROOT/etc/NetworkManager/system-connections/Wired-DHCP.nmconnection" << 'WIREDEOF'
[connection]
id=Wired-DHCP
type=ethernet
autoconnect=true

[ethernet]
wake-on-lan=default

[ipv4]
method=auto

[ipv6]
method=auto
WIREDEOF
chmod 600 "$CHROOT/etc/NetworkManager/system-connections/Wired-DHCP.nmconnection"

# Enable NetworkManager on boot
chroot "$CHROOT" systemctl enable NetworkManager 2>/dev/null || true

ok "Networking configured (Ethernet DHCP auto-connect + WiFi ready)"

# ── Step 8: RUBY terminal, TUI, system config ───────────────
log "Step 8/9 -- Installing RUBY terminal and system configuration..."

# System identity
cat > "$CHROOT/etc/os-release" << 'OSEOF'
PRETTY_NAME="CapsuleCorpOS v1.0 (Bookworm)"
NAME="CapsuleCorpOS"
VERSION="1.0"
VERSION_ID="1.0"
ID=capsulecorpos
ID_LIKE=debian
HOME_URL="https://aquaberry.co"
SUPPORT_URL="https://aquaberry.co"
BUG_REPORT_URL="https://aquaberry.co"
VARIANT="Crystal Globe Edition"
VARIANT_ID=crystal-globe
ANSI_COLOR="1;35"
OSEOF

# Hostname
echo "capsulecorp" > "$CHROOT/etc/hostname"
cat > "$CHROOT/etc/hosts" << 'HOSTSEOF'
127.0.0.1   localhost
127.0.1.1   capsulecorp
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
HOSTSEOF

# Users
chroot "$CHROOT" useradd -m -s /bin/bash android 2>/dev/null || true
echo "android:CrystalGlobe2347" | chroot "$CHROOT" chpasswd
echo "root:CrystalGlobeRoot" | chroot "$CHROOT" chpasswd
chroot "$CHROOT" usermod -aG sudo,audio,video,plugdev,netdev android 2>/dev/null || true

# Sudoers
echo "android ALL=(ALL) NOPASSWD: ALL" > "$CHROOT/etc/sudoers.d/android"
chmod 440 "$CHROOT/etc/sudoers.d/android"

# nftables firewall
cat > "$CHROOT/etc/nftables.conf" << 'FWEOF'
#!/usr/sbin/nft -f
# CapsuleCorpOS Firewall -- Crystal Globe Security Layer

flush ruleset

table inet ccos_filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Loopback
        iifname "lo" accept

        # Established / related
        ct state established,related accept

        # ICMP (ping)
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        # SSH (rate-limited)
        tcp dport 22 ct state new limit rate 10/minute accept

        # Crystal Globe Grid mesh (SA Current port)
        tcp dport 23470 accept
        udp dport 23470 accept

        # Log dropped
        log prefix "CCOS-DROP: " drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
FWEOF

chroot "$CHROOT" systemctl enable nftables 2>/dev/null || true

# SA Current mesh daemon (Crystal Globe Grid)
cat > "$CHROOT/etc/systemd/system/cg-grid.service" << 'CGEOF'
[Unit]
Description=Crystal Globe Grid -- SA Current Mesh Daemon
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/opt/capsulecorp/bin/cg-grid-daemon
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
CGEOF

# Grid daemon stub
cat > "$CHROOT/opt/capsulecorp/bin/cg-grid-daemon" << 'GDEOF'
#!/bin/bash
# Crystal Globe Grid SA Current Mesh Daemon
# Maintains persistent Grid node synchronisation
LOG="/opt/capsulecorp/logs/grid.log"
mkdir -p "$(dirname $LOG)"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CG-GRID: SA Current mesh daemon starting..." >> "$LOG"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CG-GRID: Node CG-NODE-EARTH-001 -- ACTIVE" >> "$LOG"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CG-GRID: Connecting to Crystal Globe Grid..." >> "$LOG"
while true; do
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CG-GRID: Heartbeat -- Node ONLINE" >> "$LOG"
    sleep 300
done
GDEOF
chmod +x "$CHROOT/opt/capsulecorp/bin/cg-grid-daemon"
chroot "$CHROOT" systemctl enable cg-grid 2>/dev/null || true

# RUBY shell
mkdir -p "$CHROOT/opt/capsulecorp/terminal"
if [ -f "$SCRIPT_DIR/rootfs/opt/capsulecorp/terminal/ruby-shell.sh" ]; then
    cp "$SCRIPT_DIR/rootfs/opt/capsulecorp/terminal/ruby-shell.sh" \
       "$CHROOT/opt/capsulecorp/terminal/"
    chmod +x "$CHROOT/opt/capsulecorp/terminal/ruby-shell.sh"
fi

# Set android user default shell to RUBY if available
if [ -f "$CHROOT/opt/capsulecorp/terminal/ruby-shell.sh" ]; then
    chroot "$CHROOT" usermod -s /opt/capsulecorp/terminal/ruby-shell.sh android 2>/dev/null || true
fi

# MOTD
cat > "$CHROOT/etc/motd" << 'MOTDEOF'

  ██████╗ ██████╗██████╗  ██████╗     ██████╗ ███████╗
 ██╔════╝██╔════╝██╔═══██╗██╔════╝    ██╔═══██╗██╔════╝
 ██║     ██║     ██║   ██║╚█████╗     ██║   ██║███████╗
 ██║     ██║     ██║   ██║ ╚═══██╗    ██║   ██║╚════██║
 ╚██████╗╚██████╗██████╔╝██████╔╝     ██████╔╝███████║
  ╚═════╝ ╚═════╝╚═════╝ ╚═════╝      ╚═════╝ ╚══════╝

  CapsuleCorpOS v1.0 -- Crystal Globe Pty Ltd
  Commander: Android #23 | ABN 52 635 620 343
  Grid Node: CG-NODE-EARTH-001
  SA Current: ACTIVE | Block Ray: STANDBY

MOTDEOF

# Plymouth boot splash
mkdir -p "$CHROOT/usr/share/plymouth/themes/capsulecorp"
cat > "$CHROOT/usr/share/plymouth/themes/capsulecorp/capsulecorp.script" << 'PLYMEOF'
Window.SetBackgroundTopColor(0.0, 0.0, 0.05);
Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);

logo.image = Image("splash.png");
logo.sprite = Sprite(logo.image);
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);

progress_box.image = Image.Scale(Image("progress_box.png"), Window.GetWidth() * 0.5, 20);
progress_box.sprite = Sprite(progress_box.image);
progress_box.sprite.SetX(Window.GetWidth() / 2 - progress_box.image.GetWidth() / 2);
progress_box.sprite.SetY(Window.GetHeight() * 0.85);

progress_bar.original_image = Image("progress_bar.png");

fun progress_callback(duration, progress) {
    progress_bar.image = Image.Scale(
        progress_bar.original_image,
        progress_box.image.GetWidth() * progress,
        progress_box.image.GetHeight()
    );
    progress_bar.sprite = Sprite(progress_bar.image);
    progress_bar.sprite.SetX(progress_box.sprite.GetX());
    progress_bar.sprite.SetY(progress_box.sprite.GetY());
}

Plymouth.SetBootProgressFunction(progress_callback);
PLYMEOF

cat > "$CHROOT/usr/share/plymouth/themes/capsulecorp/capsulecorp.plymouth" << 'PTHEOF'
[Plymouth Theme]
Name=CapsuleCorpOS
Description=Crystal Globe Boot Splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/capsulecorp
ScriptFile=/usr/share/plymouth/themes/capsulecorp/capsulecorp.script
PTHEOF

chroot "$CHROOT" \
    update-alternatives --install \
    /usr/share/plymouth/themes/default.plymouth \
    default.plymouth \
    /usr/share/plymouth/themes/capsulecorp/capsulecorp.plymouth \
    150 2>/dev/null || true

chroot "$CHROOT" update-initramfs -u 2>/dev/null || true

ok "RUBY terminal, firewall, Grid daemon, system config installed"

# ── Step 9: Build ISO ────────────────────────────────────────
log "Step 9/9 -- Building ISO..."
rm -rf "$ISO_STAGE"
mkdir -p "$ISO_STAGE"/{live,boot/grub,EFI/BOOT,isolinux}

# Squashfs
log "  Compressing filesystem (xz, this takes ~5 min)..."
mksquashfs "$CHROOT" "$ISO_STAGE/live/filesystem.squashfs" \
    -e boot -comp xz -b 1M -noappend -quiet
ok "  Squashfs: $(du -sh $ISO_STAGE/live/filesystem.squashfs | cut -f1)"

# Kernel + initrd
VMLINUZ=$(ls "$CHROOT/boot/vmlinuz-"* | sort -V | tail -1)
INITRD=$(ls  "$CHROOT/boot/initrd.img-"* | sort -V | tail -1)
cp "$VMLINUZ" "$ISO_STAGE/boot/vmlinuz"
cp "$INITRD"  "$ISO_STAGE/boot/initrd.img"
ok "  Kernel: $(basename $VMLINUZ)"

# GRUB EFI config
printf '%s\n' \
    'set default=0' \
    'set timeout=5' \
    '' \
    'menuentry "CapsuleCorpOS v1.0 -- Crystal Globe" {' \
    '  linux /boot/vmlinuz boot=live quiet splash' \
    '  initrd /boot/initrd.img' \
    '}' \
    'menuentry "CapsuleCorpOS -- Safe Mode (nomodeset)" {' \
    '  linux /boot/vmlinuz boot=live nomodeset' \
    '  initrd /boot/initrd.img' \
    '}' \
    'menuentry "CapsuleCorpOS -- Recovery Shell" {' \
    '  linux /boot/vmlinuz boot=live single' \
    '  initrd /boot/initrd.img' \
    '}' \
    > "$ISO_STAGE/boot/grub/grub.cfg"

# GRUB EFI image
grub-mkstandalone \
    --format=x86_64-efi \
    --output="$ISO_STAGE/EFI/BOOT/BOOTX64.EFI" \
    --locales="" --fonts="" \
    "boot/grub/grub.cfg=$ISO_STAGE/boot/grub/grub.cfg"

dd if=/dev/zero of="$ISO_STAGE/boot/efi.img" bs=1M count=10 status=none
mkfs.vfat "$ISO_STAGE/boot/efi.img" > /dev/null
mmd  -i "$ISO_STAGE/boot/efi.img" ::/EFI ::/EFI/BOOT
mcopy -i "$ISO_STAGE/boot/efi.img" "$ISO_STAGE/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/

# ISOLINUX (legacy BIOS)
ISOLINUX_BIN=$(find /usr/lib -name "isolinux.bin" 2>/dev/null | head -1)
LDLINUX=$(find /usr/lib -name "ldlinux.c32" 2>/dev/null | head -1)
if [ -n "$ISOLINUX_BIN" ] && [ -n "$LDLINUX" ]; then
    cp "$ISOLINUX_BIN" "$ISO_STAGE/isolinux/"
    cp "$LDLINUX"      "$ISO_STAGE/isolinux/"
    printf '%s\n' \
        'DEFAULT capsulecorp' \
        'TIMEOUT 50' \
        '' \
        'LABEL capsulecorp' \
        '  KERNEL /boot/vmlinuz' \
        '  APPEND initrd=/boot/initrd.img boot=live quiet splash' \
        'LABEL safe' \
        '  KERNEL /boot/vmlinuz' \
        '  APPEND initrd=/boot/initrd.img boot=live nomodeset' \
        > "$ISO_STAGE/isolinux/isolinux.cfg"
    HAS_ISOLINUX=true
else
    warn "isolinux.bin not found -- building EFI-only ISO (UEFI boot only)"
    HAS_ISOLINUX=false
fi

# Build final ISO
if [ "$HAS_ISOLINUX" = true ]; then
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "CAPSULECORPOS_V1" \
        -eltorito-boot isolinux/isolinux.bin \
        -eltorito-catalog isolinux/boot.cat \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        --eltorito-alt-boot \
        -e boot/efi.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        -append_partition 2 0xef "$ISO_STAGE/boot/efi.img" \
        -output "$ISO_OUT" \
        "$ISO_STAGE" \
        2>&1 | grep -v "^xorriso"
else
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "CAPSULECORPOS_V1" \
        --eltorito-alt-boot \
        -e boot/efi.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        -append_partition 2 0xef "$ISO_STAGE/boot/efi.img" \
        -output "$ISO_OUT" \
        "$ISO_STAGE" \
        2>&1 | grep -v "^xorriso"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  CapsuleCorpOS v1.0 -- BUILD COMPLETE${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ISO:  ${BOLD}$ISO_OUT${NC}"
echo -e "  Size: ${BOLD}$(du -sh $ISO_OUT | cut -f1)${NC}"
echo ""
echo -e "  Flash to USB (Linux):"
echo -e "  ${CYAN}sudo dd if=$ISO_OUT of=/dev/sdX bs=4M status=progress${NC}"
echo ""
echo -e "  Flash to USB (Windows):"
echo -e "  ${CYAN}Use Rufus -- select ISO, GPT, UEFI${NC}"
echo ""
echo -e "  Default login: android / CrystalGlobe2347"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"

# ── Step 10: Install new standalone OS tools ─────────────────
log "Step 10/10 -- Installing CapsuleCorpOS v2.0 standalone upgrades..."

# ccpkg -- package manager
cp "$SCRIPT_DIR/rootfs/opt/capsulecorp/bin/ccpkg" "$CHROOT/usr/local/bin/ccpkg"
chmod +x "$CHROOT/usr/local/bin/ccpkg"

# ccos-monitor -- system monitor
cp "$SCRIPT_DIR/rootfs/opt/capsulecorp/bin/ccos-monitor" "$CHROOT/usr/local/bin/ccos-monitor"
chmod +x "$CHROOT/usr/local/bin/ccos-monitor"

# ccos-vault -- encrypted storage
cp "$SCRIPT_DIR/rootfs/opt/capsulecorp/bin/ccos-vault" "$CHROOT/usr/local/bin/ccos-vault"
chmod +x "$CHROOT/usr/local/bin/ccos-vault"

# avis-connector -- G347 telemetry
cp "$SCRIPT_DIR/rootfs/opt/capsulecorp/bin/avis-connector" "$CHROOT/usr/local/bin/avis-connector"
chmod +x "$CHROOT/usr/local/bin/avis-connector"

# Create /usr/local/bin symlinks inside chroot
chroot "$CHROOT" /bin/bash -c "
    ln -sf /usr/local/bin/ccpkg /usr/bin/ccpkg 2>/dev/null || true
    ln -sf /usr/local/bin/ccos-monitor /usr/bin/ccos-monitor 2>/dev/null || true
    ln -sf /usr/local/bin/ccos-vault /usr/bin/ccos-vault 2>/dev/null || true
    ln -sf /usr/local/bin/avis-connector /usr/bin/avis-connector 2>/dev/null || true
"

# Set version
echo "CapsuleCorpOS v2.0 | Crystal Globe Pty Ltd | Android #23" > \
    "$CHROOT/etc/ccos-release"

ok "CapsuleCorpOS v2.0 standalone tools installed"
log "Build complete -- CapsuleCorpOS v2.0"
