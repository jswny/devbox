# Devbox
My personal development machine inside docker.

## Running
### Run the container
```bash
docker build -t jswny/devbox . && docker run -it -h devbox --name devbox jswny/devbox
```

### Stop and remove the container, and remove the associated image
```bash
docker stop devbox && docker rm devbox && docker rmi jswny/devbox
```

## Features
- [Tmux](https://github.com/tmux/tmux) for terminal multiplexing
- [Fish Shell](https://fishshell.com/)
- [ASDF VM](https://github.com/asdf-vm/asdf) for managing multiple runtimes
  - Python 2 and 3 available via `python2` and `python3` respectively
- [NeoVim](https://neovim.io/) with my custom configuration

## Host Terminal Configuration
Devbox is optimized for the [Solarized Dark](https://ethanschoonover.com/solarized/) colorscheme.

I use iTerm 2 on macOS with the above colorscheme.

## Cofiguration Files
Configuration files live in the `dotfiles` directory in this repository. When building the image, the contents of the `dotfiles` directory are copied directly into the `/root/` home directory for the `root` user.

Currently, the following configuration files are provided:
- `config.fish` for the [Fish Shell](https://fishshell.com/)
- `fishfile` for [Fisher](https://github.com/jorgebucaran/fisher), the Fish shell plugin manager

## TODO
- Fix errors in inital NeoVim startup
- FZF Vim plugin installing FZF?
- Set Tmux `$TERM`
- Fix default Fish command color
- Install Fuck
- Fix hostname
- SSH keys
- Put on Docker Hug
- Build automatically on CI