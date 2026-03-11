---
name: cli-anything
description: Build, refine, test, validate, and list CLI-Anything harnesses for GUI application codebases.
---

# cli-anything Skill

Use this skill to build and evolve agent-ready CLI harnesses for GUI applications.

## When to use

- User asks to build a new harness from a local source tree or GitHub repo
- User asks to refine/expand coverage of an existing harness
- User asks to run harness tests and update `TEST.md`
- User asks to validate a harness against `HARNESS.md`
- User asks to list detected harnesses

## Command mapping

- Build: `/cli-anything <software-path-or-repo>`
- Refine: `/cli-anything:refine <software-path> [focus]`
- Test: `/cli-anything:test <software-path-or-repo>`
- Validate: `/cli-anything:validate <software-path-or-repo>`
- List: `/cli-anything:list [--path <directory>] [--depth <n>] [--json]`

## Execution rules

- Read `./HARNESS.md` before performing build/refine/test/validate work.
- Prefer local paths. If repo URL is provided, clone first and work locally.
- Keep generated harness layout aligned with:
  `agent-harness/cli_anything/<software>/{core,utils,tests}`.
