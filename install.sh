#!/usr/bin/env bash
set -euo pipefail

REPO="RomainMILLAN/Server-s-Dotfiles"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

echo "==> Installing server aliases..."

# Fetch aliases.sh
ALIAS_URL="${RAW_BASE}/aliases.sh"
TMPFILE=$(mktemp)

if ! curl -fsSL "$ALIAS_URL" -o "$TMPFILE"; then
    echo "ERROR: failed to download aliases.sh from $ALIAS_URL" >&2
    rm -f "$TMPFILE"
    exit 1
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
cp "$TMPFILE" ~/.server-dotfiles/aliases.sh
rm -f "$TMPFILE"

echo "==> Aliases installed in ~/.server-dotfiles/aliases.sh"
echo "==> Run 'source ~/.bashrc' or reconnect to activate"
