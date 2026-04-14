# MD3 Layout and Responsive Design

Reference for Material Design 3's layout system: breakpoints, canonical layouts, and responsive implementation.

## Jetpack Compose and Android

The **breakpoint table** below is a **design** reference. In **Jetpack Compose**, prefer **`calculateWindowSizeClass`** (`androidx.compose.material3:material3-window-size-class`) and/or **`androidx.compose.material3.adaptive`** APIs (e.g. `currentWindowAdaptiveInfo`, list-detail scaffolds) instead of hand-rolling raw `BoxWithConstraints` width checks everywhere.

**Edge-to-edge:** Use **`enableEdgeToEdge()`** on your `Activity` (AndroidX) when you draw behind the system bars. Apply **`WindowInsets`** (`Modifier.statusBarsPadding()`, `navigationBarsPadding()`, **`imePadding()`**, `displayCutoutPadding()`, etc.) and **`Scaffold`** `contentWindowInsets` so content and **IME** behave correctly.

**Foldables:** Use **`WindowInfoTracker`**, **`FoldingFeature`**, or Jetpack WindowManager APIs — see the foldable section below; verify APIs against your dependency versions.

---

## Window Size Classes

MD3 defines 5 breakpoint classes:

| Class | Width Range | Typical Devices | Columns |
|-------|-----------|----------------|---------|
| Compact | < 600dp | Phone portrait | 4 |
| Medium | 600–839dp | Tablet portrait, foldable | 8 |
| Expanded | 840–1199dp | Tablet landscape, small desktop | 12 |
| Large | 1200–1599dp | Desktop | 12 |
| Extra-large | 1600dp+ | Ultra-wide, large desktop | 12 |

## Layout Anatomy

### Key Terms

- **Window**: The visible area of the app
- **Pane**: A layout container within the window. A pane is fixed, flexible, floating, or semi-permanent
- **Column**: A vertical content block within a pane
- **Margin**: Space between screen edge and content
- **Gutter**: Space between columns
- **Spacer**: Space between panes (in multi-pane layouts)

### Margin and Gutter Values

| Window Size | Margins | Gutters |
|-------------|---------|---------|
| Compact | 16dp | 8dp |
| Medium | 24dp | 16dp |
| Expanded | 24dp | 16dp |
| Large | 24dp | 24dp |
| Extra-large | 24dp | 24dp |

## Canonical Layouts

MD3 defines 3 canonical layouts as starting points. Always begin from one of these rather than from a raw grid.

### Feed Layout

**Use when**: Displaying a large collection of browsable items (social feed, news, product grid).

```
Compact:    Single column of cards
Medium:     2-column grid
Expanded:   3-column grid
Large:      4-column grid + optional side panel
```

### List-Detail Layout

**Use when**: Browsing a list of items where each has detailed content (email, file browser, contacts).

```
Compact:    List view OR detail view (navigate between them)
Medium:     Side-by-side list (1/3) + detail (2/3)
Expanded:   Side-by-side with wider detail pane
```

### Drag Handle for Resizable Panes

In list-detail and supporting pane layouts, users can resize panes with a drag handle.

### Supporting Pane Layout

**Use when**: Primary content needs supplementary information (document + properties panel, video + comments).

```
Compact:    Stacked — primary on top, supporting below (or bottom sheet)
Medium:     Side-by-side (2/3 primary + 1/3 supporting)
Expanded:   Same but with more space
```

## Adaptive Component Behavior

Components transform across breakpoints:

| Component | Compact | Medium (incl. foldable unfolded) | Expanded+ / Large screen |
|-----------|---------|--------|-----------|
| Navigation | Bottom bar | Side rail | Side drawer |
| App bar | Small (64dp) | Small (64dp) | Small or Medium (112dp) |
| Dialog | Full-screen | Centered dialog | Centered dialog (max 560dp wide) |
| Bottom sheet | Full height | Partial height | Side sheet |
| Search | Full-screen search view | Persistent search bar | Persistent search bar |
| Cards | Full-width single column | Multi-column grid | Multi-column grid (max 4 cols) |
| Content panes | Single pane | Optional second pane | Two or three panes |
| Input method | Touch only | Touch + stylus | Touch + mouse/trackpad + keyboard |

## Foldables and Large Screens

MD3 provides specific guidance for foldable devices, tablets, and large-screen form factors. These are first-class targets in Material Design 3 — not afterthoughts.

### Foldable Postures

Foldable devices introduce postures that don't exist on traditional phones:

| Posture | Description | Layout behavior |
|---------|-------------|----------------|
| **Flat (unfolded)** | Device fully open, single large screen | Treat as Medium or Expanded window class based on width |
| **Half-opened (tabletop)** | Folded ~90° horizontally, bottom half on table | Split content at the hinge — video/image on top half, controls/info on bottom half |
| **Half-opened (book)** | Folded ~90° vertically, held like a book | Split content at the hinge — list on one side, detail on the other |
| **Folded** | Device closed, outer/cover screen | Treat as Compact — show essential content only |

### Hinge-Aware Layouts

The fold/hinge is a physical divider. Never place interactive content or critical information across the hinge area.

**Jetpack Compose — `WindowInfoTracker` and `FoldingFeature`:**

