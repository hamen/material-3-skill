# MD3 Component Catalog

Complete reference for Material Design 3 components. **Primary:** Compose Multiplatform / Jetpack Compose (`androidx.compose.material3`).

## Actions

### Buttons

MD3 has 5 button types ordered by emphasis: Filled > Filled Tonal > Elevated > Outlined > Text.

#### Filled Button
**Use when**: Primary action, highest emphasis.

#### Filled Tonal Button
**Use when**: Medium emphasis, softer than filled. Secondary actions alongside a filled button.

#### Elevated Button
**Use when**: Medium emphasis with shadow. Use on colored backgrounds where tonal button blends in.

#### Outlined Button
**Use when**: Medium emphasis, neutral. Good for secondary actions.

#### Text Button
**Use when**: Lowest emphasis. Inline actions, dialog actions, less important options.

#### Button Sizes (Expressive)
Buttons now support 5 sizes: extra-small, small (default), medium, large, extra-large.

**A11y**: Buttons have built-in button role. Use `aria-label` when using icon-only buttons. Minimum touch target 48x48dp.

### Button Group
**Use when**: Grouping related actions together with connected visual treatment.

### FAB (Floating Action Button)
**Use when**: The single most important action on a screen.

| Property | Values |
|----------|--------|
| Size | `small`, `medium` (default), `large` |
| Variant | `surface`, `primary`, `secondary`, `tertiary` |

**A11y**: Always provide a content description since FABs are icon-only.

### Extended FAB
**Use when**: Primary action with explanatory text.

### Icon Button

4 variants: Standard, Filled, Filled Tonal, Outlined.

Icon buttons support **toggle** behavior with selected/unselected states.

**A11y**: Always provide a content description. Toggle buttons should have descriptive labels for both states.

### Segmented Buttons
Groups of related toggle options. Supports single-select and multi-select modes.

## Communication

### Badge
Two variants:
- **Small**: Dot indicator only (no text)
- **Large**: Contains a count or short text

### Progress Indicator
Two types: **Linear** and **Circular**.

Each can be **determinate** (shows specific progress 0–1) or **indeterminate** (shows ongoing activity). A four-color indeterminate variant is also available.

**A11y**: Has built-in `progressbar` role. Add a content description for context (e.g., "Loading messages").

### Snackbar
Brief messages at the bottom of the screen with an optional action and dismiss button.

- Uses `inverse-surface` / `inverse-on-surface` color roles
- Shape: `extra-small`
- Max width: 560dp
- Min height: 48dp

### Tooltip
Two types:
- **Plain**: Short text label, appears on hover/focus. Use for icon buttons and truncated text.
- **Rich**: Multi-line with optional actions. Use for complex explanations.

## Containment

### Card
Three variants:

| Variant | Appearance | Elevation |
|---------|-----------|-----------|
| Filled | Surface-container-highest fill, no border | Level 0 |
| Outlined | Surface fill, outline-variant border | Level 0 |
| Elevated | Surface-container-low fill, shadow | Level 1 |

### Dialog
Displays a modal prompt for user decisions or information.

**A11y**: Dialog traps focus automatically. Provide an accessible headline.

### Bottom Sheet
Two variants: Standard (persistent, coexists with content) and Modal (blocks interaction, has scrim).

### Side Sheet
Two variants: Standard (docked alongside content) and Modal (overlays content with scrim).

### Divider
Thin line separating content. Two modes:
- **Full-width**: Spans the entire container
- **Inset**: Adds padding on start, end, or both sides

### Carousel
Three configurations:
- **Multi-browse**: Multiple items visible, scrollable
- **Uncontained**: Items extend beyond viewport edges
- **Hero**: One large featured item with smaller previews

## Input

### Checkbox
Supports three states: unchecked, checked, and indeterminate.

**A11y**: Associate with a label or use a content description. Checkbox has built-in checkbox role.

### Chips
Four variants:

| Variant | Use |
|---------|-----|
| Assist | Smart suggestions, shortcuts |
| Filter | Filtering content, multi-select |
| Input | User input tokens (email recipients) |
| Suggestion | Suggested responses, queries |

### Menu
Displays a list of actions or options anchored to a trigger element. Supports sub-menus via nested menu items.

### Radio Button
Single-select from a set of options. Group radios together for exclusive selection.

**A11y**: Group radios in a container with a group role and label.

### Slider
Three modes:
- **Continuous**: Smooth value selection across a range
- **Discrete**: Snaps to defined step increments, optionally shows value label
- **Range**: Two thumbs for selecting a value range

### Switch
Binary toggle control with on/off states. Optionally displays on/off icons on the thumb.

### Text Field
Two variants: **Filled** and **Outlined** (outlined recommended for most uses).

Supports: label, placeholder, supporting text, error state with error text, prefix/suffix text, leading/trailing icons, character counter, and textarea mode.

#### Jetpack Compose

