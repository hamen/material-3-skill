# AGENTS.md

## What this repo is

A Material Design 3 knowledge skill packaged as markdown for AI coding assistants. **No code, no build, no dependencies.** The "product" is `skills/material-3/SKILL.md` and six reference files. CI is a single bash script (`bin/ci`).

Compatible with **OpenCode**, **Claude Code**, and any assistant that reads `SKILL.md` files. Skill auto-discovery:
- **OpenCode:** `opencode.json` at repo root declares `skills.paths` → `skills/`. Also auto-loads from `~/.claude/skills/`.
- **Claude Code:** `.claude-plugin/plugin.json` manifest + `claude plugin install github:hamen/material-3-skill`.

## Quick commands

```bash
./bin/ci                              # validate plugin.json (needs jq) + run layout tests
bash tests/plugin_layout_test.sh      # just the structural checks
```

## Architecture: where to edit

| When you're changing... | Edit this |
|--------------------------|-----------|
| Skill entrypoint, decision tree, audit procedure | `skills/material-3/SKILL.md` |
| Color roles, tonal palettes, dynamic color | `skills/material-3/references/color-system.md` |
| Components (Compose + web mappings) | `skills/material-3/references/component-catalog.md` |
| Theming, dark mode, JS/CSS | `skills/material-3/references/theming-and-dynamic-color.md` |
| Type scale, shape, elevation, motion | `skills/material-3/references/typography-and-shape.md` |
| Navigation patterns | `skills/material-3/references/navigation-patterns.md` |
| Breakpoints, insets, foldables, adaptive layout | `skills/material-3/references/layout-and-responsive.md` |
| Repo overview, install instructions | `README.md` |
| Plugin manifest (version bumps) | `.claude-plugin/plugin.json` |
| OpenCode skill discovery | `opencode.json` |

**Rule:** `SKILL.md` is the index. Put deep detail in `references/`. Keep snippets in `SKILL.md` only when clearly better than linking.

## Platform hierarchy (do not invert)

1. **Jetpack Compose** — primary. New examples default to Compose.
2. **Flutter** — secondary.
3. **Web (`@material/web`)** — limited. Material Web is in **maintenance mode**. M3 Expressive is **not on Web**.

## Facts agents get wrong (verify before claiming)

- **Flutter:** it's `useMaterial3: true` — not `material3: true`.
- **Dynamic color from wallpaper:** Android 12+ (API 31+) only. Not a browser feature.
- **WCAG contrast:** UI component contrast is often 3:1; body text is 4.5:1. Don't conflate them.
- **Shape tokens:** dialog uses `extra-large` (28dp), cards use `medium` (12dp). Don't swap them.
- **@material/web imports:** always import individual components (`import '@material/web/button/filled-button.js'`), never barrel-import `'@material/web'`.
- **M3 Expressive:** never say a feature is "available everywhere." Use the platform matrix pattern from `SKILL.md`.
- **Elevation in MD3:** communicated through tonal surface color, not shadows. Shadows are supplemental only.
- **Roboto:** IS the correct default typeface in MD3 on Android/web. The "avoid Roboto" rule from general frontend guidance does not apply here.

## Structural constraints (enforced by CI)

- No root-level `SKILL.md` or `references/`. Everything lives under `skills/material-3/`.
- `.claude-plugin/plugin.json` must have `"name": "material-3"` and the correct repo URL.
- `README.md` must reference both `claude plugin install github:hamen/material-3-skill` and `skills/material-3/SKILL.md`.

## Versioning

Bump the version in **both** `.claude-plugin/plugin.json` and `README.md` (the version badge and release notes).

## SKILL.md frontmatter

The `SKILL.md` YAML frontmatter has `user-invokable: true` and an `argument-hint` field — these are consumed by skill-aware assistants for auto-discovery. Do not remove them.

## OpenCode specifics

- **`opencode.json`** at repo root uses `skills.paths: ["skills"]` so that running `opencode` from the repo directory auto-discovers the skill. OpenCode walks up from cwd to the worktree root looking for config files.
- **Relative path caveat:** `skills.paths` entries resolve relative to `process.cwd()`, NOT the config file location. Users MUST run `opencode` from the repo root for auto-discovery to work.
- **External skill auto-loading:** OpenCode scans `~/.claude/skills/<name>/SKILL.md` and `~/.agents/skills/<name>/SKILL.md` automatically. A symlink there works without any config.
- **Global registration:** users add the `skills` directory path to `skills.paths` in `~/.config/opencode/opencode.json`. Use an absolute path for this approach.
