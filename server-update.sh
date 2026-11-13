#!/usr/bin/env bash
# Met à jour le système (APT) et propose un redémarrage si nécessaire.
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: apt-get not found (Debian/Ubuntu only)" >&2
    exit 1
fi

SUDO=""
if [ "$EUID" -ne 0 ]; then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: run as root or install sudo" >&2
        exit 1
    fi
    SUDO="sudo"
fi

echo "==> apt-get update"
$SUDO apt-get update

echo "==> apt-get upgrade"
$SUDO apt-get upgrade -y

echo "==> apt-get full-upgrade"
$SUDO apt-get full-upgrade -y

# --- Reboot detection -----------------------------------------
reboot_required=0

if [ -f /var/run/reboot-required ]; then
    reboot_required=1
    echo
    echo "⚠️  Reboot required"
    if [ -f /var/run/reboot-required.pkgs ]; then
        echo "Packages requiring a reboot:"
        sort -u /var/run/reboot-required.pkgs | sed 's/^/  - /'
    fi
else
    # Repli (Debian sans update-notifier) : noyau installé plus récent que celui en cours
    latest_kernel=$(find /boot -maxdepth 1 -name 'vmlinuz-*' 2>/dev/null \
        | sed 's|^/boot/vmlinuz-||' | sort -V | tail -n 1)
    if [ -n "$latest_kernel" ] && [ "$latest_kernel" != "$(uname -r)" ]; then
        reboot_required=1
        echo
        echo "⚠️  Reboot required: running kernel $(uname -r), installed $latest_kernel"
    fi
fi

if [ "$reboot_required" -eq 0 ]; then
    echo
    echo "✅ System up to date, no reboot required."
    exit 0
fi

echo -n "Reboot now? (y/N): "
read -r confirm </dev/tty || confirm=""
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "==> Rebooting..."
    $SUDO reboot
else
    echo "❌ Reboot skipped — remember to reboot later."
fi
