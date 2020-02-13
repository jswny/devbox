#!/usr/bin/env bash

# Script for installing the latest version of my dotfiles into the container

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"/root/.config"}

# Clone the repository and open it as the working directory
git clone https://github.com/jswny/dotfiles.git "$XDG_CONFIG_HOME/dotfiles"
cd "$XDG_CONFIG_HOME/dotfiles"

# Symlink the Fish files
ln -s "$XDG_CONFIG_HOME/dotfiles/fish/config.fish" "$XDG_CONFIG_HOME/fish/config.fish"
ln -s "$XDG_CONFIG_HOME/dotfiles/fish/config.fishfile" "$XDG_CONFIG_HOME/fish/fishfile"
