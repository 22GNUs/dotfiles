#!/bin/bash

# Install homebrew

# Install dev tools
brew install neovim
brew install neovide

# formetter
brew install shfmt

# Install aerospace
brew install --cask nikitabobko/tap/aerospace

# Install jankyborders
brew tap FelixKratz/formulae
brew install borders

# Install sketchybar
brew tap FelixKratz/formulae
brew install sketchybar
brew install --cask font-hack-nerd-font
brew install --cask font-sf-pro
mkdir -p ~/.config/sketchybar/plugins
cp $(brew --prefix)/share/sketchybar/examples/sketchybarrc ~/.config/sketchybar/sketchybarrc
cp -r $(brew --prefix)/share/sketchybar/examples/plugins/ ~/.config/sketchybar/plugins/
brew services start sketchybar
