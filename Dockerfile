FROM ubuntu:18.04

# Turn non-interactive on only for the build
ARG DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update

# Set environment variables
ENV TERM xterm-256color

# Install essentials
RUN apt-get install -y \
    locales \
    apt-utils \
    software-properties-common \
    make \
    cmake \
    git \
    curl 

# Install user packages
RUN apt-get install -y \
    tmux

# Generate the correct locale
RUN locale-gen en_US.UTF-8

# Add custom config files
ADD dotfiles /root/

# Install Fish
RUN apt-add-repository ppa:fish-shell/release-3
RUN apt-get update
RUN apt-get install -y fish

# Create Fish config directory
RUN mkdir -p ~/.config/fish

# Change default shell to ZSH
RUN chsh -s $(which fish)
ENV SHELL /usr/bin/fish
SHELL ["/usr/bin/fish", "-c"]

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.3
RUN echo 'source ~/.asdf/asdf.fish' >> ~/.config/fish/config.fish
RUN mkdir -p ~/.config/fish/completions && cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions

# Install Python 2 and 3 through ASDF
RUN apt-get install -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev
RUN asdf plugin-add python https://github.com/danhper/asdf-python.git
RUN asdf install python 3.7.2
RUN asdf install python 2.7.15

# Setup both Python 2 and 3 so either version can be used
RUN asdf global python 3.7.2 2.7.15

# Upgrade Python 2 and 3 Pip versions
RUN pip2 install --upgrade pip
RUN pip3 install --upgrade pip

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
RUN git clone https://github.com/neovim/neovim.git /tmp/neovim
WORKDIR /tmp/neovim
RUN git checkout v0.3.2
RUN make clean
RUN make CMAKE_BUILD_TYPE=Release install
RUN ln -s /usr/local/bin/nvim /usr/local/bin/vim

# Install NeoVim plugins
RUN vim --headless +PlugInstall +qa

WORKDIR /root

# Override this as needed
CMD ["/usr/bin/fish"]