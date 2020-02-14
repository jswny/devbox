#!/usr/bin/env bash

# Script for installing the latest version of my dotfiles into the container

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"/root/.config"}

# Clone the repository and open it as the working directory
git clone https://github.com/jswny/dotfiles.git "$XDG_CONFIG_HOME/dotfiles"
cd "$XDG_CONFIG_HOME/dotfiles"

# Symlink Fish files
ln -s "$XDG_CONFIG_HOME/dotfiles/fish/config.fish" "$XDG_CONFIG_HOME/fish/config.fish"
ln -s "$XDG_CONFIG_HOME/dotfiles/fish/fishfile" "$XDG_CONFIG_HOME/fish/fishfile"

# Install plugins with Fisher
fish -c "fisher"

# Symlink Tmux files
mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -s "$XDG_CONFIG_HOME/dotfiles/tmux/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

# Symlink to the regular Tmux config file location so Tmux doesn't have to be started with a parameter to point it to the actual file location
# Also, installing plugins with TPM as shown below doesn't work either
ln -s $XDG_CONFIG_HOME/tmux/tmux.conf $HOME/.tmux.conf

# Install TPM plugins
$XDG_DATA_HOME/tmux/plugins/tpm/bin/install_plugins
