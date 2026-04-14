# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code skill** (`/material-3`) — a pure markdown documentation repository that guides AI agents to generate Material Design 3 (Material You) compliant UIs. There is no build system, no compiled code, no tests, and no dependencies.

Forked from [hamen/material-3-skill](https://github.com/hamen/material-3-skill) to specialize for **Compose Multiplatform** (Android + iOS + Desktop).

## Architecture

- **SKILL.md** — Main skill entry point (invoked via `/material-3`). Contains the decision tree, design token tables, component quick reference, anti-patterns, M3 Expressive matrix, and the 11-category MD3 compliance audit procedure. Keep this as an index; deep detail belongs in `references/`.
- **references/** — Ten reference files: six M3 spec files (color-system, component-catalog, layout-and-responsive, navigation-patterns, theming-and-dynamic-color, typography-and-shape) plus four CMP-specific files (cmp-dependencies, cmp-dynamic-color, cmp-system-integration, cmp-platform-adaptation). All Compose Multiplatform-first.
- **docs/cmp-material3-skill-design.md** — Internal design spec for the CMP fork.

## Platform Hierarchy (non-negotiable)

1. **Compose Multiplatform** — Primary. Android + iOS + Desktop. All examples default to CMP (`org.jetbrains.compose.material3`).
2. **Jetpack Compose Android-only** — Secondary. `androidx.compose.material3`. Subset of CMP with Android-specific features (dynamic color, etc.).

Flutter and Web are **out of scope** for this fork. Never add Flutter or Web content. Never claim a feature is "available everywhere" — check CMP availability per platform.

## Key Rules When Editing

- Use `md.sys.*` token namespace — never hardcoded color values
- All code examples are Compose Multiplatform / Jetpack Compose only — no Flutter or Web
- Keep SKILL.md as an index; deep technical detail goes in `references/`
- CMP-specific files use `cmp-` prefix in `references/` (won't conflict on upstream merges)
- Inline CMP notes in SKILL.md should be one line max with a link to the reference file
- No contradictory token tables between files
- Code snippets must be labeled if pseudocode, BOM-dependent, or API-version-sensitive

## Git Workflow

- **origin**: `santyas/cmp-material3-skill` (this fork)
- **upstream**: `hamen/material-3-skill` (original)
- **Main branch**: `master`
- **Merge strategy**: Minimize changes to upstream files. All CMP depth goes in new `cmp-*.md` files that upstream will never touch. Upstream merges primarily conflict in SKILL.md and reference files.

## Facts to Double-Check

- Dynamic color from wallpaper: Android 12+ (API 31+) only — iOS/Desktop need fallback
- CMP coordinates: `org.jetbrains.compose.material3` (not `androidx.compose.material3`) in `commonMain`
- WCAG contrast: UI component contrast (3:1) vs body text (4.5:1) — don't conflate
- Shape tokens: keep dialog vs card token usage consistent across SKILL.md and references/typography-and-shape.md
- Tonal palettes: verify stop counts against references/color-system.md
- System fonts: `FontFamily.Default` resolves per platform — never hardcode Roboto in `commonMain`