```kotlin
@Composable
fun AdaptiveLayout() {
    val windowInfo = WindowInfoTracker.getOrCreate(LocalContext.current)
        .windowLayoutInfo(LocalContext.current as Activity)
        .collectAsState(initial = WindowLayoutInfo(emptyList()))

    val foldingFeature = windowInfo.value.displayFeatures
        .filterIsInstance<FoldingFeature>()
        .firstOrNull()

    when {
        foldingFeature != null && foldingFeature.state == FoldingFeature.State.HALF_OPENED -> {
            // Tabletop or book posture
            if (foldingFeature.orientation == FoldingFeature.Orientation.HORIZONTAL) {
                TabletopLayout(foldingFeature)  // top: content, bottom: controls
            } else {
                BookLayout(foldingFeature)  // left: list, right: detail
            }
        }
        else -> {
            // Standard adaptive layout based on window size class
            val windowSizeClass = calculateWindowSizeClass(LocalContext.current as Activity)
            StandardAdaptiveLayout(windowSizeClass)
        }
    }
}
```

### Tabletop Posture Pattern

When the device is in tabletop posture (horizontal fold, bottom half resting on a surface), the content naturally divides into two halves:

```
┌─────────────────────┐
│                     │  ← Top half: visual content
│   Video / Image /   │     (camera viewfinder, video player,
│   Primary content   │      image gallery, map)
│                     │
├─ ─ ─ hinge ─ ─ ─ ─ ┤
│                     │  ← Bottom half: controls & info
│  Controls / Text /  │     (playback controls, chat input,
│  Supporting info    │      product details, toolbar)
│                     │
└─────────────────────┘
```

### Book Posture Pattern

When the device is in book posture (vertical fold, held like a book), it naturally maps to list-detail:

```
┌──────────┬──────────┐
│          │          │
│  List /  │  Detail  │
│  Nav /   │  Content │
│  Browse  │  / Edit  │
│          │          │
└──────────┴──────────┘
         hinge
```

### Large Screen Layout Guidance

For tablets, Chromebooks, desktop, and large foldables (Expanded, Large, Extra-large):

**Content width constraints:**
- Don't stretch content to fill ultra-wide screens — reading lines longer than ~80 characters become hard to scan
- Constrain body content to a max width (typically 840–1040dp) and center it
- Use the extra space for multi-pane layouts, not wider single columns

**Multi-pane strategies by window class:**

| Window class | Columns | Recommended layout |
|-------------|---------|-------------------|
| Compact (<600dp) | 4 | Single pane. Full-screen navigation between views. |
| Medium (600–839dp) | 8 | Optional second pane. List-detail with narrow list. Rail navigation. |
| Expanded (840–1199dp) | 12 | Two panes standard. List-detail or supporting pane. Drawer navigation. |
| Large (1200–1599dp) | 12 | Two or three panes. Feed with side panel. Persistent supporting pane. |
| Extra-large (1600dp+) | 12 | Three panes or constrained two-pane with generous margins. |

**Input and interaction differences:**
- Large screens often have mouse/trackpad input — hover states and right-click menus matter
- Touch targets remain 48dp minimum but can be supplemented with hover tooltips
- Keyboard shortcuts become expected on desktop-class devices
- Drag-and-drop is more natural on large screens

### Foldable-Aware Canonical Layouts

The three canonical layouts adapt naturally to foldables:

| Layout | Foldable behavior |
|--------|------------------|
| **Feed** | Unfolded: multi-column grid fills both halves. Tabletop: grid on top, selected item preview on bottom. |
| **List-detail** | Book posture: list on left half, detail on right half — a perfect natural fit. Tabletop: list on top, detail on bottom. |
| **Supporting pane** | Book posture: primary on left, supporting on right. Tabletop: primary on top, supporting controls on bottom. |

### Testing Large Screens and Foldables

**Compose:**
- Use Android Studio foldable emulators (Pixel Fold, 7.6" Foldable)
- Test posture changes: flat → half-opened → folded
- Use `WindowInfoTracker` to verify fold-aware layout switching

### Audit Checklist for Foldable/Large Screen Support

When auditing, check these specific items:

- [ ] App uses `calculateWindowSizeClass` or equivalent to determine window size class
- [ ] Layout switches from single-pane to multi-pane at 600dp
- [ ] Navigation transforms: bottom bar → rail → drawer across breakpoints
- [ ] Content has max-width constraint on large screens (not stretching to fill)
- [ ] No critical content or interactive elements placed across a fold/hinge
- [ ] Foldable postures handled (if targeting foldable devices): tabletop and book modes
- [ ] Hover states exist for pointer devices
- [ ] Touch targets remain 48dp minimum even on large screens
- [ ] Dialogs are centered (not full-screen) on medium+ screens
- [ ] Bottom sheets convert to side sheets on expanded+ screens

## Spacing System

MD3 uses a 4dp base grid for spacing:

| Use | Values |
|-----|--------|
| Component internal padding | 4, 8, 12, 16, 24dp |
| Between components | 8, 12, 16, 24dp |
| Section spacing | 24, 32, 48dp |
| Layout margins | 16dp (compact), 24dp (medium+) |
| Grid gutters | 8dp (compact), 16dp (medium), 24dp (large+) |

Always use multiples of 4dp for consistent spatial rhythm.
