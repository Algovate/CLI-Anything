# cli-anything Plugin (Core)

Core Claude Code plugin for generating and maintaining CLI-Anything harnesses.

## What this plugin provides

- `/cli-anything` and `/cli-anything:default` - build a harness from source path/repo
- `/cli-anything:refine` - expand an existing harness
- `/cli-anything:test` - run harness tests and update `TEST.md`
- `/cli-anything:validate` - validate against `HARNESS.md`
- `/cli-anything:list` - list discovered harnesses

## Repository layout

- `.claude-plugin/plugin.json` - plugin manifest
- `commands/` - command definitions
- `skills/cli-anything/SKILL.md` - skill definition
- `scripts/setup-cli-anything.sh` - setup/alias installer
- `HARNESS.md` - core methodology/spec
- `repl_skin.py` - shared REPL skin template
- `verify-plugin.sh` - local integrity/schema checks

## Install from local marketplace

From repository parent:

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
/cli-anything <software-path-or-repo>
/cli-anything:default <software-path-or-repo>
/cli-anything:refine <software-path> [focus]
/cli-anything:test <software-path-or-repo>
/cli-anything:validate <software-path-or-repo>
/cli-anything:list
```

If your Claude Code build does not expose `/cli-anything`, use `/cli-anything:default`.
