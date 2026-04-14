# MD3 Color System

Complete reference for Material Design 3's color system: roles, tonal palettes, dynamic color, and scheme generation.

## Color Roles

MD3 defines 29+ color roles organized into groups. In **Jetpack Compose**, these map to `MaterialTheme.colorScheme` properties (e.g. `MaterialTheme.colorScheme.primary`, `.onPrimary`). The spec uses `md.sys.color.*` token names.

### Accent Colors

Three accent groups (primary, secondary, tertiary) each have 4 roles:

| Role | Token | Purpose |
|------|-------|---------|
| Primary | `--md-sys-color-primary` | High-emphasis fills, text, icons against surface |
| On Primary | `--md-sys-color-on-primary` | Text and icons on primary |
| Primary Container | `--md-sys-color-primary-container` | Standout fill for key components (FAB, etc.) |
| On Primary Container | `--md-sys-color-on-primary-container` | Text and icons on primary-container |
| Secondary | `--md-sys-color-secondary` | Less prominent fills, text, icons |
| On Secondary | `--md-sys-color-on-secondary` | Text and icons on secondary |
| Secondary Container | `--md-sys-color-secondary-container` | Recessive components (tonal buttons) |
| On Secondary Container | `--md-sys-color-on-secondary-container` | Text and icons on secondary-container |
| Tertiary | `--md-sys-color-tertiary` | Complementary fills, text, icons |
| On Tertiary | `--md-sys-color-on-tertiary` | Text and icons on tertiary |
| Tertiary Container | `--md-sys-color-tertiary-container` | Complementary container fill |
| On Tertiary Container | `--md-sys-color-on-tertiary-container` | Text and icons on tertiary-container |

**Usage guidance:**
- **Primary**: Most prominent components — FABs, high-emphasis buttons, active states
- **Secondary**: Less prominent components — filter chips, tonal buttons, selection states
- **Tertiary**: Contrasting accents that balance primary/secondary — input fields, badges

### Error Colors

Static colors that don't change with dynamic color schemes:

| Role | Token | Purpose |
|------|-------|---------|
| Error | `--md-sys-color-error` | Attention-grabbing color for urgent elements |
| On Error | `--md-sys-color-on-error` | Text and icons on error |
| Error Container | `--md-sys-color-error-container` | Error container fill |
| On Error Container | `--md-sys-color-on-error-container` | Text and icons on error-container |

### Surface Colors

| Role | Token | Purpose |
|------|-------|---------|
| Surface | `--md-sys-color-surface` | Default background color |
| On Surface | `--md-sys-color-on-surface` | Text and icons on any surface |
| On Surface Variant | `--md-sys-color-on-surface-variant` | Lower-emphasis text/icons on surface |
| Surface Container Lowest | `--md-sys-color-surface-container-lowest` | Lowest-emphasis container |
| Surface Container Low | `--md-sys-color-surface-container-low` | Low-emphasis container |
| Surface Container | `--md-sys-color-surface-container` | Default container (navigation areas) |
| Surface Container High | `--md-sys-color-surface-container-high` | High-emphasis container |
| Surface Container Highest | `--md-sys-color-surface-container-highest` | Highest-emphasis container |
| Surface Dim | `--md-sys-color-surface-dim` | Dimmest surface in both themes |
| Surface Bright | `--md-sys-color-surface-bright` | Brightest surface in both themes |

**Surface container hierarchy**: Use `surface` for background, `surface-container` for navigation. The 5 container levels create visual hierarchy and nesting depth, especially useful for expanded layouts with multiple panes.

**Surface dim/bright**: Unlike regular surface (which flips from light to dark), dim and bright maintain their relative brightness in both themes. Use bright for areas that should always be the lightest, dim for areas that should always be the dimmest.

### Inverse Colors

For elements that contrast against the surrounding UI (e.g., snackbars):

| Role | Token | Purpose |
|------|-------|---------|
| Inverse Surface | `--md-sys-color-inverse-surface` | Background for contrasting elements |
| Inverse On Surface | `--md-sys-color-inverse-on-surface` | Text on inverse-surface |
| Inverse Primary | `--md-sys-color-inverse-primary` | Actionable text on inverse-surface |

### Outline Colors

| Role | Token | Purpose |
|------|-------|---------|
| Outline | `--md-sys-color-outline` | Important boundaries (text field borders, 3:1 contrast) |
| Outline Variant | `--md-sys-color-outline-variant` | Decorative elements (dividers, card borders) |

