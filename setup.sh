#!/usr/bin/env bash
set -euo pipefail

FISH_FUNCTIONS="${HOME}/.config/fish/functions"
DEVILBOX_DEFAULT="${HOME}/Work/devilbox-ce"

read -rp "Devilbox path [${DEVILBOX_DEFAULT}]: " input_path
DEVILBOX_PATH="${input_path:-$DEVILBOX_DEFAULT}"

# ── Install devilbox.fish ──────────────────────────────────────────────
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

echo "✓ Done. Restart fish or run 'exec fish' to reload."
