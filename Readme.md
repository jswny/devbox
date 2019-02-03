# Devbox
My personal development machine inside [Docker](https://www.docker.com/).

## Getting Started
### Docker Image
The Docker image is available from the [Docker Hub](https://hub.docker.com/r/jswny/devbox). A new image is pushed to the `jswny/devbox:latest` tag each time a new commit is pushed to the `master` branch of the [GitHub repository](https://github.com/jswny/devbox).

The image is based on [Ubuntu `18.04`](https://hub.docker.com/_/ubuntu).

### Pulling from Docker Hub
```sh
docker pull jswny/devbox
```

### Building from Source
```sh
docker build -t jswny/devbox .
```

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

### Remomve the Image
```sh
docker rmi jswny/devbox
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