**Important**: Don't use `outline` for dividers — use `outline-variant`. Don't use `outline-variant` for interactive boundaries that need 3:1 contrast — use `outline`.

### Fixed Accent Colors (Add-on)

These maintain the same color in both light and dark themes (unlike regular container colors which change tone):

| Role | Token |
|------|-------|
| Primary Fixed | `--md-sys-color-primary-fixed` |
| Primary Fixed Dim | `--md-sys-color-primary-fixed-dim` |
| On Primary Fixed | `--md-sys-color-on-primary-fixed` |
| On Primary Fixed Variant | `--md-sys-color-on-primary-fixed-variant` |
| Secondary Fixed | `--md-sys-color-secondary-fixed` |
| Secondary Fixed Dim | `--md-sys-color-secondary-fixed-dim` |
| On Secondary Fixed | `--md-sys-color-on-secondary-fixed` |
| On Secondary Fixed Variant | `--md-sys-color-on-secondary-fixed-variant` |
| Tertiary Fixed | `--md-sys-color-tertiary-fixed` |
| Tertiary Fixed Dim | `--md-sys-color-tertiary-fixed-dim` |
| On Tertiary Fixed | `--md-sys-color-on-tertiary-fixed` |
| On Tertiary Fixed Variant | `--md-sys-color-on-tertiary-fixed-variant` |

**Caution**: Fixed colors don't adapt to theme, so they may cause contrast issues. Use regular accent roles for elements where contrast is critical.

## Tonal Palette System

MD3 generates colors from a **seed color** through the tonal palette system:

### How It Works

1. A **seed color** (hex value) is chosen
2. The seed generates **5 tonal palettes**: Primary, Secondary, Tertiary, Neutral, Neutral-Variant
3. Each palette uses tonal stops along **0–100** (commonly 16 key stops: 0, 10, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 95, 98, 99, 100)
4. Color roles are mapped to specific tonal values depending on light or dark scheme

### Tonal Value Mapping (Light Scheme)

| Role | Tonal Palette | Tone |
|------|--------------|------|
| Primary | Primary | 40 |
| On Primary | Primary | 100 |
| Primary Container | Primary | 90 |
| On Primary Container | Primary | 10 |
| Surface | Neutral | 98 |
| On Surface | Neutral | 10 |
| Surface Container | Neutral | 94 |
| Surface Container Low | Neutral | 96 |
| Surface Container Lowest | Neutral | 100 |
| Surface Container High | Neutral | 92 |
| Surface Container Highest | Neutral | 90 |
| Outline | Neutral-Variant | 50 |
| Outline Variant | Neutral-Variant | 80 |

### Tonal Value Mapping (Dark Scheme)

| Role | Tonal Palette | Tone |
|------|--------------|------|
| Primary | Primary | 80 |
| On Primary | Primary | 20 |
| Primary Container | Primary | 30 |
| On Primary Container | Primary | 90 |
| Surface | Neutral | 6 |
| On Surface | Neutral | 90 |
| Surface Container | Neutral | 12 |
| Surface Container Low | Neutral | 10 |
| Surface Container Lowest | Neutral | 4 |
| Surface Container High | Neutral | 17 |
| Surface Container Highest | Neutral | 22 |
| Outline | Neutral-Variant | 60 |
| Outline Variant | Neutral-Variant | 30 |

## Color Pairing Rules

Colors must only be used in their intended pairs to ensure accessible contrast:

| Container/Fill | Text/Icon Color |
|---------------|----------------|
| `primary` | `on-primary` |
| `primary-container` | `on-primary-container` |
| `secondary` | `on-secondary` |
| `secondary-container` | `on-secondary-container` |
| `tertiary` | `on-tertiary` |
| `tertiary-container` | `on-tertiary-container` |
| `error` | `on-error` |
| `error-container` | `on-error-container` |
| `surface` | `on-surface` or `on-surface-variant` |
| `surface-container-*` | `on-surface` or `on-surface-variant` |
| `inverse-surface` | `inverse-on-surface` or `inverse-primary` |

**Never pair colors outside their intended pairs** — this breaks contrast guarantees, especially under dynamic color and high contrast modes.

### Compose Color Role Pairing

In Compose, the pairing rules map to `MaterialTheme.colorScheme` properties:

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

