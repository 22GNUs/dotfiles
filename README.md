# Dotfiles

A collection of personal configuration files for terminal, editor, and window manager tools.

## Repository Structure

```
.
├── .config/               # Main config directory
│   ├── fish/             # Fish Shell configuration
│   ├── ghostty/          # Ghostty terminal configuration
│   ├── zellij/           # Zellij terminal multiplexer configuration
│   ├── aerospace/        # AeroSpace window manager configuration
│   ├── nvim/             # Neovim (LazyVim) configuration
│   ├── opencode/         # OpenCode AI assistant configuration
│   ├── lazygit/          # Lazygit configuration
│   └── starship.toml     # Starship prompt configuration
├── archive/              # Archived legacy configurations
│   ├── editors/          # Editor configurations (Vim, IntelliJ)
│   ├── macos/            # macOS tool configurations (Sketchybar)
│   ├── scripts/          # Legacy utility scripts
│   ├── shells/           # Legacy shell configurations (Zsh)
│   └── terminals/        # Legacy terminal configurations (Alacritty, WezTerm)
├── scripts/              # Maintenance scripts
├── fonts/                # Nerd Fonts files
├── external/             # External repository references (used via symlinks)
├── install.sh            # Install script (repo → system)
├── .tmux.conf            # Tmux configuration
└── .ideavimrc            # IntelliJ IDEA Vim plugin configuration
```

## Neovim (LazyVim)

A Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim).

### Install Dependencies

```sh
# Node.js (JSON LSP)
brew install node

# Lazygit (optional)
brew install lazygit

# Glow (optional, for Markdown preview)
brew install glow
```

### Recommended Font

```sh
brew tap homebrew/cask-fonts && brew install --cask font-fantasque-sans-mono-nerd-font
```

### Clean Cache

```sh
~/.config/nvim/clean.sh
```

This script backs up and cleans:

- `~/.local/share/nvim`
- `~/.local/state/nvim`
- `~/.cache/nvim`

### Claude Code Integration

AI assistance keybindings with the `<leader>a` prefix are configured, supporting integration with Claude Code.

---

## OpenCode

The core configuration for the OpenCode AI assistant, including custom agents and skills.

### Quick Install

```bash
chmod +x .config/opencode/setup.sh
./setup.sh
```

The script will automatically:

1. Check the `~/.config/opencode` directory
2. Clone/update the configuration from this repository
3. Clean plugin caches

### Plugin

This configuration uses the **`opencode-antigravity-auth@1.2.6`** plugin, providing:

- **Google OAuth authentication**: multi-account support
- **Dual quota pool**: automatic switching between Antigravity and Gemini CLI quotas
- **Multi-model support**: including the Gemini 3 series and Claude 4.5 series

### Environment Variables

Set in your shell configuration file:

```bash
# Required
export CONTEXT7_API_KEY="your_key_here"

# Optional
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

---

## Pi Agent

Configuration directory for the Pi AI assistant.

After initialization, run:

```bash
pi /reload
pi list
```

See `.pi/agent/README.md` for details.

---

## Installation & Sync

### Install (Repo → System)

```bash
./install.sh
```

This script symlinks the configuration files from the repository into your home directory. Conflicting files are backed up to `~/.dotfiles_backup/`.

The Lazygit configuration is linked to both of the following locations to avoid macOS/XDG path differences from causing it to not take effect:

- `~/.config/lazygit/config.yml`
- `~/Library/Application Support/lazygit/config.yml`

### SDKMAN / Legacy Java Configuration Cleanup

If you need to uninstall SDKMAN on an older machine and remove the Java / Maven related configurations we previously placed in dotfiles, run:

```bash
./scripts/uninstall-sdkman.sh
```

The script cleans:

- `~/.sdkman`
- `~/.config/fisher/github.com/reitzig/sdkman-for-fish`
- `~/.config/fish/conf.d/java.fish`
- `~/.m2/toolchains.xml`
- SDKMAN path remnants in `fish_user_paths`
- SDKMAN fragments left in `~/.bashrc` / `~/.bash_profile`
- SDKMAN-related functions, completions, and configuration in `~/.config/fish`

### Notes

1. **Do not commit sensitive information**: `.gitignore` is configured to exclude `.gitconfig` and similar
2. **Fish variables**: `fish_variables` is a local state file and is excluded
3. **Symlinks preferred**: use `install.sh` to create symlinks rather than copying
4. **Platform-specific**: this configuration targets macOS and uses `/opt/homebrew` paths
