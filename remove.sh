#!/usr/bin/env bash
# Désinstalle server-dotfiles : retire le bloc de ~/.bashrc puis supprime le dossier d'installation.
set -euo pipefail

INSTALL_DIR="${SERVER_DOTFILES_DIR:-$HOME/.server-dotfiles}"
MARKER="# --- server-dotfiles ---"
BASHRC="$HOME/.bashrc"

# Garde-fou : ne jamais supprimer autre chose qu'un dossier server-dotfiles
if [ -z "$INSTALL_DIR" ] || [ "$INSTALL_DIR" = "/" ] || [ "$INSTALL_DIR" = "$HOME" ]; then
    echo "ERROR: refusing to remove unsafe directory '$INSTALL_DIR'" >&2
    exit 1
fi
if [ -d "$INSTALL_DIR" ] && [ ! -f "$INSTALL_DIR/aliases.sh" ]; then
    echo "ERROR: $INSTALL_DIR does not look like a server-dotfiles install (no aliases.sh)" >&2
    exit 1
fi

echo
echo "⚠️  This will uninstall server-dotfiles:"
echo "- Remove the server-dotfiles block from $BASHRC (backup: $BASHRC.bak)"
echo "- Delete $INSTALL_DIR (including your config)"
echo
echo -n "Uninstall server-dotfiles? (y/N): "
read -r confirm </dev/tty || confirm=""
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Aborted."
    exit 0
fi

# --- ~/.bashrc ------------------------------------------------
if [ -f "$BASHRC" ] && grep -qF "$MARKER" "$BASHRC"; then
    cp "$BASHRC" "$BASHRC.bak"
    TMPFILE=$(mktemp)
    # Supprime tout ce qui est entre les deux marqueurs (inclus),
    # ainsi que la ligne vide ajoutée juste avant par install.sh
    awk -v marker="$MARKER" '
        $0 == marker { inside = !inside; pending = ""; has_pending = 0; next }
        inside { next }
        {
            if (has_pending) print pending
            if ($0 == "") { pending = $0; has_pending = 1 } else { print; has_pending = 0 }
        }
        END { if (has_pending) print pending }
    ' "$BASHRC" > "$TMPFILE"
    # cat > conserve l'inode, les droits et un éventuel lien symbolique
    cat "$TMPFILE" > "$BASHRC"
    rm -f "$TMPFILE"
    echo "==> server-dotfiles block removed from $BASHRC"
else
    echo "==> No server-dotfiles block found in $BASHRC (skipped)"
fi

# --- Install dir (en dernier : ce script peut y être) ---------
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "==> $INSTALL_DIR removed"
else
    echo "==> $INSTALL_DIR not found (skipped)"
fi

echo "✅ server-dotfiles uninstalled. Open a new shell to drop the aliases from the current session."
