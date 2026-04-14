# Contributing

This repo is a **Claude Code skill**: markdown that guides agents to produce **Material Design 3**–aligned UI for **Compose Multiplatform**. Keep changes **accurate**, **minimal**, and aligned with the CMP-first story in [README.md](README.md).

## Platform hierarchy (do not invert)

1. **Compose Multiplatform** (`org.jetbrains.compose.material3`) — primary. Android + iOS + Desktop.
2. **Jetpack Compose Android-only** (`androidx.compose.material3`) — secondary, subset of CMP.

Flutter and Web are **out of scope**. Do not add Flutter or Web content.

## M3 Expressive

Do **not** claim a feature is "available everywhere." Check CMP release notes for API availability. Use the platform matrix pattern in [SKILL.md](SKILL.md) with opt-in / BOM caveats where APIs move quickly.

## Facts to double-check

- **Dynamic color from wallpaper:** Android 12+ (API 31+) only — iOS/Desktop need `expect/actual` fallback.
- **CMP coordinates:** `org.jetbrains.compose.material3` in `commonMain`, not `androidx.compose.material3`.
- **System fonts:** `FontFamily.Default` resolves per platform — never hardcode Roboto in `commonMain`.
- **Contrast:** MD3 roles help; still distinguish **UI component** contrast (often 3:1) vs **body text** (typically 4.5:1) per WCAG.
- **Shape:** Keep dialog vs card token usage consistent across [SKILL.md](SKILL.md) and [references/typography-and-shape.md](references/typography-and-shape.md).
- **Tonal palettes:** Do not reintroduce a wrong count for palette stops; see [references/color-system.md](references/color-system.md).

## Where to edit

| Topic | Start here |
|-------|------------|
| Skill entry, decision tree, audit | [SKILL.md](SKILL.md) |
| Color roles, dynamic color | [references/color-system.md](references/color-system.md) |
| Theming, dark mode | [references/theming-and-dynamic-color.md](references/theming-and-dynamic-color.md) |
| Type, shape, motion, elevation | [references/typography-and-shape.md](references/typography-and-shape.md) |
| Components, Compose mappings | [references/component-catalog.md](references/component-catalog.md) |
| Navigation | [references/navigation-patterns.md](references/navigation-patterns.md) |
| Breakpoints, insets, foldables | [references/layout-and-responsive.md](references/layout-and-responsive.md) |
| CMP dependencies, version sync | [references/cmp-dependencies.md](references/cmp-dependencies.md) |
| CMP dynamic color fallbacks | [references/cmp-dynamic-color.md](references/cmp-dynamic-color.md) |
| CMP system integration | [references/cmp-system-integration.md](references/cmp-system-integration.md) |
| CMP platform adaptation (iOS) | [references/cmp-platform-adaptation.md](references/cmp-platform-adaptation.md) |
| Repo overview, install | [README.md](README.md) |

Keep **SKILL.md** as an index; put deep detail in **references/**. CMP-specific files use the `cmp-` prefix.

## PR checklist

- [ ] CMP-first wording preserved. No Flutter or Web content introduced.
- [ ] No `android.*` imports shown in `commonMain` code examples.
- [ ] No contradictory token tables between files.
- [ ] Code snippets are labeled if pseudocode, BOM-dependent, or API-version-sensitive.
- [ ] `expect/actual` patterns used for platform-specific APIs (dynamic color, Context, insets).
- [ ] Official links updated if you change behavior claims ([m3.material.io](https://m3.material.io/), [Android Developers](https://developer.android.com/develop/ui/compose/designsystems/material3)).

Thank you for helping keep this skill trustworthy for readers and agents.
