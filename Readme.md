# Devbox
My personal development machine inside [Docker](https://www.docker.com/).

## Features
- [Tmux](https://github.com/tmux/tmux) for terminal multiplexing
- [Zsh](http://zsh.sourceforge.net/) with [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh) installed
- [ASDF VM](https://github.com/asdf-vm/asdf) for managing multiple runtimes
- [NeoVim](https://neovim.io/) with my custom configuration
- [Fuck](https://github.com/nvbn/thefuck) for easily correcting commands
- Colors:
    - Solarized dark dircolors
- Languages:
  - Python 2 and 3 available via `python2` and `python3` respectively

## Usage
### Docker Image
The Docker image is available from the [Docker Hub](https://hub.docker.com/r/jswny/devbox). A new image is pushed to the `jswny/devbox:latest` tag each time a new commit is pushed to the `master` branch of the [GitHub repository](https://github.com/jswny/devbox).

The image is based on [Ubuntu `18.04`](https://hub.docker.com/_/ubuntu).

### Building from Source
In the root of this repository, run:
```sh
docker build -t jswny/devbox .
```

### Pulling from Docker Hub
```sh
docker pull jswny/devbox
```
If you use `docker run` (as shown below), Docker will pull the image automatically. However, you may want to pull it manually if you don't want to run it right away or if you want to force the image to update from Docker Hub.

### Running
```sh
docker run -it -h devbox --name devbox jswny/devbox
```
This command sets the internal hostname of the container as `devbox`.

You can also run the container so that it automatically removes itself after it stops running with the `--rm` flag. Keep in mind that this may cause you to lose any data from inside the container.
```sh
docker run -it --rm -h devbox --name devbox jswny/devbox
```

You may also want to run the container without a name, or without a hostname, so that you can run many container instances of this image. To do so, remove those commands like so:
```sh
docker run -it jswny/devbox
```

### Volumes
You can use a [Docker volume](https://docs.docker.com/storage/volumes/) to mount local files into the internal filesystem of the container so that you can access them inside the container. Any changes you make to the files in the volume inside the container will be reflected outside the container, and vice versa.

To mount a volume when running the container, add the `-v /local/path/:/internal/container/path` flag when running the container.

```sh
docker run -it --rm -v /local/path/:/internal/container/path -h devbox --name devbox jswny/devbox
```

### Stop the Container
```sh
docker stop devbox
```

### Remove a Stopped Container
```sh
docker rm devbox
```

### Remove the Image
```sh
docker rmi jswny/devbox
```

## Host Terminal Configuration
Devbox is optimized for the [Solarized Dark](https://ethanschoonover.com/solarized/) colorscheme.

In addition, the shell prompt that is configured requires a **Powerline patched font** to display certain things. You can find and install Powerline patched fonts through [this Powerline repository](https://github.com/powerline/fonts).

You may need to tell your terminal to do the following (play around with these if the text doesn't look right):
1. Don't draw bold text in bold font
1. Draw bold text in  bright colors

I recommend the following (this is my setup):
- macOS
- iTerm 2
  - Bold text drawn in bold font
- Solarized Dark
- Meslo LG M DZ Powerline patched font

## Configuration
Configuration files live in the `dotfiles` directory in this repository. Devbox attempts to follow the [XDG Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-0.6.html) wherever possible.

Currently, the following configuration files are provided:
- `.config/zsh/.zshrc` for the [Z Shell](http://zsh.sourceforge.net/)
- `.config/nvim/init.vim` for [NeoVim](https://neovim.io/) (similar to `.vimrc` for Vim)
- `zshenv` to configure Zsh to use [XDG](https://specifications.freedesktop.org/basedir-spec/basedir-spec-0.6.html) and set environment variables accordingly

## TODO
- Use environment variables in `Dockerfile`
- Set Tmux `$TERM`
- Tmux Solarized
- Add screenshots
- Install Elixir
- Restart stopped container
- `exec` into background container
- SSH keys