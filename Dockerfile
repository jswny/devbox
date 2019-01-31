FROM ubuntu:18.04
RUN apt-get update

# Install essentials
RUN apt-get install -y \
    software-properties-common \
    git \
    curl 

# Install user packages
RUN apt-get install -y \
    tmux \
    zsh \
    neovim

# Change default shell to ZSH
RUN chsh -s $(which zsh)

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Remove default .zshrc
RUN rm ~/.zshrc

# Add custom config files
ADD dotfiles /root/

WORKDIR /root

# Override this as needed
CMD ["/usr/bin/zsh"]