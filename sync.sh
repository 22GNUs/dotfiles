#!/bin/bash

cp ~/.config/starship.toml ./.config/
cp ~/.ideavimrc ./
cp ~/.tmux.conf ./
cp ~/.gitconfig ./

rm -rf ./.config/fish/ && cp -r ~/.config/fish ./.config
rm -rf ./.config/alacritty/ && cp -r ~/.config/alacritty ./.config
rm -rf ./.config/aerospace/ && cp -r ~/.config/aerospace ./.config
rm -rf ./.config/sketchybar && cp -r ~/.config/sketchybar ./.config
rm -rf ./.config/ghostty && cp -r ~/.config/ghostty ./.config
