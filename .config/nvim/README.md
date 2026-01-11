# 💤 LazyVim

A starter powered by [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Getting started

```sh
git clone git@github.com:22GNUs/lazyvimdots.git ~/.config/nvim
```

## Recommand Fonts

### FantasqueSansMono Nerd Font

```sh
brew tap homebrew/cask-fonts && brew install --cask font-fantasque-sans-mono-nerd-font
```

## Requements

### Node(Jsonlsp)

```
brew install node
```

### Lazygit(Optional)

```sh
brew install lazygit
```


## Plugins

### Git Conflict (git-conflict.nvim)

用于可视化和解决 Git 冲突的插件。当检测到冲突时，会自动在当前 buffer 启用以下快捷键：

- **`co`** (Choose Ours): 选择当前分支的更改。
- **`ct`** (Choose Theirs): 选择传入分支的更改。
- **`cb`** (Choose Both): 保留双方更改。
- **`c0`** (Choose None): 都不保留。
- **`[x`** : 跳转到上一个冲突点。
- **`]x`** : 跳转到下一个冲突点。

**常用命令：**

- `:GitConflictListQf`: 在 Quickfix 窗口中列出项目中的所有冲突。
