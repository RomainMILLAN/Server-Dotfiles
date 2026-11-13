#!/usr/bin/env bash
set -euo pipefail

REPO="RomainMILLAN/Server-Dotfiles"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
INSTALL_DIR="${SERVER_DOTFILES_DIR:-$HOME/.server-dotfiles}"

echo "==> Checking for server-dotfiles updates..."

# Check if currently installed
if [ ! -f "$INSTALL_DIR/aliases.sh" ]; then
    echo "==> server-dotfiles not found in $INSTALL_DIR"
    echo "==> Run the installer first:"
    echo "    curl -fsSL ${RAW_BASE}/install.sh | bash"
    exit 1
fi

# Check for aliases.sh update
ALIAS_URL="${RAW_BASE}/aliases.sh"
TMPFILE=$(mktemp)

if ! curl -fsSL "$ALIAS_URL" -o "$TMPFILE"; then
    echo "ERROR: failed to download aliases.sh" >&2
    rm -f "$TMPFILE"
    exit 1
fi

if ! diff -q "$INSTALL_DIR/aliases.sh" "$TMPFILE" >/dev/null 2>&1; then
    cp "$TMPFILE" "$INSTALL_DIR/aliases.sh"
    echo "==> aliases.sh updated"
else
    echo "==> aliases.sh is up to date"
fi

rm -f "$TMPFILE"

# Check for install.sh update
INSTALL_URL="${RAW_BASE}/install.sh"
INSTALL_TMPFILE=$(mktemp)

if curl -fsSL "$INSTALL_URL" -o "$INSTALL_TMPFILE" 2>/dev/null; then
    if [ -f "$INSTALL_DIR/install.sh" ]; then
        if ! diff -q "$INSTALL_DIR/install.sh" "$INSTALL_TMPFILE" >/dev/null 2>&1; then
            cp "$INSTALL_TMPFILE" "$INSTALL_DIR/install.sh"
            echo "==> install.sh updated (in $INSTALL_DIR)"
        else
            echo "==> install.sh is up to date"
        fi
    fi
    rm -f "$INSTALL_TMPFILE"
fi

# Check for server-update.sh update (created if missing)
SERVER_UPDATE_URL="${RAW_BASE}/server-update.sh"
SERVER_UPDATE_TMPFILE=$(mktemp)

if curl -fsSL "$SERVER_UPDATE_URL" -o "$SERVER_UPDATE_TMPFILE" 2>/dev/null; then
    if ! diff -q "$INSTALL_DIR/server-update.sh" "$SERVER_UPDATE_TMPFILE" >/dev/null 2>&1; then
        cp "$SERVER_UPDATE_TMPFILE" "$INSTALL_DIR/server-update.sh"
        chmod +x "$INSTALL_DIR/server-update.sh"
        echo "==> server-update.sh updated"
    else
        echo "==> server-update.sh is up to date"
    fi
fi
rm -f "$SERVER_UPDATE_TMPFILE"

# Check for remove.sh update (created if missing)
REMOVE_URL="${RAW_BASE}/remove.sh"
REMOVE_TMPFILE=$(mktemp)

if curl -fsSL "$REMOVE_URL" -o "$REMOVE_TMPFILE" 2>/dev/null; then
    if ! diff -q "$INSTALL_DIR/remove.sh" "$REMOVE_TMPFILE" >/dev/null 2>&1; then
        cp "$REMOVE_TMPFILE" "$INSTALL_DIR/remove.sh"
        chmod +x "$INSTALL_DIR/remove.sh"
        echo "==> remove.sh updated"
    else
        echo "==> remove.sh is up to date"
    fi
fi
rm -f "$REMOVE_TMPFILE"

# Check for config update (download as config.default, never overwrites user config)
CONFIG_URL="${RAW_BASE}/config"
CONFIG_TMPFILE=$(mktemp)

if curl -fsSL "$CONFIG_URL" -o "$CONFIG_TMPFILE" 2>/dev/null; then
    if [ -f "$INSTALL_DIR/config" ]; then
        cp "$CONFIG_TMPFILE" "$INSTALL_DIR/config.default"
        echo "==> config.default downloaded (your config is unchanged)"
    else
        cp "$CONFIG_TMPFILE" "$INSTALL_DIR/config"
        echo "==> config file created from default"
    fi
    rm -f "$CONFIG_TMPFILE"
fi

echo "==> Update check complete"
echo "==> Run 'source ~/.bashrc' or reconnect to activate any changes"

# Self-update is LAST. Bash reads a script incrementally: overwriting $0 in
# place (cp) makes it read the rest of the NEW file at the old offset -> syntax
# error. `mv` swaps in a new inode instead, so this running instance keeps
# reading the old, unchanged file. The temp file lives next to $0 so mv is an
# atomic rename on the same filesystem.
SELF_URL="${RAW_BASE}/update.sh"
SELF_TMPFILE=$(mktemp "$(dirname "$0")/.update.sh.XXXXXX")

if curl -fsSL "$SELF_URL" -o "$SELF_TMPFILE" 2>/dev/null \
    && ! diff -q "$0" "$SELF_TMPFILE" >/dev/null 2>&1; then
    chmod +x "$SELF_TMPFILE"
    mv -f "$SELF_TMPFILE" "$0"
    echo "==> update.sh self-updated"
    exit 0
fi
rm -f "$SELF_TMPFILE"
echo "==> update.sh is up to date"
