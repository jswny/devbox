FROM ubuntu:18.04

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
RUN git clone https://github.com/neovim/neovim.git $XDG_CACHE_HOME/nvim
WORKDIR $XDG_CACHE_HOME/nvim
RUN git checkout v0.4.3
RUN make clean
RUN make CMAKE_BUILD_TYPE=Release install
WORKDIR $HOME
RUN rm -rf $XDG_CACHE_HOME/nvim
RUN ln -s /usr/local/bin/nvim /usr/local/bin/vim

# Install vim-plug
RUN curl -sfLo $XDG_DATA_HOME/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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

# Enable Solarized dircolors
RUN git clone https://github.com/seebi/dircolors-solarized.git $XDG_DATA_HOME/dircolors-solarized

# Install Tmux installation dependencies
RUN apt-get install -y \
    libevent-dev \
    ncurses-dev \
    bison
# Install Tmux 3.0a from release tarball (older versions do not work with some .tmux.conf syntax)
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

# Always run the dotfiles setup script at runtime
# This ensures the container always gets the latest dotfiles version
# If this was run at build-time, the dotfiles version would be tied to when the cointainer was built
ENTRYPOINT git clone https://github.com/jswny/dotfiles.git $XDG_CONFIG_HOME/dotfiles \
    && cd $XDG_CONFIG_HOME/dotfiles \
    && $XDG_CONFIG_HOME/dotfiles/setup.sh \
    && cd $HOME

# Override this as needed
# Run a regular Fish shell by default
CMD /usr/bin/fish
