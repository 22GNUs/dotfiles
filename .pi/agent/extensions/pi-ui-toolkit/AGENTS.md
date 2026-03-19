# pi-ui-toolkit 开发规范

## 类型检查

每次修改插件代码后，**必须**运行类型检查确保无错误：

```bash
cd ~/.pi/agent/extensions/pi-ui-toolkit
npm run typecheck
```

## 依赖说明

devDependencies 指向 pi 全局安装路径（仅用于类型检查，运行时由 pi/jiti 解析）。

`node_modules/` 已加入 `.gitignore`，克隆后需要先安装：

```bash
cd ~/.pi/agent/extensions/pi-ui-toolkit
npm install
```
