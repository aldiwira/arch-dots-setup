#!/usr/bin/env bash
# Script untuk auto-mount external SSD/USB di Arch Linux + Hyprland
# Run setelah fresh install: bash setup-external-ssd-automount.sh

set -e

echo "==================================="
echo "External SSD Auto-Mount Setup"
echo "==================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Error: Don't run this as root/sudo${NC}"
   echo "Run as: bash $0"
   exit 1
fi

echo "[1/5] Checking dependencies..."
PACKAGES_TO_INSTALL=()

for pkg in udisks2 udiskie ntfs-3g ntfsprogs; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "  - $pkg: NOT INSTALLED"
        PACKAGES_TO_INSTALL+=("$pkg")
    else
        echo "  - $pkg: OK"
    fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Installing missing packages: ${PACKAGES_TO_INSTALL[*]}${NC}"
    sudo pacman -S --needed --noconfirm "${PACKAGES_TO_INSTALL[@]}"
    echo -e "${GREEN}Dependencies installed!${NC}"
else
    echo -e "${GREEN}All dependencies already installed!${NC}"
fi

echo ""
echo "[2/5] Checking Hyprland config..."
HYPR_EXEC_FILE="$HOME/.config/hypr/hyprland/execs.lua"

if [ ! -f "$HYPR_EXEC_FILE" ]; then
    echo -e "${RED}Error: $HYPR_EXEC_FILE not found${NC}"
    echo "This script expects Hyprland config at that path."
    echo "Adjust HYPR_EXEC_FILE variable if your config is elsewhere."
    exit 1
fi

# Check if udiskie already in config
if grep -q "udiskie --tray" "$HYPR_EXEC_FILE"; then
    echo -e "${GREEN}udiskie already configured in Hyprland startup${NC}"
else
    echo "Adding udiskie to Hyprland startup..."

    # Find the line with "-- Clipboard: history" and add after clipboard section
    # Looking for the clipboard section end (after the two wl-paste lines)
    LINE_NUM=$(grep -n "wl-paste --type image" "$HYPR_EXEC_FILE" | cut -d: -f1)

    if [ -z "$LINE_NUM" ]; then
        echo -e "${YELLOW}Warning: Couldn't find clipboard section. Adding at end of function...${NC}"
        # Add before the "-- Cursor" line or end)
        sed -i '/-- Cursor/i \    -- Auto-mount USB/external drives\n    hl.exec_cmd("udiskie --tray")\n' "$HYPR_EXEC_FILE"
    else
        # Add after the image wl-paste line
        NEXT_LINE=$((LINE_NUM + 1))
        sed -i "${NEXT_LINE}i\\
\\
    -- Auto-mount USB/external drives\\
    hl.exec_cmd(\"udiskie --tray\")" "$HYPR_EXEC_FILE"
    fi

    echo -e "${GREEN}Added udiskie to $HYPR_EXEC_FILE${NC}"
fi

echo ""
echo "[3/5] Setting up polkit (for passwordless mount)..."
POLKIT_RULE="/etc/polkit-1/rules.d/50-udisks.rules"

if [ -f "$POLKIT_RULE" ]; then
    echo -e "${GREEN}Polkit rule already exists${NC}"
else
    echo "Creating polkit rule for udisks2..."
    sudo tee "$POLKIT_RULE" > /dev/null <<'EOF'
// Allow users in the "wheel" group to mount/unmount disks without password
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
         action.id == "org.freedesktop.udisks2.filesystem-mount") &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
EOF
    echo -e "${GREEN}Polkit rule created${NC}"
fi

echo ""
echo "[4/5] Testing udiskie..."
# Kill existing udiskie if running
killall udiskie 2>/dev/null || true
sleep 1

# Start udiskie in background
udiskie --tray &
UDISKIE_PID=$!
sleep 2

if ps -p $UDISKIE_PID > /dev/null; then
    echo -e "${GREEN}udiskie started successfully (PID: $UDISKIE_PID)${NC}"
else
    echo -e "${RED}Error: udiskie failed to start${NC}"
    exit 1
fi

echo ""
echo "[5/5] Checking for connected external drives..."
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL | grep -E "sd[b-z]|nvme[1-9]" || echo "No external drives detected"

echo ""
echo -e "${GREEN}==================================="
echo "Setup Complete!"
echo "===================================${NC}"
echo ""
echo "Summary:"
echo "  ✓ udisks2, udiskie, ntfs-3g installed"
echo "  ✓ udiskie added to Hyprland startup"
echo "  ✓ Polkit rule configured (passwordless mount)"
echo "  ✓ udiskie running in background"
echo ""
echo "What happens now:"
echo "  - External USB/SSD will auto-mount to /run/media/$USER/<label>"
echo "  - Tray icon for easy unmount (right-click)"
echo "  - After reboot, everything auto-starts"
echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo "  1. Use Dolphin file manager for NTFS drives (not Nautilus)"
echo "  2. Nautilus has issues with ntfs3 kernel driver"
echo "  3. To test: unplug and replug your SSD — should auto-mount"
echo ""
echo "Test command:"
echo "  lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT"
echo ""
