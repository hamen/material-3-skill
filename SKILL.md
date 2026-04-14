---
name: material-3
description: >
  Implement Google's Material Design 3 (Material You) UI system. Primary: Compose Multiplatform
  (Android + iOS + Desktop). Secondary: Jetpack Compose Android-only. Covers tokens, 30+ components,
  adaptive layout, theming, dynamic color with cross-platform fallbacks, M3 Expressive,
  platform adaptation patterns, and accessibility. Use when: "material design", "MD3",
  "material you", "Compose Multiplatform", "CMP", "Jetpack Compose", "MaterialTheme",
  "material component", "md3 button".
user-invokable: true
argument-hint: "[component|theme|layout|scaffold|audit] [description or URL]"
---

# Material Design 3

This skill guides implementation of Google's Material Design 3 (MD3) — a personal, adaptive, expressive design system. MD3 uses dynamic color, tonal surfaces, rounded shapes, and spring-based motion to create UIs that feel alive and personal.

## Philosophy

MD3 is built on three principles:
- **Personal**: Dynamic color adapts UI to the user's wallpaper or content. Theming is individual, not one-size-fits-all.
- **Adaptive**: Layouts transform across 5 window size classes. Components resize, reposition, and change form factor responsively.
- **Expressive**: Shape morphing, spring physics, and emphasized typography create moments of delight without sacrificing usability.

**Key differences from MD2:**
- Tonal surfaces replace elevation shadows as the primary depth cue
- Dynamic color generates full schemes from a single seed color
- Fully rounded corners by default (not slightly rounded)
- Spring-based motion physics replace fixed easing curves for components
- 3 levels of user-controlled contrast (standard/medium/high)

**Relationship with frontend-design skill:**
When both skills are active, MD3 provides the design system (tokens, components, layout rules) and frontend-design provides creative direction within those constraints. MD3 rules take precedence for component structure and token usage. Note: Roboto/Roboto Flex IS the correct default typeface in MD3 — the frontend-design guidance to avoid Roboto does not apply when implementing MD3.

## Decision Tree

**What are you building?**
```
Full app scaffold        → See "Common Patterns: App Shell" + references/layout-and-responsive.md
Single component         → See "Component Quick Reference" table → references/component-catalog.md
Custom theme             → See references/theming-and-dynamic-color.md
Form / input layout      → See references/component-catalog.md § Input Components
Navigation structure     → See references/navigation-patterns.md
Data display             → See references/component-catalog.md § Data Display
```

**What platform?**
```
Compose Multiplatform    → Primary: org.jetbrains.compose.material3, MaterialTheme, references/*
                           Android + iOS + Desktop. See references/cmp-dependencies.md for coordinates
Jetpack Compose (Android)→ Secondary: androidx.compose.material3, same APIs, Android-specific features
```

## Design Token System

All MD3 tokens use the `md.sys` namespace. **Compose Multiplatform / Jetpack Compose** maps roles to `MaterialTheme.colorScheme`, `MaterialTheme.typography`, and `MaterialTheme.shapes` (same semantic roles as the spec):

