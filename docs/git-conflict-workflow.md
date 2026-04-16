# 终端 Git 冲突处理方案：lazygit + mergiraf + ec

本配置使用三个工具协同工作，将 Git 冲突处理从“体力活”变成“终端内的流畅操作”。

---

## 方案概述

| 工具 | 角色 | 作用 |
|------|------|------|
| **mergiraf** | Git merge driver | 基于 AST（抽象语法树）做结构化合并，自动解决大量“伪冲突”。支持 25+ 种语言。 |
| **ec (easy-conflict)** | Git mergetool | 终端原生 3-way TUI 冲突解决工具，提供 ours / base / theirs 三窗格。 |
| **lazygit** | Git TUI | 在文件面板中一键唤起 `ec`，全程不离开终端。 |

**工作流**：

```
merge / rebase / cherry-pick
        ↓
  mergiraf 自动消化结构级冲突
        ↓
  仍有冲突 → lazygit 按 m/E 启动 ec
        ↓
  TUI 中解决 → 保存退出 → 继续 rebase
```

---

## 工具介绍

### 1. mergiraf

Git 默认的合并是纯文本的（逐行比较），这会导致很多“伪冲突”。例如两个人在同一个文件的不同位置添加 import，Git 会报冲突，而人类一眼就能看出应该保留两者。

**mergiraf** 会解析代码的语法树，在 AST 层面合并。只要冲突双方修改的是语法树的不同分支，它就能自动合并。如果无法合并，它会优雅地回退到标准冲突标记，不会破坏任何东西。

支持语言包括：Java、Rust、Go、Python、JavaScript、TypeScript、C/C++、C#、Ruby、Elixir、PHP、Dart、Scala、Haskell、OCaml、Lua、Nix、YAML、TOML、HTML、XML 等。

> 对于 mergiraf 不认识的文件类型，它会自动退出并让 Git 使用默认合并策略。

### 2. ec (easy-conflict)

ec 是一款终端原生的 3-way Git mergetool。界面分为三栏：

- **左侧 (ours)**：当前分支的内容
- **中间 (result)**：合并结果（最终写入磁盘的文件）
- **右侧 (theirs)**：对方分支的内容

当 Git 配置了 `diff3` 冲突样式时，ec 还能显示 **base**（共同祖先版本），帮助你判断两边各做了什么改动。

### 3. lazygit

lazygit 是本方案的操作入口。我们通过自定义命令和原生 `m` 键，将 `ec` 无缝集成进 lazygit 的文件面板。

---

## 配置说明

以下配置已通过 `install.sh` 自动同步到系统，文件存放在仓库内对应位置：

### Git 全局配置 (`.config/git/config`)

```ini
[merge "mergiraf"]
    name = mergiraf
    driver = mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L

[mergetool "ec"]
    cmd = ec "$BASE" "$LOCAL" "$REMOTE" "$MERGED"
    trustExitCode = true

[merge]
    tool = ec
    conflictStyle = zdiff3

[rerere]
    enabled = true
```

### Git 全局属性 (`.config/git/attributes`)

```gitattributes
# Mergiraf: structural merge driver for all files
# Mergiraf will fall back to standard Git merge for unsupported file types
* merge=mergiraf
```

全局对所有文件启用 mergiraf。遇到不支持的语言，mergiraf 会自动退让。

### Lazygit 配置 (`.config/lazygit/config.yml`)

```yaml
customCommands:
  - key: "E"
    command: "ec"
    context: "files"
    loadingText: "opening ec mergetool"
    subprocess: true
    description: "Open ec (easy-conflict) for all conflicted files"
```

---

## 使用方法

### 1. 启动冲突解决

在 lazygit 的 **Files** 面板中选中冲突文件：

- 按 **`m`**（默认键）：调用 `git mergetool`，使用当前配置的 `ec` 处理该文件。
- 按 **`E`**（自定义命令）：启动 `ec` 无参数模式，列出当前仓库所有冲突文件，供你选择进入。

