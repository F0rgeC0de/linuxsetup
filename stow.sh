#!/bin/bash

DOTFILE_REPO="https://github.com/DominickBergeron/.dotfiles"

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

}

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


get_dotfiles
load_dotfiles


