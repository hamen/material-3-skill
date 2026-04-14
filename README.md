# cmp-material3-skill

Material Design 3 skill for [Compose Multiplatform](https://www.jetbrains.com/compose-multiplatform/) — Android, iOS, and Desktop.

[![Material Design 3](assets/m3-hero.png)](https://m3.material.io/)

Forked from [hamen/material-3-skill](https://github.com/hamen/material-3-skill) with added Compose Multiplatform guidance, platform adaptation patterns, and cross-platform dependency management.

## What it does

- Guides AI agents in generating **MD3-compliant UI** with correct design tokens, components, theming, layout, and accessibility
- **Primary: Compose Multiplatform** — `MaterialTheme`, Material 3 composables, `expect/actual` patterns for Android + iOS + Desktop
- **Secondary: Jetpack Compose Android-only** — same APIs, with Android-specific features like dynamic color
- Covers **30+ components** with Compose mappings in `references/component-catalog.md`
- Includes CMP-specific guidance: dynamic color fallbacks, platform adaptation, system integration, dependency management
- **11-category MD3 compliance audit** with CMP-specific checks (dependency hygiene, `commonMain` violations, platform fallbacks)

## Platform support

| Platform | Role | Notes |
|----------|------|-------|
| **Compose Multiplatform** | **Primary** | Android + iOS + Desktop. `org.jetbrains.compose.material3` |
| **Jetpack Compose (Android-only)** | Secondary | `androidx.compose.material3`. Subset of CMP |

## What's different from the original

- **CMP-first**: Compose Multiplatform is the primary platform, not Android-only Jetpack Compose
- **No Flutter/Web**: Focused entirely on the Compose ecosystem
- **Platform adaptation guide**: Component-by-component analysis of M3 on iOS, interface vs expect/actual framework ([cmp-platform-adaptation.md](references/cmp-platform-adaptation.md))
- **Dynamic color patterns**: expect/actual patterns with fallback strategies, bridge pattern decision guide ([cmp-dynamic-color.md](references/cmp-dynamic-color.md))
- **System integration**: Insets, fonts (including CMP `Font()` gotcha), status bar — the cross-platform gotchas ([cmp-system-integration.md](references/cmp-system-integration.md))
- **Component architecture**: MVI/MVVM wiring for Snackbar, BottomSheet, Dialog + NavigationSuiteScaffold ([cmp-component-architecture.md](references/cmp-component-architecture.md))
- **CMP dependency tracking**: Correct coordinates, feature parity, version mapping ([cmp-dependencies.md](references/cmp-dependencies.md))
- **Color pairing guide**: Do/Don't for M3 color role usage with accessibility guardrails
- **M2→M3 migration**: Component mapping reference for projects upgrading
- **Enhanced audit**: 12 categories with CMP-specific checks (up from original 10)

## Installation

### Claude Code

```bash
# Clone and symlink
git clone https://github.com/santyas/cmp-material3-skill.git
ln -s /path/to/cmp-material3-skill ~/.claude/skills/cmp-material3-skill
```

### Cursor

```bash
ln -s /path/to/cmp-material3-skill ~/.cursor/skills/cmp-material3-skill
```

## Usage

```
/material-3 component Create a login form with email and password fields
/material-3 theme Generate a theme from seed color #1A73E8
/material-3 scaffold Create a responsive app shell with navigation
/material-3 audit [file path]
```

## What's included

| File | Description |
|------|-------------|
| `SKILL.md` | Main skill: decision trees, token overview, component table, Compose patterns, audit procedure |
| **M3 Spec References** | |
| `references/color-system.md` | Color roles, tonal palettes, dynamic color, baseline schemes |
| `references/component-catalog.md` | 30+ components with Compose mappings |
| `references/theming-and-dynamic-color.md` | Theme generation, brand colors, dark mode |
| `references/typography-and-shape.md` | Type scale, shape, elevation, motion |
| `references/navigation-patterns.md` | Navigation selection, Compose-first adaptive patterns |
| `references/layout-and-responsive.md` | Breakpoints, canonical layouts, insets, foldables |
| **CMP-Specific References** | |
| `references/cmp-dependencies.md` | Maven coordinates CMP vs Jetpack, feature parity, version sync |
| `references/cmp-dynamic-color.md` | Dynamic color fallbacks, expect/actual, iOS/Desktop strategy |
| `references/cmp-system-integration.md` | Insets, safe area, status bar, system fonts, Context-free patterns |
| `references/cmp-platform-adaptation.md` | Platform-specific behavior, M3-pure vs native adaptation |
| `references/cmp-component-architecture.md` | MVI/MVVM wiring for Snackbar, BottomSheet, Dialog; NavigationSuiteScaffold; M2→M3 migration |

## Credits

Original skill by [hamen](https://github.com/hamen). This fork extends it for the Compose Multiplatform community.

## License

MIT
