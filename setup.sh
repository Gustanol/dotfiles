#!/usr/bin/env bash

# __ Environment Variables __ #

DOTFILES_DIR=$(pwd)
PACKAGES=(foot gsimplecal hyprland waybar mako mpv pipewire wofi)
DELETE_REPO=$1
SYMLINKS=$2

# __ Functions __ #

log() {
    echo -e "\e[1;32m[INFO]\e[0m $1"
}

erro() {
    echo -e "\e[1;31m[ERRO]\e[0m $1"
    exit 1
}

require_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo "Some stages in this setup will need sudo."
        sudo -v || exit 1
    fi
}

install_packages() {
    log "[*] Installing some essential packages..."
    for pkg in "${PACKAGES[@]}"; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            log "[-] Installing $pkg"
            sudo pacman -S --noconfirm "$pkg"
        fi
    done
}

create_symlinks() {
    log "[*] Creating symlinks"
    for dir in hypr foot gsimplecal mako mpv pipewire waybar wofi; do
        ln -sf "$DOTFILES_DIR/$dir" ~/.config/
    done
}

copy_dotfiles() {
    log "[*] Copying dotfiles"
    for dir in hypr foot gsimplecal mako mpv pipewire waybar wofi; do
        cp -r "$DOTFILES_DIR/$dir" ~/.config/
    done

    if [[ "$DELETE_REPO" == "y" ]]; then
        log "[*] Removing dotfiles repo"
        rm -rf "$DOTFILES_DIR"
    fi
}

# __ Execution __ #

main() {
    require_sudo
    install_packages
    if [[ "$SYMLINKS" == "y" ]]; then
         symlinks
    else
        copy_dotfiles
    fi
    log "[✔] Dotfiles configurated successfully!"
}

main