### 2. 在 ec 中导航与解决

ec 使用 vim-like 键位：

#### 移动

| 按键 | 功能 |
|------|------|
| `n` / `p` | 下一条 / 上一条冲突 |
| `gg` / `G` | 跳到文件首 / 文件尾 |
| `j` / `k` | 上下滚动 |
| `^u` / `^d` | 半页滚动 |
| `zz` | 将当前冲突置中 |

#### 选择与应用

| 按键 | 功能 |
|------|------|
| `h` / `l` | 选择 **ours** / **theirs** |
| `a` / `Space` | 接受当前选择 |
| `o` | 应用 **ours**（当前分支） |
| `t` | 应用 **theirs**（对方分支） |
| `b` | 应用 **both**（两边都保留） |
| `x` | 应用 **none**（两边都丢弃） |
| `O` | 全局应用 ours（所有剩余冲突） |
| `T` | 全局应用 theirs（所有剩余冲突） |
| `d` | 放弃当前选择 |

#### 其他操作

| 按键 | 功能 |
|------|------|
| `u` | undo |
| `^r` | redo |
| `e` | 用 `$EDITOR`（默认 nvim）打开当前结果做手动微调；退出后 ec 自动重载 |
| `w` / `^s` | 保存文件（不退出 ec） |
| `q` | 退出（若还有未解决冲突会提示） |

### 3. 临时禁用 mergiraf

如果你某次操作想用回 Git 默认合并策略，可在命令前加环境变量：

```bash
mergiraf=0 git rebase origin/main
```

### 4. 命令行直接使用 ec

不通过 lazygit 也可以直接运行：

```bash
# 无参数模式：列出当前所有冲突文件
cd <repo>
ec

# 四参数模式（Git mergetool 标准传参）
ec "$BASE" "$LOCAL" "$REMOTE" "$MERGED"
```

---

## 完整示例

假设你在 rebase 时遇到冲突：

1. **冲突发生**：
   ```bash
   git rebase origin/main
   ```
   终端提示 `CONFLICT (content): Merge conflict in src/app.ts`。

2. **打开 lazygit**：
   ```bash
   lazygit
   ```
   在 Files 面板看到 `src/app.ts` 标为冲突。

3. **启动 ec**：
   选中 `src/app.ts`，按 **`m`** 进入 ec。

4. **在 ec 中处理**：
   - 按 `n` 跳到第一个冲突块。
   - 查看左侧 ours、右侧 theirs，中间 result 实时预览。
   - 按 `t` 选择 theirs，按 `a` 接受。
   - 如果有把握，按 `O` 全局接受 ours 处理剩余冲突。
   - 按 `q` 退出。

5. **继续 rebase**：
   在 lazygit 中按 `c`（continue）继续 rebase。

---

## 故障排除

### ec 无法启动或界面异常

- 确保终端支持真彩色（TrueColor），否则 ec 的十六进制主题色会被降级到 256 色。
- ec 需要交互式终端，lazygit 的 custom command 已配置 `subprocess: true`，请勿关闭此选项。

### mergiraf 合并结果看起来不对

- 立即 `git merge --abort` 或 `git rebase --abort`。
- 用 `mergiraf=0` 重新执行，回退到 Git 默认合并。
- 可以用 `mergiraf report <file>` 生成 bug 报告。

### 某些文件不想用 mergiraf

可以在项目根目录的 `.gitattributes` 中排除特定文件：

```gitattributes
*.lock merge=text
```

或者在全局 `~/.config/git/attributes` 中按语言精细配置：

```gitattributes
*.rs merge=mergiraf
*.py merge=mergiraf
```

---

## 相关链接

- [mergiraf 官方文档](https://mergiraf.org/)
- [ec (easy-conflict) GitHub](https://github.com/chojs23/ec)
- [lazygit 文档](https://lazygit.dev/)