### Color Tokens (`--md-sys-color-*`)
| Token | Purpose |
|-------|---------|
| `primary` | High-emphasis fills, text, icons against surface |
| `on-primary` | Text/icons on primary |
| `primary-container` | Standout fill for key components (FAB, etc.) |
| `on-primary-container` | Text/icons on primary-container |
| `secondary` / `on-secondary` | Less prominent accents |
| `secondary-container` / `on-secondary-container` | Recessive components (tonal buttons) |
| `tertiary` / `on-tertiary` | Contrasting accents |
| `tertiary-container` / `on-tertiary-container` | Complementary containers |
| `error` / `on-error` | Error states (static — doesn't change with dynamic color) |
| `error-container` / `on-error-container` | Error container fills |
| `surface` | Default background |
| `on-surface` | Text/icons on any surface |
| `on-surface-variant` | Lower-emphasis text/icons on surface |
| `surface-container-lowest` | Lowest-emphasis container |
| `surface-container-low` | Low-emphasis container |
| `surface-container` | Default container (nav areas) |
| `surface-container-high` | High-emphasis container |
| `surface-container-highest` | Highest-emphasis container |
| `surface-dim` / `surface-bright` | Maintain relative brightness across light/dark |
| `inverse-surface` / `inverse-on-surface` / `inverse-primary` | Contrasting elements (snackbars) |
| `outline` | Important boundaries (text field borders) |
| `outline-variant` | Decorative elements (dividers) |

Full details: `references/color-system.md`

### Typography Tokens (`--md-sys-typescale-*`)
| Scale | Sizes | Use |
|-------|-------|-----|
| Display | L / M / S | Hero text, large numbers |
| Headline | L / M / S | Section headers |
| Title | L / M / S | Smaller headers, card titles |
| Body | L / M / S | Paragraph text, descriptions |
| Label | L / M / S | Buttons, chips, captions |

Each style has tokens for: `-font`, `-weight`, `-size`, `-line-height`, `-tracking`
Plus 15 **emphasized** variants (higher weight) via `--md-sys-typescale-emphasized-*`

Full details: `references/typography-and-shape.md`

### Shape Tokens (`--md-sys-shape-corner-*`)
| Token | Value | Example components |
|-------|-------|-------------------|
| `none` | 0dp | — |
| `extra-small` | 4dp | Chips, snackbars |
| `small` | 8dp | Text fields, menus |
| `medium` | 12dp | Cards |
| `large` | 16dp | FABs, navigation drawer |
| `large-increased` | 20dp | (Expressive) |
| `extra-large` | 28dp | Dialogs, bottom sheets |
| `extra-large-increased` | 32dp | (Expressive) |
| `extra-extra-large` | 48dp | (Expressive) |
| `full` | 9999px | Buttons, chips, badges |

### Elevation Levels
| Level | DP | Tonal offset | Use |
|-------|-----|-------------|-----|
| 0 | 0dp | None | Flat surfaces, most components at rest |
| 1 | 1dp | +5% primary | Elevated cards, modal sheets |
| 2 | 3dp | +8% primary | Menus, nav bar, scrolled app bar |
| 3 | 6dp | +11% primary | FAB, dialogs, search, date/time pickers |
| 4 | 8dp | +12% primary | (hover/focus increase only) |
| 5 | 12dp | +14% primary | (hover/focus increase only) |

Elevation in MD3 is communicated through **tonal surface color**, not shadows. Shadows are only used when needed for additional protection against busy backgrounds.

### Motion
MD3 Expressive (May 2025) introduced **spring-based motion physics** for components. The legacy easing/duration system is still used for **transitions** (enter/exit/shared-axis):

| Easing | Duration | Transition type |
|--------|----------|-----------------|
| Emphasized | 500ms | Begin and end on screen |
| Emphasized decelerate | 400ms | Enter the screen |
| Emphasized accelerate | 200ms | Exit the screen |
| Standard | 300ms | Begin and end on screen (utility) |
| Standard decelerate | 250ms | Enter screen (utility) |
| Standard accelerate | 200ms | Exit screen (utility) |

CSS easing values:
- Emphasized: `cubic-bezier(0.2, 0, 0, 1)`
- Emphasized decelerate: `cubic-bezier(0.05, 0.7, 0.1, 1)`
- Emphasized accelerate: `cubic-bezier(0.3, 0, 0.8, 0.15)`
- Standard: `cubic-bezier(0.2, 0, 0, 1)`
- Standard decelerate: `cubic-bezier(0, 0, 0, 1)`
- Standard accelerate: `cubic-bezier(0.3, 0, 1, 1)`

## Component Quick Reference

| Component | Compose | Key Variants | Category |
|-----------|---------|--------------|----------|
| Button | `Button`, `OutlinedButton`, `TextButton`, `ElevatedButton`, `FilledTonalButton` | Filled, Outlined, Text, Elevated, Tonal; 5 sizes (XS–XL); toggle | Actions |
| Button group | — | Standard, connected | Actions |
| Extended FAB | `ExtendedFloatingActionButton` | Surface, Primary, Secondary, Tertiary | Actions |
| FAB | `FloatingActionButton`, `SmallFloatingActionButton`, `LargeFloatingActionButton` | Small, Medium, Large | Actions |
| FAB menu | — | — | Actions |
| Icon button | `IconButton`, `FilledIconButton`, `FilledTonalIconButton`, `OutlinedIconButton` | Standard, Filled, Filled Tonal, Outlined | Actions |
| Segmented button | `SegmentedButton`, `SingleChoiceSegmentedButtonRow`, `MultiChoiceSegmentedButtonRow` | Single-select, Multi-select | Actions |
| Split button | — | — | Actions |
| Badge | `Badge`, `BadgedBox` | Small (dot), Large (count) | Communication |
| Loading indicator | `LinearProgressIndicator`, `CircularProgressIndicator` | Linear, Circular | Communication |
| Progress indicator | `LinearProgressIndicator`, `CircularProgressIndicator` | Linear, Circular; determinate/indeterminate | Communication |
| Snackbar | `Snackbar`, `SnackbarHost` | Single-line, Two-line, Action | Communication |
| Tooltip | `PlainTooltip`, `RichTooltip` | Plain, Rich | Communication |
| Card | `Card`, `OutlinedCard`, `ElevatedCard` | Filled, Outlined, Elevated | Containment |
| Carousel | — | Multi-browse, Uncontained, Hero | Containment |
| Dialog | `AlertDialog`, `BasicAlertDialog` | Basic, Full-screen | Containment |
| Bottom sheet | `ModalBottomSheet` | Standard, Modal | Sheets |
| Side sheet | — | Standard, Modal | Sheets |
| Divider | `HorizontalDivider`, `VerticalDivider` | Full-width, Inset | Containment |
| Checkbox | `Checkbox`, `TriStateCheckbox` | — | Input |
| Chips | `AssistChip`, `FilterChip`, `InputChip`, `SuggestionChip` | Assist, Filter, Input, Suggestion | Input |
| Date picker | `DatePicker`, `DateRangePicker`, `DatePickerDialog` | Docked, Modal, Range | Input |
| Menu | `DropdownMenu`, `DropdownMenuItem` | — | Input |
| Radio button | `RadioButton` | — | Input |
| Slider | `Slider`, `RangeSlider` | Continuous, Discrete, Range | Input |
| Switch | `Switch` | With/without icon | Input |
| Text field | `TextField`, `OutlinedTextField` | Filled, Outlined | Input |
| Time picker | `TimePicker`, `TimeInput` | Docked, Modal | Input |
| App bar (top) | `TopAppBar`, `CenterAlignedTopAppBar`, `MediumTopAppBar`, `LargeTopAppBar` | Center-aligned, Small, Medium, Large | Navigation |
| Navigation bar | `NavigationBar`, `NavigationBarItem` | — | Navigation |
| Navigation drawer | `ModalNavigationDrawer`, `DismissibleNavigationDrawer`, `PermanentNavigationDrawer` | Standard, Modal | Navigation |
| Navigation rail | `NavigationRail`, `NavigationRailItem` | — | Navigation |
| Search | `SearchBar`, `DockedSearchBar` | Search bar, Search view | Navigation |
| Tabs | `TabRow`, `Tab`, `SecondaryTabRow` | Primary, Secondary | Navigation |
| Toolbar | — | — | Navigation |
| List | `ListItem` | One-line, Two-line, Three-line | Data Display |

**Note:** Components marked with `—` for Compose may require custom implementation or check your CMP/BOM version for availability. Full component details: `references/component-catalog.md`.

Full component details with code examples: `references/component-catalog.md`

## Compose Multiplatform (primary)

Use Material 3 composables (`Scaffold`, `Button`, `NavigationBar`, top app bars, etc.) with `MaterialTheme`. In CMP projects, use `org.jetbrains.compose.material3` coordinates; for Android-only Jetpack Compose, use `androidx.compose.material3`.

- **Theming**: `MaterialTheme(colorScheme = …, typography = …, shapes = …)`. Use `expect/actual` to provide platform-specific color schemes — dynamic color on Android 12+, fallback seed color on iOS/Desktop.
- **Adaptive UI**: Window size classes, list-detail and supporting-pane layouts, foldables — see `references/layout-and-responsive.md` and `references/navigation-patterns.md`.
- **Edge-to-edge & insets**: Lay out content with `WindowInsets` / scaffold padding so bars and IME behave correctly — see `references/layout-and-responsive.md`.
- **Experimental APIs**: Some Material 3 APIs require `@OptIn(ExperimentalMaterial3Api::class)` or expressive opt-ins; match your BOM and compiler.

> **CMP note:** Dynamic color is Android-only. See [cmp-dynamic-color.md](references/cmp-dynamic-color.md) for multiplatform fallback patterns.

> **CMP note:** Use CMP Maven coordinates, not Jetpack-only. See [cmp-dependencies.md](references/cmp-dependencies.md) for correct setup.

> **CMP note:** Insets and system UI differ by platform. See [cmp-system-integration.md](references/cmp-system-integration.md).

> **CMP note:** For Snackbar/BottomSheet/Dialog wiring with ViewModel and NavigationSuiteScaffold, see [cmp-component-architecture.md](references/cmp-component-architecture.md).

```kotlin
MaterialTheme(
    colorScheme = colorScheme, // from expect/actual platformColorScheme() or lightColorScheme()
    typography = Typography(),
    shapes = Shapes(),
) {
    // M3 content — prefer references for Scaffold, navigation, text fields
}
```

## Common Patterns

### App Shell

Standard MD3 app with responsive navigation + top app bar + content area. See `references/navigation-patterns.md` for the full responsive navigation pattern (bar → rail → drawer across breakpoints) and `references/layout-and-responsive.md` for canonical layouts.

```kotlin
// Conceptual — responsive app shell
val windowSizeClass = calculateWindowSizeClass(activity)

Scaffold(
    bottomBar = {
        if (windowSizeClass.widthSizeClass == WindowWidthSizeClass.Compact) {
            NavigationBar { /* 3-5 destinations */ }
        }
    }
) { innerPadding ->
    Row(Modifier.padding(innerPadding)) {
        if (windowSizeClass.widthSizeClass == WindowWidthSizeClass.Medium) {
            NavigationRail { /* same destinations */ }
        }
        if (windowSizeClass.widthSizeClass == WindowWidthSizeClass.Expanded) {
            PermanentNavigationDrawer(drawerContent = { /* destinations */ }) {}
        }
        // Content area
        NavHost(navController, startDestination = "home") { /* routes */ }
    }
}
```

More patterns: `references/navigation-patterns.md`, `references/layout-and-responsive.md`

## Anti-Patterns

**Never do these when implementing MD3:**

- **Mix Material2 and Material3 imports**: Don't import from both `androidx.compose.material` (M2) and `androidx.compose.material3` (M3). They have incompatible theming and component APIs.
- **Hardcode colors**: Always use `MaterialTheme.colorScheme.*` tokens, never raw `Color(0x...)` values. Hardcoded colors break dynamic theming, dark mode, and contrast adjustment.
- **Ignore tonal pairing**: Only combine colors in their intended pairs (e.g., `primary` + `onPrimary`, `surfaceContainer` + `onSurface`). Arbitrary pairings break contrast in dynamic color and high contrast modes.
- **Use `outline` for dividers**: Use `outlineVariant` for dividers. `outline` is for important boundaries like text field borders.
- **Use shadows for elevation by default**: MD3 communicates elevation through tonal surface color, not shadows. Only add shadows when elements need extra separation from busy backgrounds.
- **Apply frontend-design "avoid Roboto" rule**: On **Android**, **Roboto** is the default Material typeface. Replace only when intentionally customizing the type scale. On **iOS**, `FontFamily.Default` resolves to San Francisco.
- **Use `android.*` imports in `commonMain`**: CMP `commonMain` code cannot reference Android-specific APIs. Use `expect/actual` patterns — see [cmp-system-integration.md](references/cmp-system-integration.md).
- **Use `dynamicLightColorScheme` without fallback**: Dynamic color is Android 12+ only. Always provide a seed-based fallback for iOS and Desktop — see [cmp-dynamic-color.md](references/cmp-dynamic-color.md).
- **Use Jetpack-only Maven coordinates in CMP**: Use `org.jetbrains.compose.material3:material3`, not `androidx.compose.material3:material3` in `commonMain` — see [cmp-dependencies.md](references/cmp-dependencies.md).
- **Hardcode `Roboto` font in `commonMain`**: Use `FontFamily.Default` (resolves to system font per platform) or load a custom font via `Res.font`. Hardcoding Roboto looks wrong on iOS.
- **Ignore foldables and large screens**: MD3 is designed for all screen sizes. Don't ship phone-only layouts — use canonical layouts, multi-pane at 600dp+, and test on foldable/tablet emulators. Place no interactive content across the fold/hinge.
- **Stretch content to fill wide screens**: On Large (1200dp+) and Extra-large (1600dp+) windows, constrain content to a max width (840–1040dp). Endless-width text lines are unreadable.

## Platform Notes

### Compose Multiplatform
See **[Compose Multiplatform (primary)](#compose-multiplatform-primary)** above. Use `expect/actual` to provide `ColorScheme` per platform. On Android: `dynamicLightColorScheme` / `dynamicDarkColorScheme` when `Build.VERSION.SDK_INT >= Build.VERSION_CODES.S`; on iOS/Desktop: seed-based fallback. See [cmp-dynamic-color.md](references/cmp-dynamic-color.md).

> **CMP note:** For platform-specific component behavior and iOS friction analysis, see [cmp-platform-adaptation.md](references/cmp-platform-adaptation.md).

## M3 Expressive (May 2025)

The Expressive update adds visual richness while maintaining usability. Check your Compose Multiplatform / Jetpack Compose BOM version for API availability.

| Capability | Compose Multiplatform / Jetpack Compose |
|------------|----------------------------------------|
| Spring / motion physics | Supported via `MotionScheme` and expressive APIs (check BOM version) |
| Emphasized typography | Via theme / type scale |
| Shape morphing | Compose-first in Google’s expressive rollout |
| New button sizes (XS–XL), toggle | Follow Compose Material3 components |
| Extra corner tokens (e.g. large-increased) | `MaterialTheme.shapes` / tokens |
| 3 contrast levels | Scheme builders / system (Android); manual on other platforms |

**Legacy easing/duration** remains valid for **transitions** (enter/exit/shared-axis) where the spec still references them; see the Motion table in `references/typography-and-shape.md`.

## MD3 Compliance Audit

When invoked with `audit` as the argument (e.g., `/material-3 audit`), or when asked to audit/review MD3 compliance, analyze the target app or page and produce a compliance report.

### Audit Procedure

1. **Identify the target**: The user provides a URL (use browser tools to inspect), file paths (read source), or a running app.
2. **Inspect the following categories** and score each 0–10:

| # | Category | What to check |
|---|----------|--------------|
| 1 | **Color tokens** | `MaterialTheme.colorScheme` roles used consistently (no arbitrary `Color(0x...)` for surfaces). Proper tonal pairing (`onX` on `X`) — see color-system.md Do/Don't. Dark theme. **CMP:** Check for hardcoded `dynamicLightColorScheme` without fallback; verify `expect/actual` pattern exists. |
| 2 | **Typography** | MD3 type scale via `MaterialTheme.typography`; correct roles (Display, Headline, Title, Body, Label). **CMP:** No hardcoded `Roboto` — use `FontFamily.Default` or custom font. Flag non-composable `Font()` usage (CMP `Font(Res.font.*)` is `@Composable`). |
| 3 | **Shape** | `MaterialTheme.shapes` / component `Shape` params. Buttons: full; cards: medium; avoid magic numbers. |
| 4 | **Elevation** | Tonal elevation (`Surface` tonal/shadow as appropriate). Hover/focus elevation changes where relevant. |
| 5 | **Components** | Material3 composables (`Button`, `Scaffold`, etc.) used correctly. Correct variants. **CMP:** Flag `LocalContext.current` usage in `commonMain`. Check Snackbar uses effect channel (not consumable boolean). |
| 6 | **Layout** | Canonical layouts; window size class / adaptive APIs; readable max width on large screens; foldable hinge avoidance. **CMP:** Check window size class uses CMP-compatible coordinates. Check for `NavigationSuiteScaffold` usage. |
| 7 | **Navigation** | Bar / rail / drawer per size class; `NavHost` patterns; predictive back where applicable. **CMP:** Note if navigation pattern may feel non-native on iOS — see [cmp-platform-adaptation.md](references/cmp-platform-adaptation.md). |
| 8 | **Motion** | `MotionScheme` / expressive APIs when used; transitions may still use easing/duration. |
| 9 | **Accessibility** | **Verify contrast**: UI components need **3:1** for large text/borders and **4.5:1** for normal text (WCAG 2.x). Verify `contentDescription` on meaningful images. Check 48dp touch targets. Verify color is not sole status indicator. TalkBack/semantics, focus order. **CMP:** Note TalkBack vs VoiceOver semantic differences. |
| 10 | **Theming** | `MaterialTheme` + light/dark/dynamic as designed. **CMP:** Verify `expect/actual` exists for platform-specific theme components. |
| 11 | **CMP dependency hygiene** | Verify coordinates are CMP (`org.jetbrains.compose.*`), not Jetpack-only (`androidx.compose.*`) in `commonMain`. No `android.*` imports in `commonMain`. |
| 12 | **Component architecture** | Snackbar/Sheet use Effect channel (not state booleans). Dialog uses state flag (acceptable). M2 components flagged for migration (`BottomNavigation` → `NavigationBar`, etc.). See [cmp-component-architecture.md](references/cmp-component-architecture.md). |

3. **Generate the report**:

```
# MD3 Compliance Audit Report

Target: [URL or file path]
Date: [date]
Overall Score: [X/120]

## Scores by Category
| Category              | Score | Status |
|-----------------------|-------|--------|
| Color tokens          | X/10  | [pass/warn/fail] |
| Typography            | X/10  | [pass/warn/fail] |
| Shape                 | X/10  | [pass/warn/fail] |
| Elevation             | X/10  | [pass/warn/fail] |
| Components            | X/10  | [pass/warn/fail] |
| Layout                | X/10  | [pass/warn/fail] |
| Navigation            | X/10  | [pass/warn/fail] |
| Motion                | X/10  | [pass/warn/fail] |
| Accessibility         | X/10  | [pass/warn/fail] |
| Theming               | X/10  | [pass/warn/fail] |
| CMP dependency hygiene| X/10  | [pass/warn/fail] |
| Component architecture| X/10  | [pass/warn/fail] |

## Critical Issues
[List items scoring 0-3 with specific file:line references and fixes]

## Warnings
[List items scoring 4-6 with recommendations]

## Passing
[List items scoring 7-10 with notes on what's done well]

## Recommended Fixes (Priority Order)
1. [Most impactful fix first]
2. ...
```

### Audit Methods

**For source code** (file paths provided):
- **Compose/Kotlin:** `.kt` files — `MaterialTheme`, composables, `Color(0x…)` abuse, hard-coded `Dp`, missing `Modifier.semantics` where needed
- **CMP:** Check `commonMain` for Android-only imports, Jetpack-only coordinates, missing `expect/actual`

**Quick checks** (adapt paths to your codebase):
```
# Compose: raw Color(...) usage
grep -rn 'Color(0x' --include='*.kt'

# CMP: android imports in commonMain
grep -rn 'import android\.' --include='*.kt' src/commonMain/

# CMP: Jetpack-only coordinates in common build
grep -rn 'androidx\.compose' build.gradle.kts

# CMP: hardcoded Roboto in commonMain
grep -rn 'Roboto' --include='*.kt' src/commonMain/

# M2/M3 mixing
grep -rn 'androidx.compose.material[^3]' --include='*.kt'
```

### Scoring Guide

- **9-10**: Fully MD3 compliant, uses correct tokens and patterns
- **7-8**: Mostly compliant, minor issues (e.g., a few hardcoded values)
- **4-6**: Partially compliant, some MD3 patterns but significant gaps
- **1-3**: Major violations, mostly non-MD3 or MD2 patterns
- **0**: Not applicable or completely absent

Status thresholds: **pass** (7+), **warn** (4-6), **fail** (0-3)

## Reference Documents

### M3 Spec References
- `references/color-system.md` — Color roles, tonal palettes, dynamic color, scheme generation
- `references/typography-and-shape.md` — Type scale, shape corners, elevation, motion, Expressive notes
- `references/component-catalog.md` — 30+ components with Compose mappings
- `references/navigation-patterns.md` — Navigation selection, Compose-first adaptive patterns
- `references/layout-and-responsive.md` — Breakpoints, canonical layouts, insets, foldables
- `references/theming-and-dynamic-color.md` — Theming with MaterialTheme, dynamic color, brand integration

### CMP-Specific References
- `references/cmp-dependencies.md` — Maven coordinates CMP vs Jetpack, feature parity, version sync
- `references/cmp-dynamic-color.md` — Dynamic color fallbacks, expect/actual color scheme, iOS/Desktop strategy
- `references/cmp-system-integration.md` — Insets, safe area, status bar, system fonts, Context-free patterns
- `references/cmp-platform-adaptation.md` — Platform-specific component behavior, M3-pure vs native adaptation
- `references/cmp-component-architecture.md` — MVI/MVVM wiring for Snackbar, BottomSheet, Dialog; NavigationSuiteScaffold; M2→M3 migration
