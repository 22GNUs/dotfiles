#!/bin/bash

cp ~/.zshrc ~/.zshenv ~/.p10k.zsh ~/antigen.zsh ~/.catppuccin_mocha-zsh-syntax-highlighting.zsh ./
cp ~/.config/starship.toml ./.config/
cp ~/.wezterm.lua ./
cp ~/.ideavimrc ./
cp ~/.tmux.conf ./
cp ~/.gitconfig ./

rm -rf ./.config/fish/ && cp -r ~/.config/fish ./.config
rm -rf ./.config/alacritty/ && cp -r ~/.config/alacritty ./.config
