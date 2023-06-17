#!/bin/bash

# Author: Paxol (https://github.com/Paxol)
# Inspired by https://www.github.com/keyitdev/dotfiles

config_directory="$HOME/.config"
fonts_directory="$HOME/.local/share/fonts"
gtk_theme_directory="$HOME/.local/share/themes"
scripts_directory="/usr/local/bin"

green='\033[0;32m'
no_color='\033[0m'
date=$(date +%s)

config_dirs=()
for dir in config/*/; do
    dirname=$(basename $dir)
    config_dirs+=($dirname)
done

mkdir -p "$config_directory"

sudo pacman --noconfirm --needed -Sy dialog

system_update(){
    echo -e "${green}[*] Doing a system update, cause stuff may break if it's not the latest version...${no_color}"
    sudo pacman -Sy --noconfirm archlinux-keyring
    sudo pacman --noconfirm -Syu
    sudo pacman -S --noconfirm --needed base-devel wget git curl
}
install_aur_helper(){ 
    if ! command -v yay &> /dev/null
    then
    echo -e "${green}[*] It seems that you don't have yay installed, I'll install that for you before continuing.${no_color}"
    git clone https://aur.archlinux.org/yay.git $HOME/.srcs/yay
    (cd $HOME/.srcs/yay/ && makepkg -si)
    else
    echo -e "${green}[*] It seems that you already have yay installed, skipping.${no_color}"
    fi
}
install_pkgs(){
    echo -e "${green}[*] Installing packages with pacman.${no_color}"
    sudo pacman -S --noconfirm --needed zsh hyprland kitty rofi polkit-kde-agent xdg-desktop-portal-hyprland qt5-wayland qt6-wayland cliphist swayidle dunst btop rofi-emoji rofi-calc ttf-font-awesome brightnessctl ttf-jetbrains-mono kvantum-qt5
}
install_aur_pkgs(){
    echo -e "${green}[*] Installing packages with yay.${no_color}"
    yay -S --noconfirm --needed waybar-hyprland-git swww greetd-tuigreet xwaylandvideobridge-cursor-mode-2-git hyprpicker visual-studio-code-bin wlogout gtklock sddm-git python-requests rofi-wifi-menu-git pw-volume
}
install_emoji_fonts(){
    echo -e "${green}[*] Installing emoji fonts with yay.${no_color}"
    yay -S --noconfirm --needed noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-whatsapp-emoji
    sudo cp -f ./local.conf /etc/fonts
    fc-cache -fv
}
install_oh_my_zsh(){
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
set_zsh_shell(){
    echo -e "${green}[*] Setting Zsh as default shell.${no_color}"
    chsh -s /bin/zsh
    sudo chsh -s /bin/zsh
}
copy_fonts(){
    echo -e "${green}[*] Copying fonts to $fonts_directory.${no_color}"
    sudo cp -r ./fonts/* "$fonts_directory"
    fc-cache -fv
}
backup_config(){
    echo -e "${green}[*] Creating backup of existing configs.${no_color}"

    for dir in ${config_dirs[@]}; do
        [ -d "$config_directory"/"$dir" ] && mv "$config_directory"/"$dir" "$config_directory"/"$dir"_$date && echo "$dir configs detected, backing up."
    done
}
copy_config(){
    echo -e "${green}[*] Copying configs to $config_directory.${no_color}"
    cp -r ./config/* "$config_directory"
}
cmd=(dialog --clear --separate-output --checklist "Select (with space) what script should do.\\nChecked options are required for proper installation, do not uncheck them if you do not know what you are doing." 26 86 16)
options=(1 "System update" on
         2 "Install aur helper" on
         3 "Install basic packages" on
         4 "Install basic packages (aur)" on
         5 "Install emoji fonts" off
         6 "Install oh my zsh" off
         7 "Set zsh as default shell" on
         8 "Copy fonts" off
         9 "Backup config" on
         10 "Copy config" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

clear

for choice in $choices
do
    case $choice in
        1) system_update;;
        2) install_aur_helper;;
        3) install_pkgs;;
        4) install_aur_pkgs;;
        5) install_emoji_fonts;;
        6) install_oh_my_zsh;;
        7) set_zsh_shell;;
        8) copy_fonts;;
        9) backup_config;;
        10) copy_config;;
    esac
done
