# ============================================================
# Server aliases — https://github.com/RomainMILLAN/Server-Dotfiles
# ============================================================

# --- Configuration -------------------------------------------
SERVER_DOTFILES_DIR="${SERVER_DOTFILES_DIR:-$HOME/.server-dotfiles}"
[ -f "$SERVER_DOTFILES_DIR/config" ] && source "$SERVER_DOTFILES_DIR/config"

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

# --- Server dotfiles ----------------------------------------
alias dotfiles_update="bash \"$SERVER_DOTFILES_DIR/update.sh\""

# --- Login message -------------------------------------------
_server_dotfiles_welcome() {
    [ -n "$SERVER_DOTFILES_NO_MESSAGE" ] && return
    shopt -q login_shell || return

    local CYAN='\033[0;36m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'
    local SEP='══════════════════════════════════════════════════════════════'

    # --- Collect system data ----------------------------------
    local hostname=$(hostname 2>/dev/null || echo "unknown")
    local kernel=$(uname -r 2>/dev/null || echo "unknown")

    local uptime_str=""
    command -v uptime >/dev/null 2>&1 && uptime_str=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | cut -d',' -f1)

    local mem_used="" mem_total="" mem_pct=""
    if command -v free >/dev/null 2>&1; then
        mem_used=$(free -h | awk '/Mem:/ {print $3}')
        mem_total=$(free -h | awk '/Mem:/ {print $2}')
        mem_pct=$(free -m | awk '/Mem:/ {printf "%.0f%%", $3/$2*100}')
    fi

    local disk_used="" disk_total="" disk_pct=""
    if command -v df >/dev/null 2>&1; then
        disk_used=$(df -h / | awk 'NR==2 {print $3}')
        disk_total=$(df -h / | awk 'NR==2 {print $2}')
        disk_pct=$(df -h / | awk 'NR==2 {print $5}')
    fi

    local private_ip=""
    if command -v hostname >/dev/null 2>&1; then
        private_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    [ -z "$private_ip" ] && command -v ip >/dev/null 2>&1 && private_ip=$(ip -4 addr show | grep -oP '(?<=inet )\S+' | grep -v 127.0.0.1 | head -1)

    local public_ip="N/A"
    command -v curl >/dev/null 2>&1 && public_ip=$(curl -s --max-time 2 ifconfig.me 2>/dev/null)

    local docker_status=""
    if command -v docker >/dev/null 2>&1; then
        docker info &>/dev/null && docker_status="RUNNING" || docker_status="STOPPED"
    fi

    local updates=0 security=0
    if command -v apt >/dev/null 2>&1; then
        updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable 2>/dev/null) || true
        security=$(apt-get --just-print upgrade 2>/dev/null | grep -c "^Inst.*security" 2>/dev/null) || true
    fi

    local has_site=0
    [ -n "$SERVER_DOTFILES_SITE" ] && has_site=1
    local has_env=0
    [ -n "$SERVER_DOTFILES_ENVIRONMENT" ] && has_env=1
    local has_fqdn=0
    [ -n "$SERVER_DOTFILES_FQDN" ] && has_fqdn=1

    # --- Render ----------------------------------------------
    echo -e "${CYAN}${SEP}${NC}"
    printf "  ${YELLOW}%s${NC}\n" "${SERVER_DOTFILES_WELCOME_TITLE}"
    echo -e "${CYAN}${SEP}${NC}"

    if [ "$has_site" -eq 1 ] || [ "$has_env" -eq 1 ] || [ "$has_fqdn" -eq 1 ]; then
        echo ""
        [ "$has_site" -eq 1 ] && printf " ${YELLOW}SITE${NC}          : %s\n" "${SERVER_DOTFILES_SITE}"
        [ "$has_env" -eq 1 ]  && printf " ${YELLOW}ENVIRONNEMENT${NC} : %s\n" "${SERVER_DOTFILES_ENVIRONMENT}"
        [ "$has_fqdn" -eq 1 ] && printf " ${YELLOW}FQDN${NC}          : %s\n" "${SERVER_DOTFILES_FQDN}"
        echo ""
        echo -e "${CYAN}${SEP}${NC}"
    fi

    echo ""
    printf " ${YELLOW}HOST${NC}          : %s\n" "${hostname}"
    printf " ${YELLOW}KERNEL${NC}        : %s\n" "${kernel}"
    printf " ${YELLOW}UPTIME${NC}        : %s\n" "${uptime_str}"
    echo ""
    printf " ${YELLOW}MEMORY${NC}        : %s / %s (%s)\n" "${mem_used}" "${mem_total}" "${mem_pct}"
    printf " ${YELLOW}DISK (/)${NC}      : %s / %s (%s)\n" "${disk_used}" "${disk_total}" "${disk_pct}"
    echo ""
    printf " ${YELLOW}NETWORK${NC}\n"
    printf "   LAN IP      : %s\n" "${private_ip:-N/A}"
    printf "   WAN IP      : %s\n" "${public_ip}"
    echo ""
    printf " ${YELLOW}SERVICES${NC}\n"
    [ -n "$docker_status" ] && printf "   Docker      : %s\n" "${docker_status}"
    echo ""
    echo -e "${CYAN}${SEP}${NC}"

    if [ "$updates" -gt 0 ] || [ "$security" -gt 0 ]; then
        echo ""
        printf " ${YELLOW}STATUS${NC}\n"
        [ "$updates" -gt 0 ] && printf "   Updates     : ${YELLOW}%s packages available${NC}\n" "${updates}"
        [ "$security" -gt 0 ] && printf "   Security    : ${RED}%s security updates available${NC}\n" "${security}"
        echo ""
        echo -e "${CYAN}${SEP}${NC}"

        echo ""
        printf " ${RED}ACTION REQUIRED${NC}\n"
        [ "$security" -gt 0 ] && printf "   - ${RED}Security updates pending${NC}\n"
        [ "$updates" -gt 0 ] && printf "   - ${RED}System updates pending${NC}\n"
        echo ""
        echo -e "${CYAN}${SEP}${NC}"
    fi

    if [ -n "$SERVER_DOTFILES_WARNING" ]; then
        echo ""
        printf " ${YELLOW}WARNING${NC}\n"
        printf '%s\n' "${SERVER_DOTFILES_WARNING}" | while IFS= read -r line; do
            printf "   %s\n" "${line}"
        done
        echo ""
        echo -e "${CYAN}${SEP}${NC}"
    fi
}

_server_dotfiles_welcome
