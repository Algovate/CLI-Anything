# CLI-Anything (Core)

This repository now keeps only the core plugin implementation.

## Included

- `cli-anything-plugin/` - Claude Code plugin source (commands, scripts, skills, docs)
- `.claude-plugin/marketplace.json` - local marketplace entry for installing the plugin

## Removed

All bundled example harnesses and demo assets were removed to keep the repository focused and lightweight.

## Install (Local Marketplace)

From repository parent directory:

```bash
cd /Users/rodin/Workspace/algovate
```

In Claude Code:

```text
/plugin marketplace add ./CLI-Anything
/plugin install cli-anything@cli-anything
/reload-plugins
```

## Use

```text
/cli-anything:default <software-path-or-repo>
/cli-anything:refine <software-path> [focus]
/cli-anything:test <software-path-or-repo>
/cli-anything:validate <software-path-or-repo>
/cli-anything:list
```

If `/cli-anything ...` is not available in your Claude Code build, use `/cli-anything:default ...`.
