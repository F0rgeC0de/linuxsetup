#!/bin/bash
##############################################################
# Created by: Colin Smith
# License: MIT
# 
# *******************CHANGELOG****************************** #
# - Created on 06/05/2025
#
#
##############################################################



#--------------------SETUP-VARIABLES-------------------------#
# Used for any variables specific to users particular setup

# Insert your dotfiles here or use my repo
#DOTFILE_REPO = <Your .dotfiles repo>
DOTFILE_REPO="https://github.com/F0rgeC0de/.dotfiles"

# List of packages to install with apt
declare -a apt_packages=(
"tmux"


)

# List of packages to install with Homebrew
declare -a brew_packages=(
"neovim" "tree-sitter" "gcc" "unzip" "node" "make"
"lazygit"

"fzf" "stow" "eza" "zoxide" "ripgrep-all" "git" "gh" "curl"
"fastfetch"

"python3"


)


declare -a fonts=(
    # BitstreamVeraSansMono
    # CodeNewRoman
    # DroidSansMono
    # FiraCode
    # FiraMono
    # Go-Mono
    # Hack
    # Hermit
    JetBrainsMono
    # Meslo
    # Noto
    OpenDyslexic
    Overpass
    # ProggyClean
    # RobotoMono
    SourceCodePro
    # SpaceMono
    # Ubuntu
    # UbuntuMono
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

# Directory containing your dotfiles (stow packages)
DOTFILES_DIR=~/.dotfiles

# List of files you want to backup (for example: .bashrc, .vimrc, etc.)
FILES_TO_BACKUP=($(ls -A $DOTFILES_DIR))

for file in "${FILES_TO_BACKUP[@]}"; do
    # Only backup if the file exists in home directory
    if [ -e "$HOME/$file" ]; then
        mv "$HOME/$file" "$HOME/stow_backups/$file"
        echo "Backed up $file to ~/stow_backups/$file"
    fi
done

cd ~/.dotfiles
stow .

}

get_brew_packages() {

for pkg in "${brew_packages[@]}"
do
echo "Installing $pkg..."
brew install $pkg

# Check for sucessful installation and notify user
if [ $? -eq 0 ]; then
  echo "Successfully installed $pkg!"
else
  echo "ERROR encountered installing $pkg!" 
fi

done 

}

get_apt_packages() {

for pkg in "${apt_packages[@]}"
do
echo "Installing $pkg..."
sudo apt install $pkg

# Check for sucessful installation and notify user
if [ $? -eq 0 ]; then
  echo "Successfully installed $pkg!"
else
  echo "ERROR encountered installing $pkg!" 
fi

done 

}


install_fonts() {

fonts_dir="${HOME}/.local/share/fonts"

if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
fi

echo -e "\e[0;32mScript:\e[0m \e[0;34mClonning\e[0m \e[0;31mNerdFonts\e[0m \e[0;34mrepo (sparse)\e[0m"
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
cd nerd-fonts

for font in "${fonts[@]}"; do
    echo -e "\e[0;32mScript:\e[0m \e[0;34mClonning font:\e[0m \e[0;31m${font}\e[0m"
    git sparse-checkout add "patched-fonts/${font}"
    echo -e "\e[0;32mScript:\e[0m \e[0;34mInstalling font:\e[0m \e[0;31m${font}\e[0m"
    ./install.sh "${font}"
done

echo -e "\e[0;32mScript:\e[0m \e[0;34mCleaning the mess...\e[0m"
cd ../
rm -rf nerd-fonts```

}



set_aliases() {

# exa
echo "" >> ~/.bashrc
echo "alias ll='eza -l --icons'" >> ~/.bashrc
echo "alias ls='eza'" >> ~/.bashrc
echo "alias tree='eza --tree --level=2 --icons'" >> ~/.bashrc


}



setup_brew() {

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ $? -eq 0 ]; then
  echo "Homebrew installed!"
else
  echo "Homebrew installed FAILED!"    
  exit 1
fi


}





get_apt_packages
setup_brew
get_brew_packages
get_dotfiles
load_dotfiles
install_fonts
gh auth login
set_aliases

