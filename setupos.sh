#!/bin/bash
##############################################################
# Created by: Colin Smith
# License: MIT
# 
# *******************CHANGELOG****************************** #
# - Created on 05/31/2025
#
#
##############################################################



#--------------------SETUP-VARIABLES-------------------------#
# Used for any variables specific to users particular setup

# Insert your dotfiles here or use my repo
#DOTFILE_REPO = <Your .dotfiles repo>
DOTFILE_REPO="https://github.com/F0rgeC0de/.dotfiles"

# List of packages to install with nix-env
declare -a packages=(
"ghostty"
"neovim" "tree-sitter" "gcc" "unzip" "yarn" "gnumake"
"lazygit"

"fzf" "stow" "exa" "zoxide" "ripgrep-all" "git" "curl"

"python3"

"nerd-fonts.sauce-code-pro" "nerd-fonts.open-dyslexic"

)


#------------------------------------------------------------#



get_dotfiles() {

git clone $DOTFILE_REPO ~/.dotfiles

if [ $? -eq 0 ]; then
  echo "Success! Cloned to the home directory (~/.dotfiles)."
else
  echo "Clone failed! Check internet connection or just throw your computer at the wall... Whatever works..."    
  exit 1
fi

}


load_dotfiles() {

cd ~/.dotfiles
stow .

}

get_packages() {

for pkg in "${packages[@]}"
do
echo "Installing $pkg..."
nix-env -iA nixpkgs.$pkg

# Check for sucessful installation and notify user
if [ $? -eq 0 ]; then
  echo "Successfully installed $pkg!"
else
  echo "ERROR encountered installing $pkg!" 
fi

done 

}


set_aliases() {

# exa
echo "alias ll='exa -l --icons'" >> ~/.bashrc
echo "alias ls='exa'" >> ~/.bashrc
echo "alias tree='exa --tree --level=2 --icons'" >> ~/.bashrc


}



setup_nix() {

curl -L https://nixos.org/nix/install | sh

. /home/$USER/.nix-profile/etc/profile.d/nix.sh

ln -s /home/$USER/.nix-profile/share/applications/* /home/$USER/.local/share/applications/


if [ $? -eq 0 ]; then
  echo "Nix installed!"
else
  echo "Nix installed FAILED!"    
  exit 1
fi


}


get_dotfiles
get_packages
load_dotfiles
set_aliases