### Do / Don't

| Do | Don't |
|---|---|
| `containerColor = MaterialTheme.colorScheme.primary`, `contentColor = MaterialTheme.colorScheme.onPrimary` | `containerColor = MaterialTheme.colorScheme.primary`, `contentColor = MaterialTheme.colorScheme.tertiaryContainer` |
| Access colors via `MaterialTheme.colorScheme.*` | Hardcode hex colors: `Color(0xFF6750A4)` |
| Test both light and dark themes | Assume light-only usage |
| Use M3 tonal palettes — they guarantee 3:1+ contrast when paired correctly | Mix unrelated pairs across accent families |
| Use `contentColorFor(containerColor)` to get the correct `on*` color | Manually pick an `on*` color that doesn't match the container |

## Dynamic Color

Dynamic color creates personalized color schemes from external sources:

### User-Generated (Wallpaper)
The OS extracts a seed color from the user's wallpaper and generates a scheme. **Android:** `dynamicLightColorScheme` / `dynamicDarkColorScheme` on **Android 12+ (API 31+)**.

### Content-Based
A seed color is extracted from in-app content (album art, book cover, etc.) to create a contextual scheme.

## Color Harmonization

When integrating custom brand colors that don't come from the seed, use harmonization to blend them into the tonal system. This shifts the custom color's hue slightly toward the scheme's primary, making it feel cohesive without losing its identity.

## User-Controlled Contrast (May 2025)

MD3 now supports 3 contrast levels:
- **Standard** (0.0): Default contrast
- **Medium** (0.5): Increased tonal distance between roles
- **High** (1.0): Maximum tonal distance for vision accessibility

The contrast parameter adjusts the tonal distance between paired roles, increasing legibility without changing the overall color feel.

## Baseline Color Scheme (Default Values)

The static baseline scheme for products not using dynamic color:

### Light Theme

| Token | Value |
|-------|-------|
| primary | #6750A4 |
| on-primary | #FFFFFF |
| primary-container | #EADDFF |
| on-primary-container | #21005D |
| secondary | #625B71 |
| on-secondary | #FFFFFF |
| secondary-container | #E8DEF8 |
| on-secondary-container | #1D192B |
| tertiary | #7D5260 |
| on-tertiary | #FFFFFF |
| tertiary-container | #FFD8E4 |
| on-tertiary-container | #31111D |
| error | #B3261E |
| on-error | #FFFFFF |
| error-container | #F9DEDC |
| on-error-container | #410E0B |
| surface | #FEF7FF |
| on-surface | #1D1B20 |
| on-surface-variant | #49454F |
| surface-container-lowest | #FFFFFF |
| surface-container-low | #F7F2FA |
| surface-container | #F3EDF7 |
| surface-container-high | #ECE6F0 |
| surface-container-highest | #E6E0E9 |
| surface-dim | #DED8E1 |
| surface-bright | #FEF7FF |
| outline | #79747E |
| outline-variant | #CAC4D0 |
| inverse-surface | #322F35 |
| inverse-on-surface | #F5EFF7 |
| inverse-primary | #D0BCFF |

### Dark Theme

| Token | Value |
|-------|-------|
| primary | #D0BCFF |
| on-primary | #381E72 |
| primary-container | #4F378B |
| on-primary-container | #EADDFF |
| secondary | #CCC2DC |
| on-secondary | #332D41 |
| secondary-container | #4A4458 |
| on-secondary-container | #E8DEF8 |
| tertiary | #EFB8C8 |
| on-tertiary | #492532 |
| tertiary-container | #633B48 |
| on-tertiary-container | #FFD8E4 |
| error | #F2B8B5 |
| on-error | #601410 |
| error-container | #8C1D18 |
| on-error-container | #F9DEDC |
| surface | #141218 |
| on-surface | #E6E0E9 |
| on-surface-variant | #CAC4D0 |
| surface-container-lowest | #0F0D13 |
| surface-container-low | #1D1B20 |
| surface-container | #211F26 |
| surface-container-high | #2B2930 |
| surface-container-highest | #36343B |
| surface-dim | #141218 |
| surface-bright | #3B383E |
| outline | #938F99 |
| outline-variant | #49454F |
| inverse-surface | #E6E0E9 |
| inverse-on-surface | #322F35 |
| inverse-primary | #6750A4 |
