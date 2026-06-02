#!/usr/bin/env bash
set -euo pipefail

REPO="RomainMILLAN/Server-Dotfiles"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

echo "==> Installing server aliases..."

# Fetch aliases.sh and update.sh
ALIAS_URL="${RAW_BASE}/aliases.sh"
UPDATE_URL="${RAW_BASE}/update.sh"

ALIASES_TMPFILE=$(mktemp)
UPDATE_TMPFILE=$(mktemp)

if ! curl -fsSL "$ALIAS_URL" -o "$ALIASES_TMPFILE"; then
    echo "ERROR: failed to download aliases.sh from $ALIAS_URL" >&2
    rm -f "$ALIASES_TMPFILE" "$UPDATE_TMPFILE"
    exit 1
fi

if ! curl -fsSL "$UPDATE_URL" -o "$UPDATE_TMPFILE" 2>/dev/null; then
    echo "WARNING: failed to download update.sh (will skip)"
    rm -f "$UPDATE_TMPFILE"
    UPDATE_TMPFILE=""
fi

# Append to ~/.bashrc (idempant: don't duplicate)
INSTALL_DIR="${SERVER_DOTFILES_DIR:-$HOME/.server-dotfiles}"
MARKER="# --- server-dotfiles ---"
if ! grep -qF "$MARKER" ~/.bashrc 2>/dev/null; then
    {
        echo ""
        echo "$MARKER"
        echo "[ -f \"$INSTALL_DIR/aliases.sh\" ] && source \"$INSTALL_DIR/aliases.sh\""
        echo "$MARKER"
    } >> ~/.bashrc
    echo "==> Added source line to ~/.bashrc"
else
    echo "==> ~/.bashrc already contains server-dotfiles entry (skipped)"
fi

# Write aliases to install dir
mkdir -p "$INSTALL_DIR"
cp "$ALIASES_TMPFILE" "$INSTALL_DIR/aliases.sh"
rm -f "$ALIASES_TMPFILE"

# Write update.sh if downloaded
if [ -n "$UPDATE_TMPFILE" ]; then
    cp "$UPDATE_TMPFILE" "$INSTALL_DIR/update.sh"
    chmod +x "$INSTALL_DIR/update.sh"
    rm -f "$UPDATE_TMPFILE"
    echo "==> update.sh installed in $INSTALL_DIR/"
fi

# Install config file (only if not exists)
if [ ! -f "$INSTALL_DIR/config" ]; then
    if ! curl -fsSL "${RAW_BASE}/config" -o "$INSTALL_DIR/config" 2>/dev/null; then
        cat > "$INSTALL_DIR/config" << 'EOF'
# server-dotfiles configuration
# Editer ce fichier pour personnaliser le message de bienvenue

# Marque principale (affiché en haut du message)
SERVER_DOTFILES_WELCOME_TITLE="ROMAIN MILLAN INFRASTRUCTURE"

# Informations du site (optionnelles, laissez vide pour masquer)
SERVER_DOTFILES_SITE=""
SERVER_DOTFILES_ENVIRONMENT=""
SERVER_DOTFILES_FQDN=""

# Message d'avertissement (affiché en bas)
# Laisser vide pour masquer la section
SERVER_DOTFILES_WARNING="Unauthorized access is prohibited.
All actions may be logged and audited."
EOF
    fi
    echo "==> Config file created in $INSTALL_DIR/config"
fi

echo "==> Aliases installed in $INSTALL_DIR/aliases.sh"
echo "==> Run 'source ~/.bashrc' or reconnect to activate"
echo "==> To update later, run: bash $INSTALL_DIR/update.sh"
