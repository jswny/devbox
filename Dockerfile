FROM ubuntu:18.04

# Set environment variables for the build only (these won't persist when you run the container)
ARG DEBIAN_FRONTEND=noninteractive
# Set XDG variables
ARG XDG_CONFIG_HOME=/root/.config
ARG XDG_DATA_HOME=/root/.local/share
ARG XDG_CACHE_HOME=/root/.cache
ARG HOME=/root
# Running commands through Zsh doesn't source .zshrc so ZSH_CUSTOM doesn't get set
# So, we need to set this manually to install plugins and themes properly
# After starting Zsh interactively, this will be set because .zshrc is sourced
ARG ZSH_CUSTOM=$XDG_DATA_HOME/oh-my-zsh/custom

# Remove the exlusions for man pages and such so they get installed
# This will only install man pages for packages that aren't built in
# For example, "man ls" still won't work, but "man zsh" will
# To restore ALL man pages, run "yes | unminimize"
# However, this will take a long time and install a lot of extra packages as well
RUN rm /etc/dpkg/dpkg.cfg.d/excludes

# Update packages
RUN apt-get update

# Set environment variables
ENV TERM xterm-256color

# Install essentials
RUN apt-get install -y \
    man-db \
    locales \
    apt-utils \
    make \
    cmake \
    git \
    curl 

# Generate the correct locale and reconfigure the locales so they are picked up correctly
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Set the correct locale variables for the build as they won't be set correctly until logging into the system
# This is needed for when the BEAM is run when 
# This is per the following suggestion: https://github.com/elixir-lang/elixir/issues/3548
# We need to set this after we generate the locales otherwise locale-gen will genearate an error
ARG LC_ALL=en_US.UTF-8

# Install user packages
RUN apt-get install -y \
    tmux

# Install Zsh
RUN apt-get install -y zsh
# Change default shell to Zsh
RUN chsh -s $(which zsh)
ENV SHELL /usr/bin/zsh

# Add custom config files to container
ADD dotfiles/.config/ $XDG_CONFIG_HOME
ADD dotfiles/.zshenv $HOME/

# Run all of the following Dockerfile commands with Zsh instead of Bash
SHELL ["/usr/bin/zsh", "-c"]

# Make a Zsh directory in the XDG data directory so that Zsh history can be stored
RUN mkdir -p $XDG_DATA_HOME/zsh
# Make a Zsh directory in the XDG cache directory so that Zsh .zcompdump completion files can be stored
RUN mkdir -p $XDG_CACHE_HOME/zsh

# Install Oh-My-Zsh into the XDG data directory
RUN export ZSH="$XDG_DATA_HOME/oh-my-zsh"; sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# Install Oh-My-Zsh plugins and themes
RUN git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Remove default .zshrc
RUN rm ~/.zshrc

# Enable Solarized dircolors
RUN git clone https://github.com/seebi/dircolors-solarized.git $XDG_DATA_HOME/dircolors-solarized

# Install TPM (Tmux Plugin Manager)
RUN git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm
# Symlink to the regular Tmux config file location because otherwise TPM doesn't work
RUN ln -s $XDG_CONFIG_HOME/tmux/tmux.conf $HOME/.tmux.conf
# Install TPM plugins
RUN $XDG_DATA_HOME/tmux/plugins/tpm/bin/install_plugins

# Install FZF without Bash support
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $XDG_DATA_HOME/fzf
RUN $XDG_DATA_HOME/fzf/install --all --no-bash --xdg

# Install ASDF
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.3
# Install ASDF plugins (need to source ASDF for every command because it only gets sourced normally inside ".zshrc" which isn't loaded at this time)
RUN source $HOME/.asdf/asdf.sh && asdf plugin-add erlang
RUN source $HOME/.asdf/asdf.sh && asdf plugin-add elixir
# Install Erlang with ASDF
RUN apt-get install -y \
    build-essential \
    autoconf \
    m4 \
    libncurses5-dev \
    libwxgtk3.0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libpng16-16 \
    libssh-dev \
    unixodbc-dev \
    xsltproc \
    libxml2-utils \
    fop
# Install languages with ASDF and set globals
RUN source $HOME/.asdf/asdf.sh && asdf install erlang 21.2.5
RUN source $HOME/.asdf/asdf.sh && asdf global erlang 21.2.5
# Install Elixir 1.8.0 instead of 1.8.1 because otherwise there is one failing test (https://github.com/elixir-lang/elixir/issues/8640)
RUN source $HOME/.asdf/asdf.sh && asdf install elixir ref:v1.8.0
RUN source $HOME/.asdf/asdf.sh && asdf global elixir ref:v1.8.0

# Install Pip for Python 2 and 3
RUN apt-get install -y \
    python-pip \
    python3-pip
# Upgrade Python 2 and 3 Pip versions
RUN pip2 install --upgrade pip
RUN pip3 install --upgrade pip

# Install Fuck
RUN pip3 install thefuck

# Install Python 2 and 3 providers for NeoVim
RUN pip2 install --upgrade pynvim
RUN pip3 install --upgrade pynvim
# Build and install NeoVim from source
# This is necessary because certain plugins require the latest version
RUN apt-get install -y \
    ninja-build \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    cmake \
    g++ \
    pkg-config \
    unzip
RUN git clone https://github.com/neovim/neovim.git /tmp/nvim
WORKDIR /tmp/nvim
RUN git checkout v0.3.2
RUN make clean
RUN make CMAKE_BUILD_TYPE=Release install
WORKDIR $HOME
RUN rm -rf /tmp/nvim
RUN ln -s /usr/local/bin/nvim /usr/local/bin/vim

# Install vim-plug
RUN curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install NeoVim plugins and output to log file since this output is not noninteractive
RUN vim --headless '+PlugInstall --sync' +qa &> /var/log/nvim_plug_install.log

# Install Rebar3
RUN source $HOME/.asdf/asdf.sh && mix local.rebar --force
# Install Hex
RUN source $HOME/.asdf/asdf.sh && mix local.hex --force

# Install and build Elixir-LS
RUN git clone https://github.com/elixir-lsp/elixir-ls.git /usr/local/share/elixir-ls
WORKDIR /usr/local/share/elixir-ls
# Remove the ASDF tool versions file since the Elixir version doesn't match up with the version in the file
# This is probably fine but it does generate a warning about backwards-compatibility
RUN rm .tool-versions
RUN source $HOME/.asdf/asdf.sh && mix deps.get
RUN source $HOME/.asdf/asdf.sh && mix compile
RUN source $HOME/.asdf/asdf.sh && mix elixir_ls.release
RUN ln -s /usr/local/share/elixir-ls/release/language_server.sh /usr/local/bin/elixir-ls.sh 

# Set the root home directory as the working directory
WORKDIR $HOME

# Override this as needed
CMD ["/usr/bin/zsh"]