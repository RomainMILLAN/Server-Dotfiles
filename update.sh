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

# Self-update is LAST (cp over $0 after all other operations are done,
# so Bash never needs to re-read a modified script mid-execution)
SELF_URL="${RAW_BASE}/update.sh"
SELF_TMPFILE=$(mktemp)

if curl -fsSL "$SELF_URL" -o "$SELF_TMPFILE" 2>/dev/null; then
    if ! diff -q "$0" "$SELF_TMPFILE" >/dev/null 2>&1; then
        cp "$SELF_TMPFILE" "$0"
        chmod +x "$0"
        echo "==> update.sh self-updated"
    else
        echo "==> update.sh is up to date"
    fi
    rm -f "$SELF_TMPFILE"
fi
