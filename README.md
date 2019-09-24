配置文件
========

NVIM
----

其他配置都是常规配置, 需要支持scala的话需要执行以下操作 (防止自己忘记了 😹):

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

手动执行 `sbt bloopInstall` 安装, 自动安装不显示进度条
