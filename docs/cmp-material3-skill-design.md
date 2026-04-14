# cmp-material3-skill — Design Spec

**Date**: 2026-04-14
**Origin**: Fork of [hamen/material-3-skill](https://github.com/hamen/material-3-skill)
**Purpose**: Community resource — the reference Material Design 3 skill for Compose Multiplatform

---

## 1. Identity

| Field | Value |
|---|---|
| Name | `cmp-material3-skill` |
| Primary audience | Compose Multiplatform developers (Android + iOS + Desktop) |
| Secondary audience | Jetpack Compose Android-only developers |
| Out of scope | Flutter, Web |
| Positioning | "Material Design 3 skill for Compose Multiplatform" |
| License | MIT (same as upstream) |

Credit to the original skill by hamen must be explicit in the README and preserved across versions.

---

## 2. Strategy: CMP Overlay on Upstream

### Principle

Minimize changes to upstream files. Maximize CMP value through dedicated new files that upstream will never touch.

### Merge model

- `git remote add upstream https://github.com/hamen/material-3-skill.git`
- Periodic `git fetch upstream && git merge upstream/main`
- Conflict surface: primarily `SKILL.md` and cleaned reference files
- New `references/cmp-*.md` files never conflict (upstream doesn't have them)

### One-time upstream cleanup

- Remove all Flutter content (secondary platform in original)
- Remove all Web content (maintenance mode in original)
- This creates an initial diff that may complicate the first merge, but stabilizes afterward

---

## 3. File Structure

```
cmp-material3-skill/
├── README.md                              # New — positioning, installation, credits
├── SKILL.md                               # Modified from upstream
├── references/
│   ├── color-system.md                    # Upstream (cleaned: no Flutter/Web)
│   ├── components.md                      # Upstream (cleaned)
│   ├── layout-responsive.md               # Upstream (cleaned)
│   ├── navigation.md                      # Upstream (cleaned)
│   ├── theming-dynamic-color.md           # Upstream (cleaned)
│   ├── typography-shape-motion.md         # Upstream (cleaned)
│   ├── cmp-dynamic-color.md               # NEW
│   ├── cmp-platform-adaptation.md         # NEW
│   ├── cmp-dependencies.md                # NEW
│   ├── cmp-system-integration.md          # NEW
│   └── cmp-component-architecture.md      # NEW — MVI/MVVM wiring for M3 components
└── scripts/
    └── validate.sh                        # Upstream (if present)
```

---

## 4. Changes to SKILL.md

### 4.1 Platform hierarchy

Replace the original hierarchy:

```
# Original
1. Jetpack Compose (primary)
2. Flutter (secondary)
3. Web (maintenance mode)

# Fork
1. Compose Multiplatform — Android + iOS + Desktop (primary)
2. Jetpack Compose Android-only (secondary, subset of above)
```

### 4.2 CMP routing in references section

Add routing entries for the new CMP files:

- **Dynamic color fallbacks, expect/actual color scheme, iOS strategy** → `cmp-dynamic-color.md`
- **Platform-specific component behavior, M3-pure vs native adaptation** → `cmp-platform-adaptation.md`
- **Maven coordinates CMP vs Jetpack, feature parity, version sync** → `cmp-dependencies.md`
- **Insets, safe area, status bar, system fonts, Context-free patterns** → `cmp-system-integration.md`
- **MVI/MVVM wiring for Snackbar, BottomSheet, Dialog, NavigationSuiteScaffold** → `cmp-component-architecture.md`

### 4.3 Inline CMP notes

In sections where CMP behavior critically differs, add a single-line note with link. Example:

> **CMP note:** Dynamic color is Android-only. See [cmp-dynamic-color.md](references/cmp-dynamic-color.md) for multiplatform fallback patterns.

Keep these minimal — one line max, link to the reference file for details.

### 4.4 Remove Flutter/Web

- Delete all Flutter code examples, config snippets, and platform notes
- Delete all Web/CSS references and `@material/web` mentions
- Clean up any "Platform Support" tables to show only Compose

---

## 5. New CMP Reference Files

### 5.1 `cmp-dynamic-color.md`

**Why this matters**: Dynamic color is the most visible M3 feature and it's Android-only. Every CMP project hits this gap.

**Content**:

- Why dynamic color doesn't exist on iOS (no wallpaper extraction API)
- **Bridge pattern decision**: use `expect/actual` function (not interface+DI) because this is a stateless platform fact with no lifecycle

  | Need | Pattern | Rationale |
  |---|---|---|
  | ColorScheme per platform | `expect/actual` function | Stateless, no DI overhead |
  | Theme with user preferences | Interface + DI (Koin) | Has state (user choice), needs fakes for testing |

- `expect/actual` pattern for providing `ColorScheme` per platform:
  - `androidMain`: `dynamicLightColorScheme(context)` / `dynamicDarkColorScheme(context)` with API 31+ check
  - `iosMain`: fallback `ColorScheme` from seed color
  - `commonMain`: `expect fun platformColorScheme(darkTheme: Boolean): ColorScheme?`
- Fallback strategies for non-Android platforms:
  - Fixed seed color (simplest)
  - User preference / theme picker (best UX)
  - Brand color extraction (good for white-label apps)
- Complete code example: `commonMain` → `androidMain` → `iosMain`
- Dark theme considerations per platform
- Desktop: no dynamic color, same fallback as iOS

### 5.2 `cmp-platform-adaptation.md`

**Why this matters**: The #1 question CMP developers have about M3 is "will this feel wrong on iOS?"

**Content**:

- **Skill position: M3 pure cross-platform**, with explicit documentation of where iOS users may feel friction
- Component-by-component analysis:

| Component | M3 behavior | iOS expectation | Friction level | Guidance |
|---|---|---|---|---|
| NavigationBar | Bottom, 3-5 items, labels | UITabBar, different styling | Medium | Use M3, acceptable |
| BottomSheet | M3 drag handle, scrim | iOS sheet physics, detents | High | Consider platform-specific impl |
| DatePicker | M3 calendar/input | iOS wheel picker | High | Document both options |
| Dialog | M3 centered dialog | iOS action sheet / alert | Medium | Use M3, acceptable |
| Snackbar | M3 bottom snackbar | iOS doesn't have equivalent | Low | Use M3 |
| FAB | M3 floating action button | No iOS equivalent | Low | Use M3 |
| TopAppBar | M3 center/large | iOS UINavigationBar | Medium | Use M3, note differences |

- Haptics and ripple:
  - Android: Ripple `Indication` is standard M3
  - iOS: Users expect highlight, not ripple
  - How `Indication` behaves cross-platform in CMP
  - Whether to customize per platform (and when it's worth it)
  - Pattern: model haptics as semantic effects via interface+DI (same as compose-skill cross-platform pattern):
    ```kotlin
    enum class HapticType { Confirm, Error, Selection }
    interface Haptics { fun perform(type: HapticType) }
    ```
- **Interface vs expect/actual decision framework** (sourced from compose-skill cross-platform patterns):

  | Need | Pattern | Why |
  |---|---|---|
  | Service with lifecycle/state/async (haptics, analytics) | Interface + DI | Testable, fakeable, swappable |
  | Stateless platform fact (UUID, platform name, default font) | `expect/actual` function | No DI overhead for one-liner |
  | Reuse existing platform type in common signature | `expect class` + `actual typealias` | Rare — prefer interface |

- When to break M3 for platform convention:
  - Rule of thumb: break M3 only for navigation patterns and system-level interactions (share sheets, permissions dialogs)
  - Never break M3 for: color, typography, shape, elevation (these are the identity of the design system)

### 5.3 `cmp-dependencies.md`

**Why this matters**: Wrong Maven coordinates is the #1 setup error for CMP beginners.

**Content**:

- Dependency coordinates table:

| Library | Jetpack Compose | Compose Multiplatform |
|---|---|---|
| Material3 core | `androidx.compose.material3:material3` | `org.jetbrains.compose.material3:material3` |
| Material3 adaptive | `androidx.compose.material3.adaptive:*` | Check availability per version |
| Window size classes | `androidx.compose.material3:material3-window-size-class` | `org.jetbrains.compose.material3:material3-window-size-class` (verify) |
| Material icons extended | `androidx.compose.material:material-icons-extended` | `org.jetbrains.compose.material:material-icons-extended` |

- Feature parity tracker:
  - What exists in Jetpack M3 that hasn't arrived in CMP yet
  - How to check: JetBrains Compose Multiplatform releases changelog
  - Workarounds for missing features
- Version synchronization notes:
  - CMP versions don't map 1:1 to Jetpack versions
  - How to find the Jetpack version bundled inside a CMP release
- BOM usage differences

### 5.4 `cmp-system-integration.md`

**Why this matters**: System UI integration is where "write once" breaks down. Every CMP project needs these patterns.

**Content**:

- **Edge-to-edge / insets**:
  - Android: `enableEdgeToEdge()`, `WindowInsets` APIs
  - iOS: SafeArea via `UIKit` bridge
  - CMP pattern: `expect/actual` or libraries like `insetsx`
  - Code example for common status bar + navigation bar handling
- **System fonts**:
  - Android default: Roboto
  - iOS default: San Francisco (cannot be explicitly loaded)
  - `FontFamily.Default` resolves to system font per platform
  - Loading custom fonts via `Res.font` (works cross-platform)
  - When to use system font vs custom font (recommendation: custom for brand consistency)
- **CMP Font() gotcha** (critical): In CMP, `Font(Res.font.*)` is `@Composable` (unlike Jetpack where it's a regular function). This means `Typography` construction must happen inside composition:
  ```kotlin
  // CMP — Font() is composable, so Typography must be built inside @Composable
  @Composable
  fun AppTypography(): Typography {
      val fontFamily = FontFamily(
          Font(Res.font.Inter_Regular, FontWeight.Normal),
          Font(Res.font.Inter_Bold, FontWeight.Bold),
      )
      return MaterialTheme.typography.copy(
          bodyLarge = MaterialTheme.typography.bodyLarge.copy(fontFamily = fontFamily),
          titleLarge = MaterialTheme.typography.titleLarge.copy(fontFamily = fontFamily),
      )
  }

  // Jetpack Android — Font() is NOT composable, can be a top-level val
  val AppTypography = Typography(
      bodyLarge = TextStyle(fontFamily = InterFont, ...),
  )
  ```
  This is one of the most common CMP migration surprises and must be documented prominently.
- **Status bar styling**:
  - Android: `WindowInsetsController` or `enableEdgeToEdge()` with dark/light
  - iOS: `UIStatusBarStyle` via `expect/actual`
  - Code example for toggling light/dark status bar icons
- **Context-free patterns**:
  - Problem: many Android M3 APIs need `Context` (dynamic color, configuration, etc.)
  - Solution patterns for `commonMain`:
    - `expect/actual` that takes no `Context` in the signature
    - Koin DI to provide platform-specific implementations
    - `LocalPlatformContext` (if available in CMP version)
  - List of common APIs that need this treatment

### 5.5 `cmp-component-architecture.md`

**Why this matters**: The upstream skill catalogs 30+ M3 components but doesn't show how to wire them with ViewModel architecture. CMP projects need this because the wiring differs from Android-only Compose (no `Activity` context, different lifecycle).

**Content**:

- **Snackbar wiring with ViewModel effects**:
  - `SnackbarHostState` remembered in Route composable
  - ViewModel emits `Effect.ShowSnackbar(message)` via `Channel<Effect>(Channel.BUFFERED)`
  - Route collects effects and calls `snackbarHostState.showSnackbar()`
  - Anti-pattern: never use `showSnackbar: Boolean` in state (event replay on config change)
  - Complete code example with action handling

- **BottomSheet wiring**:
  - `ModalBottomSheet` with `rememberModalBottomSheetState()`
  - ViewModel emits `Effect.ShowSheet` / state flag controls visibility
  - Route calls `sheetState.show()` / `sheetState.hide()` from effect collector
  - CMP note: sheet physics may feel different on iOS

- **Dialog wiring**:
  - Dialog visibility via `state.showDialog: Boolean` (acceptable here — dialogs are state, not one-shots)
  - Confirm/dismiss dispatch events back to ViewModel
  - `AlertDialog` for simple confirm, custom `Dialog` for forms

- **NavigationSuiteScaffold** (from compose-skill, not in upstream):
  - Auto-switches `NavigationBar` / `NavigationRail` / `NavigationDrawer` by window size
  - Eliminates manual window-size-class branching
  - Code example:
    ```kotlin
    NavigationSuiteScaffold(
        navigationSuiteItems = {
            destinations.forEach { dest ->
                item(
                    selected = currentDest == dest,
                    onClick = { currentDest = dest },
                    icon = { Icon(dest.icon, contentDescription = null) },
                    label = { Text(dest.label) }
                )
            }
        }
    ) { DestinationContent(currentDest) }
    ```
  - CMP availability note: verify artifact exists for CMP targets before recommending

- **M2 to M3 migration quick reference** (from compose-skill):

  | M2 | M3 |
  |---|---|
  | `Colors` | `ColorScheme` |
  | `lightColors()` / `darkColors()` | `lightColorScheme()` / `darkColorScheme()` |
  | `BottomNavigation` | `NavigationBar` |
  | `BottomNavigationItem` | `NavigationBarItem` |
  | `ModalBottomSheetLayout` | `ModalBottomSheet` |
  | `ModalDrawer` | `ModalNavigationDrawer` |
  | `Scaffold` with `scaffoldState` | `Scaffold` with `snackbarHost` slot |
  | `TopAppBar` elevation | `TopAppBar` with `scrollBehavior` |

---

## 6. Enhancements to Upstream Reference Files

Changes to apply to the cleaned (no Flutter/Web) upstream references.

### 6.1 `color-system.md` — Add Do/Don't pairing rules

Add a practical pairing table (sourced from compose-skill material-design reference):

**Color role pairing rules:**

| Container | Content on it |
|---|---|
| `primary` | `onPrimary` |
| `primaryContainer` | `onPrimaryContainer` |
| `secondary` | `onSecondary` |
| `secondaryContainer` | `onSecondaryContainer` |
| `tertiary` | `onTertiary` |
| `tertiaryContainer` | `onTertiaryContainer` |
| `surface` | `onSurface` |
| `surfaceVariant` | `onSurfaceVariant` |
| `error` | `onError` |
| `errorContainer` | `onErrorContainer` |

**Do / Don't:**

| Do | Don't |
|---|---|
| `containerColor = primary`, `contentColor = onPrimary` | `containerColor = primary`, `contentColor = tertiaryContainer` |
| Access colors via `MaterialTheme.colorScheme.*` | Hardcode hex colors in components |
| Test both light and dark themes | Assume light-only usage |
| M3 tonal palettes guarantee 3:1+ contrast when paired correctly | Mix unrelated pairs across accent families |

### 6.2 `navigation.md` — Add NavigationSuiteScaffold

Document `NavigationSuiteScaffold` as the recommended default for adaptive navigation with 3-5 destinations, with CMP availability note.

### 6.3 `components.md` — Add accessibility integration

For each component, note:
- Required `contentDescription` values
- Semantic role (auto-provided by M3 components vs manual)
- Touch target compliance (48dp minimum)
- WCAG contrast: never use color alone to convey state — pair with icon/text

---

## 7. Audit Framework Updates

Maintain the original 10-category M3 compliance audit, adding CMP-specific checks:

| # | Original category | CMP addition |
|---|---|---|
| 1 | Color tokens | Check for hardcoded `dynamicLightColorScheme` without fallback; verify role pairing (never mix unrelated `on*` colors) |
| 2 | Typography roles | Check for hardcoded `Roboto` instead of `FontFamily.Default` or custom; flag non-composable `Font()` usage in CMP |
| 3 | Shape consistency | No CMP-specific changes |
| 4 | Elevation communication | No CMP-specific changes |
| 5 | Component correctness | Flag `LocalContext.current` usage in `commonMain`; check component wiring uses effects (not consumable booleans) for Snackbar |
| 6 | Layout patterns | Check window size class implementation is multiplatform-compatible; check for `NavigationSuiteScaffold` usage |
| 7 | Navigation structure | Note if navigation pattern may feel non-native on iOS |
| 8 | Motion implementation | No CMP-specific changes |
| 9 | Accessibility contrast | Verify `contentDescription` on meaningful images; check 48dp touch targets; verify color is not sole status indicator; note TalkBack vs VoiceOver semantic differences |
| 10 | Theming completeness | Verify `expect/actual` exists for platform-specific theme components |

New audit items:

| # | Category | Checks |
|---|---|---|
| 11 | CMP dependency hygiene | Verify coordinates are CMP (not Jetpack-only), no `android.*` imports in `commonMain` |
| 12 | Component architecture | Snackbar/Sheet use Effect channel (not state booleans); Dialog uses state flag (acceptable); M2 components flagged for migration |

---

## 8. README

```markdown
# cmp-material3-skill

Material Design 3 skill for [Compose Multiplatform](https://www.jetbrains.com/compose-multiplatform/) — Android, iOS, and Desktop.

Forked from [hamen/material-3-skill](https://github.com/hamen/material-3-skill) with added Compose Multiplatform guidance,
platform adaptation patterns, and cross-platform dependency management.

## Installation

### Claude Code
Symlink or clone to `~/.claude/skills/cmp-material3-skill`

### Cursor
Symlink or clone to `~/.cursor/skills/cmp-material3-skill`

## What's different from the original

- **CMP-first**: Compose Multiplatform is the primary platform, not Android-only Jetpack Compose
- **No Flutter/Web**: Focused entirely on the Compose ecosystem
- **Platform adaptation guide**: Component-by-component analysis of M3 on iOS
- **Dynamic color patterns**: expect/actual patterns with fallback strategies
- **System integration**: Insets, fonts (including CMP Font() gotcha), status bar — the cross-platform gotchas
- **Component architecture**: MVI/MVVM wiring for Snackbar, BottomSheet, Dialog + NavigationSuiteScaffold
- **CMP dependency tracking**: Correct coordinates, feature parity, version mapping
- **Color pairing guide**: Do/Don't for M3 color role usage with accessibility guardrails
- **M2→M3 migration**: Component mapping reference for projects upgrading
- **Enhanced audit**: 12 categories with CMP-specific checks (up from 10)

## Credits

Original skill by [hamen](https://github.com/hamen). This fork extends it for the Compose Multiplatform community.
```

---

## 9. Implementation Order

1. Fork `hamen/material-3-skill`, rename to `cmp-material3-skill`
2. Clean upstream files: remove all Flutter and Web content
3. Enhance upstream references: color pairing Do/Don't, NavigationSuiteScaffold, accessibility notes on components
4. Modify `SKILL.md`: platform hierarchy, CMP routing, inline notes
5. Write `cmp-dependencies.md` (unblocks everything else — coordinates are foundational)
6. Write `cmp-dynamic-color.md` (highest-impact CMP gap)
7. Write `cmp-system-integration.md` (second most common pain point — includes Font() gotcha)
8. Write `cmp-component-architecture.md` (MVI/MVVM wiring, NavigationSuiteScaffold, M2→M3 migration)
9. Write `cmp-platform-adaptation.md` (most research-heavy, benefits from the others being done)
10. Update audit framework with CMP checks (12 categories)
11. Write README
12. Validate with `validate.sh` if present

---

## 10. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Upstream divergence makes merges painful | Keep upstream file changes minimal; all CMP depth goes in new files |
| CMP APIs change across versions | Add version notes in `cmp-dependencies.md`, review on each CMP release |
| Scope creep into general Compose patterns | Stay strictly within M3 scope — architecture, state, navigation belong to other skills |
| Incomplete feature parity data | Mark uncertain items explicitly, link to JetBrains changelog, invite community PRs |
| iOS friction analysis becomes opinionated | State the skill's position clearly (M3 pure) and document alternatives without prescribing |

---

## 11. Success Criteria

- A CMP developer can install the skill and get correct M3 guidance without hitting Android-only gotchas
- Dynamic color works cross-platform on first try following the skill's patterns
- Dependency setup is copy-paste correct for CMP projects
- Upstream merges are achievable with reasonable effort (< 30 min per merge)
- The audit catches CMP-specific M3 violations that the original skill misses

---

## 12. Sources and Attribution

| Content | Source | Notes |
|---|---|---|
| Base M3 skill (SKILL.md, all upstream references) | [hamen/material-3-skill](https://github.com/hamen/material-3-skill) | MIT license, credit preserved |
| MVI/MVVM wiring for M3 components | [compose-skill](https://github.com/AdrianCraft/compose-skill) (material-design.md) | Snackbar, BottomSheet, Dialog patterns |
| Interface vs expect/actual decision framework | compose-skill (cross-platform.md) | Bridge pattern selection guide |
| Font() composable gotcha in CMP | compose-skill (resources.md) | Typography construction pattern |
| Color role pairing Do/Don't | compose-skill (material-design.md) | Accessibility guardrails |
| NavigationSuiteScaffold | compose-skill (material-design.md) | Adaptive navigation component |
| M2→M3 migration table | compose-skill (material-design.md) | Component mapping reference |
| Accessibility semantics and touch targets | compose-skill (accessibility.md) | contentDescription, 48dp min, WCAG |
| Haptics as semantic effects | compose-skill (cross-platform.md) | Platform capability pattern |
