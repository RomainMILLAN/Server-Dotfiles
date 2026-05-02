#!/usr/bin/env bash
set -euo pipefail

REPO="RomainMILLAN/Server-s-Dotfiles"
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
MARKER="# --- server-dotfiles ---"
if ! grep -qF "$MARKER" ~/.bashrc 2>/dev/null; then
    {
        echo ""
        echo "$MARKER"
        echo "[ -f ~/.server-dotfiles/aliases.sh ] && source ~/.server-dotfiles/aliases.sh"
        echo "$MARKER"
    } >> ~/.bashrc
    echo "==> Added source line to ~/.bashrc"
else
    echo "==> ~/.bashrc already contains server-dotfiles entry (skipped)"
fi

# Write aliases to ~/.server-dotfiles/
mkdir -p ~/.server-dotfiles
cp "$ALIASES_TMPFILE" ~/.server-dotfiles/aliases.sh
rm -f "$ALIASES_TMPFILE"

# Write update.sh if downloaded
if [ -n "$UPDATE_TMPFILE" ]; then
    cp "$UPDATE_TMPFILE" ~/.server-dotfiles/update.sh
    chmod +x ~/.server-dotfiles/update.sh
    rm -f "$UPDATE_TMPFILE"
    echo "==> update.sh installed in ~/.server-dotfiles/"
fi

echo "==> Aliases installed in ~/.server-dotfiles/aliases.sh"
echo "==> Run 'source ~/.bashrc' or reconnect to activate"
echo "==> To update later, run: bash ~/.server-dotfiles/update.sh"
