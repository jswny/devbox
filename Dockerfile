FROM ubuntu:18.04
RUN apt-get update

# Install essentials
RUN apt-get install -y \
    make \
    cmake \
    git \
    curl 

# Install user packages
RUN apt-get install -y \
    tmux \
    zsh 

# Change default shell to ZSH
RUN chsh -s $(which zsh)

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Build NeoVim from source
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

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.3
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
RUN echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
# RUN source ~/.zshrc

# Remove default .zshrc
RUN rm ~/.zshrc

# Add custom config files
ADD dotfiles /root/

WORKDIR /root

# Override this as needed
CMD ["/usr/bin/zsh"]