Use **`OutlinedTextField`** / **`TextField`** from **`androidx.compose.material3`**. Prefer **state-based** APIs (`TextFieldState`, `rememberTextFieldState()`) when targeting current Material3 releases — see the [package overview](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary). Map labels, supporting text, and error state to MD3 roles (`MaterialTheme.colorScheme`, `TextFieldDefaults`).

```kotlin
// Illustrative — API names vary slightly by Material3 version
val state = rememberTextFieldState("")

OutlinedTextField(
    state = state,
    label = { Text("Email") },
    supportingText = { if (isError) Text("Invalid email") },
    isError = isError,
    modifier = Modifier.fillMaxWidth()
)
```

### Date Picker
Three configurations:
- **Docked**: Inline calendar attached to input
- **Modal**: Full dialog for date selection
- **Range**: Select a date range

### Time Picker
Two configurations:
- **Docked**: Inline time input
- **Modal**: Clock dial in dialog

## Navigation

### App Bar (Top)
Four variants:

| Variant | Height | Title position | Scroll behavior |
|---------|--------|---------------|----------------|
| Center-aligned | 64dp | Center | Elevate on scroll |
| Small | 64dp | Left | Elevate on scroll |
| Medium | 112dp | Left, bottom | Collapse to small on scroll |
| Large | 152dp | Left, bottom | Collapse to small on scroll |

**Jetpack Compose:** `TopAppBar`, `CenterAlignedTopAppBar`, `MediumTopAppBar`, `LargeTopAppBar`, and expressive variants (e.g. large flexible) may require **`@OptIn(ExperimentalMaterial3ExpressiveApi::class)`** depending on BOM — check your `material3` version.

### Navigation Bar
**Use when**: 3–5 primary destinations, mobile/compact screens, persistent.

### Navigation Drawer
**Use when**: Many destinations, larger screens, can be modal or persistent.

### Navigation Rail
**Use when**: 3–7 destinations, medium screens (600–839dp), persistent side navigation.

### Search
Two patterns:
- **Search bar**: Persistent search field in top app bar area
- **Search view**: Expandable search overlay with suggestions

### Tabs
Two variants:
- **Primary**: Top-level content switching (Flights / Hotels / Explore)
- **Secondary**: Sub-sections within primary tabs

**A11y**: Tab set has built-in tablist role. Connect tabs to panels with `aria-controls`.

### Toolbar
Displays frequently used actions relevant to current page context. Typically placed below top app bar or in contextual positions.

## Data Display

### List
Three density levels: one-line, two-line, and three-line items.

**Slots**: `start` (leading element), `end` (trailing element), `headline` (primary text), `supporting-text` (secondary text), `trailing-supporting-text` (trailing metadata), `overline` (above headline).

## Accessibility Integration

M3 components provide built-in accessibility support, but developers must complete the picture:

### Required Content Descriptions

| Component | Requirement |
|---|---|
| `IconButton` | Always provide `contentDescription` — icon-only buttons need spoken labels |
| `FloatingActionButton` | Always provide `contentDescription` for the FAB's purpose |
| `Image` | Use `contentDescription` for meaningful images; `null` for decorative |
| `Icon` (standalone) | `contentDescription` if meaningful; `null` if decorative or already labeled by parent |
| `Switch` / `Checkbox` | Wrap in `Row` with `Text` label, or use `Modifier.semantics { contentDescription = ... }` |
| `Slider` | Add `Modifier.semantics { contentDescription = "Volume: ${value.toInt()}%" }` |

### Semantic Roles

M3 composables set correct roles automatically — `Button` has `Role.Button`, `Checkbox` has `Role.Checkbox`, etc. You only need manual `Modifier.semantics { role = ... }` when building custom components that mimic M3 behavior.

### Touch Target Compliance

All interactive components must have a minimum touch target of **48x48dp**. M3 composables enforce this by default via internal padding. If you override sizes or padding, verify compliance:

```kotlin
// M3 components handle this automatically. But if you customize:
IconButton(
    onClick = { /* ... */ },
    modifier = Modifier.size(48.dp) // Minimum touch target
) {
    Icon(Icons.Default.Close, contentDescription = "Close")
}
```

### Color as Status Indicator

**Never use color alone** to convey state. Always pair with icon, text, or shape:

```kotlin
// Do — color + icon
Icon(
    imageVector = if (isError) Icons.Default.Error else Icons.Default.CheckCircle,
    contentDescription = if (isError) "Error" else "Success",
    tint = if (isError) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary,
)

// Don't — color only, no icon or text
Box(
    modifier = Modifier
        .size(12.dp)
        .background(if (isError) Color.Red else Color.Green) // Inaccessible
)
```

### CMP Note

On Android, TalkBack provides accessibility services. On iOS, VoiceOver serves the same role but with different interaction patterns (e.g., swipe gestures to navigate between elements). CMP renders its own semantics tree — verify both TalkBack and VoiceOver behavior when targeting multiple platforms.
