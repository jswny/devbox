FROM ubuntu:19.10

# Set environment variables for the build only (these won't persist when you run the container)
ARG DEBIAN_FRONTEND=noninteractive
# Set XDG variables
ARG XDG_CONFIG_HOME=/root/.config
ARG XDG_DATA_HOME=/root/.local/share
ARG XDG_CACHE_HOME=/root/.cache
ARG HOME=/root

# Set environment variables (these will persist at runtime)
ENV TERM xterm-256color
ENV XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
ENV XDG_DATA_HOME=${XDG_DATA_HOME}
ENV XDG_CACHE_HOME=${XDG_CACHE_HOME}

# Remove the exlusions for man pages and such so they get installed
# This will only install man pages for packages that aren't built in
# For example, "man ls" still won't work, but "man fish" will
# To restore ALL man pages, run "yes | unminimize"
# However, this will take a long time and install a lot of extra packages as well
RUN rm /etc/dpkg/dpkg.cfg.d/excludes

# Update packages
RUN apt-get update

# Install essentials
RUN apt-get install -y \
    man-db \
    locales \
    apt-utils \
    make \
    cmake \
    git \
    curl \
# Allows usage of apt-add-repository
    software-properties-common

# Generate the correct locale and reconfigure the locales so they are picked up correctly
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Set the correct locale variables for the build as they won't be set correctly until logging into the system
# This is needed for when the BEAM is run when 
# This is per the following suggestion: https://github.com/elixir-lang/elixir/issues/3548
# We need to set this after we generate the locales otherwise locale-gen will genearate an error
ARG LC_ALL=en_US.UTF-8

# Install Fish
RUN apt-add-repository ppa:fish-shell/release-3
RUN apt-get update
RUN apt-get install -y fish
# Change default shell to Fish
RUN chsh -s $(which fish)

# Run all of the following Dockerfile commands with Fish instead of Bash
SHELL ["/usr/bin/fish", "-c"]

# Install Fisher (Fish plugin manager)
RUN curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# Install ASDF
RUN git clone https://github.com/asdf-vm/asdf.git $XDG_DATA_HOME/asdf --branch v0.7.6
# Add ASDF support and completions to fish
RUN mkdir -p $XDG_CONFIG_HOME/fish/completions; and cp $XDG_DATA_HOME/asdf/completions/asdf.fish $XDG_CONFIG_HOME/fish/completions
RUN echo "source $XDG_DATA_HOME/asdf/asdf.fish" >> $XDG_CONFIG_HOME/fish/local.config.fish

# Install ASDF plugins 
# Source ASDF for every command because config.fish hasn't been added to the container yet so local.config.fish won't be loaded yet (so ASDF won't be loaded yet)
RUN source $XDG_DATA_HOME/asdf/asdf.fish && asdf plugin-add erlang
RUN source $XDG_DATA_HOME/asdf/asdf.fish && asdf plugin-add elixir

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
RUN source $XDG_DATA_HOME/asdf/asdf.fish && asdf install erlang 22.2.6
RUN source $XDG_DATA_HOME/asdf/asdf.fish && asdf global erlang 22.2.6
# Install Elixir
RUN source $XDG_DATA_HOME/asdf/asdf.fish && asdf install elixir ref:v1.9.4
RUN source $XDG_DATA_HOME/asdf/asdf.fish && asdf global elixir ref:v1.9.4

# Install Rebar3
RUN source $XDG_DATA_HOME/asdf/asdf.fish && mix local.rebar --force
# Install Hex
RUN source $XDG_DATA_HOME/asdf/asdf.fish && mix local.hex --force

# Install and build Elixir-LS
RUN git clone https://github.com/elixir-lsp/elixir-ls.git /usr/local/share/elixir-ls
WORKDIR /usr/local/share/elixir-ls
# Remove the ASDF tool versions file since the Elixir version doesn't match up with the version in the file
# This is probably fine but it does generate a warning about backwards-compatibility
RUN rm .tool-versions
RUN source $XDG_DATA_HOME/asdf/asdf.fish && mix deps.get
RUN source $XDG_DATA_HOME/asdf/asdf.fish && mix compile
RUN source $XDG_DATA_HOME/asdf/asdf.fish && mix elixir_ls.release
RUN ln -s /usr/local/share/elixir-ls/release/language_server.sh /usr/local/bin/elixir-ls.sh 

# Install Pip for Python 2 and 3
# Ubuntu already comes with Python 2 and 3 installed
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

# Install NeoVim
RUN add-apt-repository ppa:neovim-ppa/unstable
RUN apt-get update
RUN apt-get install -y neovim

# Install vim-plug
RUN curl -sfLo $XDG_DATA_HOME/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Enable Solarized dircolors
RUN git clone https://github.com/seebi/dircolors-solarized.git $XDG_DATA_HOME/dircolors-solarized

# Install Tmux compilation dependencies
RUN apt-get install -y \
    libevent-dev \
    ncurses-dev \
    bison \
    pkg-config

# Install Tmux from source
# Older versions than 2.9 do not work with some .tmux.conf syntax
RUN mkdir -p $XDG_CACHE_HOME
RUN git clone https://github.com/tmux/tmux.git $XDG_CACHE_HOME/tmux
WORKDIR $XDG_CACHE_HOME/tmux
RUN git checkout 3.1
RUN sh autogen.sh
RUN ./configure && make
RUN make install
RUN rm -rf $XDG_CACHE_HOME/tmux

# Install TPM (Tmux Plugin Manager)
RUN git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm

# Install FZF without Bash or ZSH support
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $XDG_DATA_HOME/fzf
RUN $XDG_DATA_HOME/fzf/install --all --no-bash --no-zsh --xdg

# Install FD
WORKDIR $XDG_CACHE_HOME
ARG FD_VERSION=7.4.0
RUN curl -sLO https://github.com/sharkdp/fd/releases/download/v{$FD_VERSION}/fd_{$FD_VERSION}_amd64.deb
RUN dpkg -i fd_{$FD_VERSION}_amd64.deb
RUN rm fd_{$FD_VERSION}_amd64.deb

# Install Bat
# Force overwrites when installing the .deb package because Bat tries to install its completions into the built-in Fish completions folder (which is managed by the Fish package)
# See: https://github.com/sharkdp/bat/issues/651
WORKDIR $XDG_CACHE_HOME
ARG BAT_VERSION=0.12.1
RUN curl -sLO https://github.com/sharkdp/bat/releases/download/v{$BAT_VERSION}/bat_{$BAT_VERSION}_amd64.deb
RUN dpkg -i --force-overwrite bat_{$BAT_VERSION}_amd64.deb
RUN rm bat_{$BAT_VERSION}_amd64.deb

# Set the root home directory as the working directory
WORKDIR $HOME

# Override this as needed
# Run the dotfiles setup script at runtime
# This ensures the container always gets the latest dotfiles version
# If this was run at build-time, the dotfiles version would be tied to when the cointainer was built
# Run a regular Fish shell by default
CMD git clone https://github.com/jswny/dotfiles.git $XDG_CONFIG_HOME/dotfiles \
    && cd $XDG_CONFIG_HOME/dotfiles \
    && $XDG_CONFIG_HOME/dotfiles/setup.sh \
    && cd $HOME \
    && /usr/bin/fish
