# ============================================================
# Server aliases — https://github.com/RomainMILLAN/Server-s-Dotfiles
# ============================================================

# --- Navigation & listing -----------------------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# bat: `batcat` sur Debian/Ubuntu, `bat` sur macOS/Arch
if command -v batcat >/dev/null 2>&1; then
    alias cat='batcat'
    alias more='batcat'
elif command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias more='bat'
fi

# sudo-rs (si dispo)
command -v sudo-rs >/dev/null 2>&1 && alias sudo="sudo-rs"

# --- Docker -------------------------------------------------
alias docker-compose="docker compose"
alias dc="docker compose"
alias dcl="docker compose logs"
alias dclf="docker compose logs -f"
alias dce="docker compose exec"
alias dceit="docker compose exec -it"
alias dcr="docker compose run"
alias dcrm="docker compose rm --rm"

alias d="docker"
alias dps="docker ps"
alias dip="docker inspect -f '{{range .NetworkSettings.Networks}}|{{.IPAddress}}{{end}}|'"

dspa() {
    echo
    echo "⚠️  DANGER: prune entire Docker system"
    echo "This will remove:"
    echo "- All stopped containers"
    echo "- All unused images"
    echo "- All unused networks"
    echo
    echo -n "Prune docker system? (y/N): "
    read confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        docker system prune -a --all -f
        echo "✅ Docker system cleaned."
    else
        echo "❌ Aborted."
    fi
}

dnk() {
    echo
    echo "⚠️  DANGER: prune entire Docker system including volumes"
    echo "This will remove:"
    echo "- All stopped containers"
    echo "- All unused images"
    echo "- All unused networks"
    echo "- All unused volumes"
    echo
    echo -n "Prune ALL docker system? (y/N): "
    read confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        docker system prune -a --volumes --all -f
        echo "✅ Docker system and volumes cleaned."
    else
        echo "❌ Aborted."
    fi
}

dka() {
    ids=$(docker ps -q)
    if [[ -z "$ids" ]]; then
        echo "No running containers."
        return
    fi
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    echo -n "Kill ALL running containers? (y/N): "
    read confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        docker kill $ids
        echo "✅ Containers killed."
    else
        echo "❌ Aborted."
    fi
}
