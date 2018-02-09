# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# choose the closest pacman mirror
pacman-mirrors -i -c China -m rank

# install base devel package
pacman -S base-devel

# install gtk theme
pacman -S adapta-gtk-theme

# install icon theme
pacman -S papirus-icon-theme

# install tmux
pacman -S tmux

# install deoplete support
pip3 install --upgrade neovim
