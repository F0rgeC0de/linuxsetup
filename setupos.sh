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

# Only backup if the file exists in home directory
if [ -e "$HOME/.dotfiles" ]; then
  rm -r -f $HOME/.dotfiles
  echo "Directory already setup!"
else
  echo "Cloning dotfiles..."
fi

git clone $DOTFILE_REPO ~/.dotfiles

if [ $? -eq 0 ]; then
  echo "Success! Cloned to the home directory (~/.dotfiles)."
else
  echo "Clone failed! Check internet connection or try intimidation. Maybe just throw your computer at the wall... Whatever works..."    
  exit 1
fi



load_dotfiles() {

# Directory containing your dotfiles (stow packages)
DOTFILES_DIR=~/.dotfiles

  # Only backup if the file exists in home directory
if [ -e "$HOME/stow_backups/" ]; then
  echo "Directory already setup!"
else
  mkdir $HOME/stow_backups/
  echo "Directory created!"
fi

# List of files you want to backup (for example: .bashrc, .vimrc, etc.)
FILES_TO_BACKUP=($(ls -A $DOTFILES_DIR))

# List of paths (relative to $HOME) to ignore
IGNORE_PATHS=(
    ".config"
    
    # Add more paths as needed
)

# Function to check if a path is in the ignore list
is_ignored() {
    local path="$1"
    for ignore in "${IGNORE_PATHS[@]}"; do
        if [[ "$path" == "$ignore" ]]; then
            return 0  # true: path is ignored
        fi
    done
    return 1  # false: path is not ignored
}

for file in "${FILES_TO_BACKUP[@]}"; do
    src="$HOME/$file"
    dest="$HOME/stow_backups/$file"
    if is_ignored "$file"; then
        echo "Skipping $file (ignored)"
        continue
    fi
    if [ -f "$src" ] || [ -L "$src" ]; then
        mv "$src" "$dest"
        echo "Backed up $file to $dest"
    elif [ -d "$src" ]; then
        mkdir -p "$dest"
        shopt -s dotglob nullglob
        for item in "$src"/* "$src"/.*; do
            base_item="$file/$(basename "$item")"
            [[ $(basename "$item") =~ ^\.\.?$ ]] && continue
            if is_ignored "$base_item"; then
                echo "Skipping $base_item (ignored)"
                continue
            fi
            mv "$item" "$dest/"
            echo "Backed up $base_item to $dest/"
        done
        shopt -u dotglob nullglob
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
rm -rf nerd-fonts
}


setup_brew() {

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /home/colin/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/colin/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install build-essential


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
gh auth login
install_fonts
