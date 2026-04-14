# MD3 Navigation Patterns

Guide for choosing and implementing Material Design 3 navigation components.

## Jetpack Compose (primary)

Use **`androidx.compose.material3`**: `NavigationBar`, `NavigationRail`, `NavigationDrawerItem`, `ModalNavigationDrawer`, `DismissibleNavigationDrawer`, `PermanentNavigationDrawer`, `NavigationBarItem`, `NavigationRailItem`, top app bars (`TopAppBar`, `CenterAlignedTopAppBar`, `LargeTopAppBar`, expressive variants per BOM), and **`Scaffold`** (`bottomBar`, `floatingActionButton`, `snackbarHost`).

Wire destinations with **Navigation Compose** (`NavHost`, `composable`, `rememberNavController`). For **adaptive** UIs, use **`calculateWindowSizeClass`**, **`androidx.compose.material3.adaptive`**, or **`currentWindowAdaptiveInfo`** / **`NavigableListDetailPaneScaffold`** (names and packages depend on your BOM — check [Android Developers](https://developer.android.com/jetpack/androidx/releases/compose-material3)).

```kotlin
// Conceptual — adapt routes and selection to your app
Scaffold(
    bottomBar = {
        NavigationBar {
            destinations.forEach { dest ->
                NavigationBarItem(
                    selected = currentRoute == dest.route,
                    onClick = { navController.navigate(dest.route) },
                    icon = { Icon(dest.icon, contentDescription = dest.label) },
                    label = { Text(dest.label) }
                )
            }
        }
    }
) { innerPadding ->
    NavHost(
        navController = navController,
        startDestination = "home",
        modifier = Modifier.padding(innerPadding)
    ) { /* composable routes */ }
}
```

---

## Navigation Component Selection

### Decision Tree

```
How many primary destinations?
├── 2 destinations → Tabs (primary)
├── 3–5 destinations
│   ├── Compact screen (<600dp) → Navigation Bar (bottom)
│   ├── Medium screen (600–839dp) → Navigation Rail (side)
│   └── Expanded+ screen (840dp+) → Navigation Drawer (side) or Rail
├── 6+ destinations
│   ├── Compact → Navigation Drawer (modal)
│   ├── Medium → Navigation Drawer (standard) or Rail + overflow menu
│   └── Expanded+ → Navigation Drawer (standard)
└── Hierarchical (nested sections)
    └── Navigation Drawer with sections
```

### Quick Reference

| Component | Destinations | Screen Size | Persistence | Position |
|-----------|-------------|-------------|-------------|----------|
| Navigation Bar | 3–5 | Compact | Persistent | Bottom |
| Navigation Rail | 3–7 | Medium | Persistent | Side (start) |
| Navigation Drawer | Unlimited | Expanded+ | Standard or Modal | Side (start) |
| Tabs | 2+ related views | Any | Persistent | Top (below app bar) |
| Bottom App Bar | — (contextual actions) | Compact | Persistent | Bottom |

## Navigation Bar

**Use when**: 3–5 primary destinations on compact (mobile) screens.
**Position**: Bottom of screen, always visible.

### Anatomy
- Fixed at bottom, full width
- 3–5 navigation items with icon + label
- Active item shows filled icon + indicator pill
- Height: 80dp

### Guidelines
- Always show labels (don't use icon-only)
- Use filled icons for active state, outlined for inactive
- Don't use for fewer than 3 or more than 5 destinations
- Hide on scroll down in content-heavy screens (optional)
- Elevation level 2 (3dp)

## Navigation Rail

**Use when**: 3–7 primary destinations on medium screens (tablets).
**Position**: Start edge (left in LTR), always visible.

### Anatomy
- Width: 80dp
- Optional FAB at top
- Navigation items vertically stacked
- Active item shows indicator pill

### Guidelines
- Align items to top (below optional FAB)
- Show labels always (optional to hide, but recommended to show)
- FAB at top is optional but common
- Elevation level 0

## Navigation Drawer

**Use when**: Many destinations, expanded screens, or deep hierarchies.
**Position**: Start edge, standard (persistent) or modal (overlay).

### Standard Drawer (Persistent)

Always visible alongside content. Width: 360dp.

### Modal Drawer (Overlay)

Overlays content with a scrim. Used on smaller screens or when content space is limited.

### Guidelines
- Standard drawer uses `surface-container` background
- Modal drawer has elevation level 1 and scrim overlay
- Group destinations with dividers and section headers
- Active item uses `secondary-container` background
- Shape: `large` on end corners (right edge in LTR)

## Top App Bar

**Use when**: Every screen needs a title and optional actions.

### Variants

| Variant | Title | Height | Scroll Behavior |
|---------|-------|--------|----------------|
| Center-aligned | Center | 64dp | Elevates to level 2 on scroll |
| Small | Start-aligned | 64dp | Elevates to level 2 on scroll |
| Medium | Bottom, start-aligned | 112dp | Collapses to 64dp on scroll |
| Large | Bottom, start-aligned | 152dp | Collapses to 64dp on scroll |

## Tabs

**Use when**: Switching between related content at the same hierarchy level.

### Primary vs Secondary

- **Primary tabs**: Top-level content switching (Flights / Hotels / Explore)
- **Secondary tabs**: Sub-sections within primary content

## Responsive Navigation Pattern

The key MD3 pattern: navigation component transforms across breakpoints.

### Mobile → Tablet → Desktop

```
Compact (<600dp):   Navigation Bar (bottom)
Medium (600–839dp): Navigation Rail (side)
Expanded (840dp+):  Navigation Drawer (side, standard)
```

## NavigationSuiteScaffold

**Recommended default** for apps with 3-5 destinations. Auto-switches between `NavigationBar` (compact), `NavigationRail` (medium), and `NavigationDrawer` (expanded) based on window size class.

```kotlin
// API-version-sensitive: requires material3-adaptive-navigation-suite artifact
// Verify CMP availability — check JetBrains Compose release notes
NavigationSuiteScaffold(
    navigationSuiteItems = {
        destinations.forEach { dest ->
            item(
                selected = currentDest == dest,
                onClick = { currentDest = dest },
                icon = { Icon(dest.icon, contentDescription = null) },
                label = { Text(dest.label) },
            )
        }
    }
) {
    DestinationContent(currentDest)
}
```

**CMP availability:** `NavigationSuiteScaffold` lives in `material3-adaptive-navigation-suite`. Check your CMP version for availability. If not available, use manual window-size-class branching as described in the Jetpack Compose section above.

This replaces manual breakpoint branching:
```
Compact (<600dp):   NavigationBar (bottom)      ┐
Medium (600–839dp): NavigationRail (side)        ├─ All handled automatically
Expanded (840dp+):  NavigationDrawer (side)      ┘
```

Full wiring details: `references/cmp-component-architecture.md`
