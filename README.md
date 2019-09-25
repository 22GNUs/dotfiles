配置文件
========

NVIM
----

### COC

执行 `:CocConfig`, 配置languageserver

安装如下插件:

```vim
:CocInstall coc-snippets // 片段补全
:CocInstall coc-json // json语法
:CocInstall coc-tsserver // js, ts
```

```json
{
  "languageserver": {
    "metals": {
      "command": "metals-vim",
      "rootPatterns": ["build.sbt"],
      "filetypes": ["scala", "sbt"]
    },
    "lua": {
      "command": "lua-lsp",
      "filetypes": ["lua"]
    }
  }
}
```

#### Scala

[coursier](https://github.com/coursier/coursier) 用包管理器安装

```sh
coursier
./coursier bootstrap \
  --java-opt -Xss4m \
  --java-opt -Xms100m \
  --java-opt -Dmetals.client=coc.nvim \
  org.scalameta:metals_2.12:0.7.6 \
  -r bintray:scalacenter/releases \
  -r sonatype:snapshots \
  -o /usr/local/bin/metals-vim -f
```

确保 `metals-vim` 可执行

进入VIM后可以手动执行 `:call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-import' })`
执行 `build`

检查安装是否正确:

```sh
:call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'doctor-run' })
```

#### Lua

使用 [luaRocks](https://luarocks.org/) 安装 lua 的lsp-server

```sh
luarocks install --server=http://luarocks.org/dev lua-lsp
luarocks install luacheck
luarocks install lcf
```

在Vim内执行 `:CocInstall coc-lua` 安装客户端
