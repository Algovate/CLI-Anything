# CLI-Anything（核心版）

当前仓库仅保留核心插件实现。

## 保留内容

- `cli-anything-plugin/`：Claude Code 插件源码（commands、scripts、skills、文档）
- `.claude-plugin/marketplace.json`：本地 marketplace 入口

## 已删除

所有内置示例 harness 与演示素材，仓库只保留核心代码。

## 本地安装

先进入仓库上级目录：

```bash
cd /Users/rodin/Workspace/algovate
```

在 Claude Code 中执行：

```text
/plugin marketplace add ./CLI-Anything
/plugin install cli-anything@cli-anything
/reload-plugins
```

## 使用命令

```text
/cli-anything:default <软件路径或仓库>
/cli-anything:refine <软件路径> [focus]
/cli-anything:test <软件路径或仓库>
/cli-anything:validate <软件路径或仓库>
/cli-anything:list
```

如果你的 Claude Code 版本不支持 `/cli-anything ...` 根命令，请使用 `/cli-anything:default ...`。
