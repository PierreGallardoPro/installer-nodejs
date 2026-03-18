#!/usr/bin/env bash
# =============================================================================
#  Script d'installation de Node.js sur Debian 13 Trixie
#  Auteur  : script généré pour Debian 13 Trixie
#  Date    : 2026-03-18
#  Source  : NodeSource official repository
# =============================================================================
#
#  Versions disponibles :
#    - LTS  (Long-Term Support) : Node.js 24.x  "Krypton"  → production
#    - Current (toute dernière) : Node.js 25.x             → développement
#
#  Usage :
#    chmod +x install_nodejs_trixie.sh
#    sudo ./install_nodejs_trixie.sh          # LTS par défaut
#    sudo ./install_nodejs_trixie.sh --lts    # Node.js 24.x LTS
#    sudo ./install_nodejs_trixie.sh --current # Node.js 25.x Current
# =============================================================================

set -euo pipefail

# ─── Couleurs ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Versions ────────────────────────────────────────────────────────────────
NODE_LTS_VERSION="24"
NODE_CURRENT_VERSION="25"

# ─── Fonctions utilitaires ───────────────────────────────────────────────────
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║        Installation de Node.js — Debian 13 Trixie        ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

log_info()    { echo -e "  ${BLUE}[INFO]${RESET}  $*"; }
log_success() { echo -e "  ${GREEN}[OK]${RESET}    $*"; }
log_warn()    { echo -e "  ${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "  ${RED}[ERREUR]${RESET} $*" >&2; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Ce script doit être exécuté en tant que root."
        echo -e "  Relancez avec : ${BOLD}sudo $0 $*${RESET}"
        exit 1
    fi
}

check_os() {
    log_info "Vérification du système d'exploitation..."
    if [[ ! -f /etc/os-release ]]; then
        log_error "Impossible de détecter le système d'exploitation."
        exit 1
    fi
    source /etc/os-release
    if [[ "$ID" != "debian" ]]; then
        log_warn "Ce script est optimisé pour Debian. OS détecté : $PRETTY_NAME"
        read -rp "  Continuer quand même ? [o/N] " answer
        [[ "$answer" =~ ^[oOyY]$ ]] || { log_info "Installation annulée."; exit 0; }
    else
        log_success "Système détecté : $PRETTY_NAME"
    fi
}

select_version() {
    local arg="${1:-}"
    case "$arg" in
        --lts)
            NODE_MAJOR=$NODE_LTS_VERSION
            VERSION_LABEL="LTS (v${NODE_LTS_VERSION}.x — Krypton, recommandée production)"
            ;;
        --current)
            NODE_MAJOR=$NODE_CURRENT_VERSION
            VERSION_LABEL="Current (v${NODE_CURRENT_VERSION}.x — dernière version)"
            ;;
        *)
            # Menu interactif si aucun argument
            echo ""
            echo -e "  ${BOLD}Quelle version de Node.js souhaitez-vous installer ?${RESET}"
            echo ""
            echo -e "    ${GREEN}1)${RESET} LTS      — v${NODE_LTS_VERSION}.x  ${YELLOW}(recommandée pour la production)${RESET}"
            echo -e "    ${CYAN}2)${RESET} Current  — v${NODE_CURRENT_VERSION}.x  ${YELLOW}(toute dernière, pour le développement)${RESET}"
            echo ""
            read -rp "  Votre choix [1/2] (défaut: 1) : " choice
            case "${choice:-1}" in
                2)
                    NODE_MAJOR=$NODE_CURRENT_VERSION
                    VERSION_LABEL="Current (v${NODE_CURRENT_VERSION}.x — dernière version)"
                    ;;
                *)
                    NODE_MAJOR=$NODE_LTS_VERSION
                    VERSION_LABEL="LTS (v${NODE_LTS_VERSION}.x — Krypton, recommandée production)"
                    ;;
            esac
            ;;
    esac
    echo ""
    log_info "Version sélectionnée : ${BOLD}${VERSION_LABEL}${RESET}"
}

install_dependencies() {
    log_info "Mise à jour des paquets et installation des dépendances..."
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        apt-transport-https \
        lsb-release \
        > /dev/null 2>&1
    log_success "Dépendances installées."
}

remove_old_nodejs() {
    log_info "Suppression des anciennes installations de Node.js (si présentes)..."
    if dpkg -l nodejs &>/dev/null; then
        apt-get remove -y nodejs npm > /dev/null 2>&1 || true
        apt-get autoremove -y > /dev/null 2>&1 || true
        log_success "Ancienne version supprimée."
    else
        log_info "Aucune installation existante détectée."
    fi

    # Supprimer les anciens dépôts NodeSource s'ils existent
    local sources_list="/etc/apt/sources.list.d/nodesource.list"
    local old_key="/usr/share/keyrings/nodesource.gpg"
    [[ -f "$sources_list" ]] && rm -f "$sources_list"
    [[ -f "$old_key" ]]      && rm -f "$old_key"
}

add_nodesource_repo() {
    log_info "Ajout du dépôt officiel NodeSource pour Node.js ${NODE_MAJOR}.x..."

    local keyring_dir="/usr/share/keyrings"
    local keyring_file="${keyring_dir}/nodesource.gpg"
    local sources_file="/etc/apt/sources.list.d/nodesource.list"

    mkdir -p "$keyring_dir"

    # Téléchargement et import de la clé GPG
    curl -fsSL "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
        | gpg --dearmor -o "$keyring_file"
    chmod 644 "$keyring_file"

    # Ajout du dépôt
    echo "deb [signed-by=${keyring_file}] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > "$sources_file"

    # Mise à jour de l'index
    apt-get update -qq
    log_success "Dépôt NodeSource v${NODE_MAJOR}.x configuré."
}

install_nodejs() {
    log_info "Installation de Node.js ${NODE_MAJOR}.x..."
    apt-get install -y nodejs > /dev/null 2>&1
    log_success "Node.js installé avec succès."
}

verify_installation() {
    echo ""
    log_info "Vérification de l'installation..."

    local node_version npm_version node_path npm_path
    node_version=$(node --version 2>/dev/null || echo "NON TROUVÉ")
    npm_version=$(npm --version 2>/dev/null || echo "NON TROUVÉ")
    node_path=$(command -v node 2>/dev/null || echo "introuvable")
    npm_path=$(command -v npm 2>/dev/null || echo "introuvable")

    echo ""
    echo -e "  ${BOLD}━━━ Résultats ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${GREEN}✔${RESET}  Node.js  : ${BOLD}${node_version}${RESET}  (${node_path})"
    echo -e "  ${GREEN}✔${RESET}  npm      : ${BOLD}v${npm_version}${RESET}  (${npm_path})"
    echo -e "  ${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    if [[ "$node_version" == "NON TROUVÉ" ]]; then
        log_error "L'installation a échoué — node introuvable dans le PATH."
        exit 1
    fi

    log_success "Installation terminée avec succès !"
    echo ""
    echo -e "  ${CYAN}${BOLD}Commandes utiles :${RESET}"
    echo -e "    node --version          # vérifier la version"
    echo -e "    npm install -g yarn     # installer Yarn (optionnel)"
    echo -e "    npm install -g pnpm     # installer pnpm (optionnel)"
    echo ""
}

# ─── Point d'entrée ──────────────────────────────────────────────────────────
main() {
    print_banner
    check_root "$@"
    check_os
    select_version "${1:-}"
    install_dependencies
    remove_old_nodejs
    add_nodesource_repo
    install_nodejs
    verify_installation
}

main "$@"
