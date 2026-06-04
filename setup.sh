#!/usr/bin/env bash
set -euo pipefail

DEVILBOX_DEFAULT="${HOME}/Work/devilbox-ce"

read -rp "Devilbox path [${DEVILBOX_DEFAULT}]: " input_path
DEVILBOX_PATH="${input_path:-$DEVILBOX_DEFAULT}"

# ── Install devilbox.fish ──────────────────────────────────────────────
FISH_FUNCTIONS="${HOME}/.config/fish/functions"
mkdir -p "$FISH_FUNCTIONS"
sed "s|~.*/devilbox-ce|${DEVILBOX_PATH}|" devilbox.fish > "$FISH_FUNCTIONS/devilbox.fish"
echo "✓ Installed devilbox.fish → $FISH_FUNCTIONS/devilbox.fish"
echo "  DEVILBOX_PATH set to: ${DEVILBOX_PATH}"

# ── Install Fisher & nvm ───────────────────────────────────────────────
if ! fish -c "functions -q fisher" 2>/dev/null; then
    echo "  Installing Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
        -o ~/.config/fish/functions/fisher.fish
    fish -c "fisher install jorgebucaran/fisher"
    echo "✓ Fisher installed"
else
    echo "✓ Fisher already installed"
fi

fish -c "fisher install jorgebucaran/nvm.fish" 2>/dev/null || echo "  nvm.fish already installed"
echo "✓ nvm.fish installed"

# ── Check system dependencies ──────────────────────────────────────────
echo ""
echo "Checking system dependencies..."

if command -v udiskie &>/dev/null; then
    echo "✓ udiskie found"
else
    echo "✗ udiskie not found"
    echo "  Install with: sudo pacman -S udiskie (Arch) or sudo apt install udiskie (Debian/Ubuntu)"
fi

if command -v nm-applet &>/dev/null; then
    echo "✓ nm-applet found"
else
    echo "✗ nm-applet not found"
    echo "  Install with: sudo pacman -S network-manager-applet (Arch) or sudo apt install network-manager-gnome (Debian/Ubuntu)"
fi

# ── Install devilbox.plugin.zsh ────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
PLUGIN_DIR="${ZSH_CUSTOM}/plugins/devilbox"
mkdir -p "$PLUGIN_DIR"
sed "s|\$HOME/Work/devilbox-ce|${DEVILBOX_PATH}|g" \
    devilbox.plugin.zsh > "$PLUGIN_DIR/devilbox.plugin.zsh"
echo "✓ Installed devilbox.plugin.zsh → $PLUGIN_DIR/devilbox.plugin.zsh"
echo "  Add 'devilbox' to the plugins array in your .zshrc to enable."

# ── Update Hyprland execs.lua ──────────────────────────────────────────
HYPR_EXECS="${HOME}/.config/hypr/hyprland/execs.lua"

if [[ -f "$HYPR_EXECS" ]]; then
    echo ""
    echo "Checking Hyprland execs.lua..."

    # Check if udiskie already exists
    if ! grep -q "udiskie" "$HYPR_EXECS"; then
        # Find the line with gnome-keyring and add udiskie after the audio section
        if grep -q "easyeffects" "$HYPR_EXECS"; then
            sed -i '/easyeffects.*--service-mode/a\
\
    -- Auto-mount USB/external drives\
    hl.exec_cmd("udiskie --tray")' "$HYPR_EXECS"
            echo "✓ Added udiskie to $HYPR_EXECS"
        fi
    else
        echo "✓ udiskie already in $HYPR_EXECS"
    fi

    # Check if nm-applet already exists
    if ! grep -q "nm-applet" "$HYPR_EXECS"; then
        # Add after udiskie
        if grep -q "udiskie" "$HYPR_EXECS"; then
            sed -i '/udiskie.*--tray/a\    -- Network manager applet\
    hl.exec_cmd("nm-applet")' "$HYPR_EXECS"
            echo "✓ Added nm-applet to $HYPR_EXECS"
        fi
    else
        echo "✓ nm-applet already in $HYPR_EXECS"
    fi
else
    echo "⚠ Hyprland execs.lua not found at $HYPR_EXECS"
    echo "  Skipping Hyprland configuration."
fi

echo ""
echo "✓ Done. Restart fish or run 'exec fish' to reload."
