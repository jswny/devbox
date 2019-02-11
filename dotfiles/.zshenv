# Set XDG environment variables
if [[ -z "$XDG_CONFIG_HOME" ]]; then
  export XDG_CONFIG_HOME="$HOME/.config"
fi
if [[ -z "$XDG_DATA_HOME" ]]; then
  export XDG_DATA_HOME="$HOME/.local/share"
fi
if [[ -z "$XDG_CACHE_HOME" ]]; then
  export XDG_CACHE_HOME="$HOME/.cache"
fi

# Use XDG for config files
if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

# Alias Tmux to use a config file which complies with XDG
# This must be a global alias in order to work correctly with TPM scripts
# However, this messes up other things like "man tmux"
alias -g tmux="tmux -f '$XDG_CONFIG_HOME/tmux/tmux.conf'"