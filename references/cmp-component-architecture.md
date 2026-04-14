# CMP Component Architecture & Wiring Patterns

> Compose Multiplatform reference for wiring Material 3 components to ViewModels,
> managing state vs effects, and migrating from M2.

---

## Why This Matters

The upstream Material 3 skill covers visual tokens, color systems, and component
catalogs but stops short of how components connect to application architecture.
Compose Multiplatform introduces additional considerations that pure Android
Compose does not face:

- **No `Activity` recreation** on desktop/iOS — configuration-change replay bugs
  manifest differently (or not at all), yet the code must still be correct for
  Android targets where they do occur.
- **ViewModel availability varies** — `androidx.lifecycle:lifecycle-viewmodel-compose`
  works on all KMP targets since lifecycle 2.8, but older projects may use
  hand-rolled state holders.
- **Platform-specific UI physics** — bottom sheets on iOS expect rubber-band
  dismissal; snackbars have no system-level toast equivalent on desktop.

This file codifies the wiring patterns that keep M3 components correct across
every Compose Multiplatform target.

---

## Snackbar Wiring with ViewModel Effects

Snackbars are **fire-and-forget signals** — they must not replay on
recomposition or configuration change. Model them as effects, not state.

### ViewModel

```kotlin
class OrderViewModel : ViewModel() {

    sealed interface Effect {
        data class ShowSnackbar(val message: String) : Effect
    }

    private val _effects = Channel<Effect>(Channel.BUFFERED)
    val effects: Flow<Effect> = _effects.receiveAsFlow()

    fun placeOrder() {
        viewModelScope.launch {
            // ... repository call ...
            _effects.send(Effect.ShowSnackbar("Order placed"))
        }
    }
}
```

### Route Composable

```kotlin
@Composable
fun OrderScreen(viewModel: OrderViewModel) {
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(Unit) {
        viewModel.effects.collect { effect ->
            when (effect) {
                is OrderViewModel.Effect.ShowSnackbar -> {
                    snackbarHostState.showSnackbar(effect.message)
                }
            }
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
    ) { innerPadding ->
        OrderContent(
            modifier = Modifier.padding(innerPadding),
            onPlaceOrder = viewModel::placeOrder,
        )
    }
}
```

### Anti-pattern: boolean state flag

```kotlin
// BAD -- replays snackbar on every recomposition / config change
data class UiState(val showSnackbar: Boolean = false)

// The composable sets showSnackbar = true, shows the snackbar, then must
// immediately send an event back to reset it. This round-trip is fragile,
// races with recomposition, and duplicates on Android config change.
```

Use `Channel<Effect>` (consumed once) instead of `StateFlow<Boolean>` for
transient signals.

---

## BottomSheet Wiring

### Programmatic Show (Effect-Driven)

When a ViewModel decides to show a sheet (e.g., after a network response),
route it through the same `Channel<Effect>` pattern.

```kotlin
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductScreen(viewModel: ProductViewModel) {
    val sheetState = rememberModalBottomSheetState()
    var showSheet by remember { mutableStateOf(false) }
    var selectedProduct by remember { mutableStateOf<Product?>(null) }

    LaunchedEffect(Unit) {
        viewModel.effects.collect { effect ->
            when (effect) {
                is ProductViewModel.Effect.ShowDetails -> {
                    selectedProduct = effect.product
                    showSheet = true
                }
            }
        }
    }

    if (showSheet) {
        ModalBottomSheet(
            onDismissRequest = { showSheet = false },
            sheetState = sheetState,
        ) {
            selectedProduct?.let { ProductDetailsContent(it) }
        }
    }

    // ... rest of scaffold
}
```

### User-Initiated Show (Local State)

When the user taps a button to open a sheet, local composable state is
sufficient — no ViewModel involvement needed.

```kotlin
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterSheet(onApply: (Filter) -> Unit) {
    var showSheet by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState()

    Button(onClick = { showSheet = true }) {
        Text("Filters")
    }

    if (showSheet) {
        ModalBottomSheet(
            onDismissRequest = { showSheet = false },
            sheetState = sheetState,
        ) {
            FilterContent(onApply = {
                onApply(it)
                showSheet = false
            })
        }
    }
}
```

> **CMP note:** iOS applies native rubber-band physics and edge-swipe
> dismissal to sheets. If you need to customize or suppress this behavior,
> see [cmp-platform-adaptation.md](cmp-platform-adaptation.md) for
> `expect`/`actual` strategies around sheet gesture handling.

---

## Dialog Wiring

Dialogs represent **decisions in progress** — the user is actively looking at
the dialog and must act on it. This makes them inherently stateful, not
effect-driven.

A `state.showDialog: Boolean` is acceptable and idiomatic for dialogs.

```kotlin
@Composable
fun DeleteConfirmationDialog(
    visible: Boolean,
    itemName: String,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
) {
    if (!visible) return

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Delete $itemName?") },
        text = { Text("This action cannot be undone.") },
        confirmButton = {
            TextButton(onClick = onConfirm) {
                Text("Delete")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
    )
}
```

The ViewModel exposes a boolean in its `UiState`:

```kotlin
data class UiState(
    val showDeleteDialog: Boolean = false,
    val itemToDelete: Item? = null,
)
```

No `Channel` needed — the dialog stays visible until the user decides.

---

## State vs Effects Decision Table

| Component / Signal          | Mechanism         | Why                                                        |
|-----------------------------|-------------------|------------------------------------------------------------|
| Snackbar                    | `Channel<Effect>` | Fire-and-forget; must not replay on recomposition          |
| BottomSheet (programmatic)  | `Channel<Effect>` | ViewModel-initiated; same replay concern as snackbar       |
| BottomSheet (user tap)      | Local `mutableStateOf` | User intent lives in UI; no ViewModel round-trip needed |
| Dialog                      | State boolean     | Decision in progress; should survive recomposition         |
| Toast / platform notification | `Channel<Effect>` | Transient; platform-consumed outside Compose tree        |
| Navigation                  | `Channel<Effect>` | One-shot destination change; must not re-navigate on recompose |

---

## NavigationSuiteScaffold

<!-- API-version-sensitive: requires material3-adaptive-navigation-suite 1.0.0+
     artifact = androidx.compose.material3:material3-adaptive-navigation-suite -->

`NavigationSuiteScaffold` replaces the manual pattern of switching between
`NavigationBar`, `NavigationRail`, and `PermanentNavigationDrawer` based on
window size class. It reads the current window size and selects the correct
navigation component automatically.

### What it replaces (manual approach)

```kotlin
// BEFORE — manual switching
val windowSizeClass = currentWindowAdaptiveInfo().windowSizeClass

when {
    windowSizeClass.windowWidthSizeClass == WindowWidthSizeClass.COMPACT ->
        NavigationBar { /* items */ }
    windowSizeClass.windowWidthSizeClass == WindowWidthSizeClass.MEDIUM ->
        NavigationRail { /* items */ }
    else ->
        PermanentNavigationDrawer(drawerContent = { /* items */ }) { /* content */ }
}
```

### NavigationSuiteScaffold (recommended)

```kotlin
// API-version-sensitive: material3-adaptive-navigation-suite 1.0.0+
@Composable
fun AppScaffold(
    selectedDestination: Destination,
    onNavigate: (Destination) -> Unit,
    content: @Composable () -> Unit,
) {
    NavigationSuiteScaffold(
        navigationSuiteItems = {
            Destination.entries.forEach { destination ->
                item(
                    selected = destination == selectedDestination,
                    onClick = { onNavigate(destination) },
                    icon = {
                        Icon(destination.icon, contentDescription = destination.label)
                    },
                    label = { Text(destination.label) },
                )
            }
        },
    ) {
        content()
    }
}
```

> **CMP availability:** `NavigationSuiteScaffold` ships in
> `androidx.compose.material3:material3-adaptive-navigation-suite`. As of
> Compose Multiplatform 1.7+, the adaptive libraries are available on Android,
> desktop (JVM), and iOS. Verify the artifact version in
> [cmp-dependencies.md](cmp-dependencies.md) before adopting — APIs marked
> `@ExperimentalMaterial3AdaptiveApi` may change across releases.

---

## M2 to M3 Migration Quick Reference

### API Renames

| Material 2                     | Material 3                              | Notes                                       |
|--------------------------------|-----------------------------------------|---------------------------------------------|
| `Colors`                       | `ColorScheme`                           | Tonal palette replaces fixed theme colors   |
| `lightColors()` / `darkColors()` | `lightColorScheme()` / `darkColorScheme()` | Parameter names differ significantly     |
| `BottomNavigation`             | `NavigationBar`                         | Different default elevation / tonal surface |
| `BottomNavigationItem`         | `NavigationBarItem`                     | Icon + label API largely unchanged          |
| `ModalBottomSheetLayout`       | `ModalBottomSheet`                      | No longer wraps content; shown conditionally|
| `ModalDrawer`                  | `ModalNavigationDrawer`                 | Requires `DrawerState` instead of scaffold state |
| `Scaffold` with `scaffoldState`| `Scaffold` with `snackbarHost`          | Snackbar host extracted to a lambda param   |
| `TopAppBar` with `elevation`   | `TopAppBar` with `scrollBehavior`       | Elevation replaced by tonal color on scroll |
| `Card`                         | `Card` / `ElevatedCard` / `OutlinedCard`| Three explicit variants instead of one      |
| `TextField`                    | `TextField` with `TextFieldState`       | State hoisting model changed (1.3.0+)       |

### Key Migration Patterns

**Colors to ColorScheme remapping:**

```kotlin
// M2
private val LightColors = lightColors(
    primary = Color(0xFF6200EE),
    primaryVariant = Color(0xFF3700B3),
    secondary = Color(0xFF03DAC6),
)

// M3 — no primaryVariant; use tonal roles instead
private val LightColorScheme = lightColorScheme(
    primary = Color(0xFF6750A4),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFEADDFF),
    onPrimaryContainer = Color(0xFF21005D),
    secondary = Color(0xFF625B71),
    // ... full tonal mapping
)
```

**Scaffold state change:**

```kotlin
// M2
val scaffoldState = rememberScaffoldState()
scaffoldState.snackbarHostState.showSnackbar("Done")

// M3
val snackbarHostState = remember { SnackbarHostState() }
Scaffold(
    snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
) { /* ... */ }
snackbarHostState.showSnackbar("Done")
```

**Elevation to tonal surface:**

```kotlin
// M2 — explicit shadow elevation
Surface(elevation = 4.dp) { /* ... */ }

// M3 — tonal elevation (color shift, not shadow)
Surface(tonalElevation = 4.dp) { /* ... */ }
// Use shadowElevation only when actual shadow is needed
```

---

## See Also

- [cmp-dependencies.md](cmp-dependencies.md) — BOM versions and artifact coordinates for adaptive libraries
- [cmp-platform-adaptation.md](cmp-platform-adaptation.md) — `expect`/`actual` patterns for iOS sheet physics, status bar, and edge-to-edge
- [cmp-dynamic-color.md](cmp-dynamic-color.md) — Dynamic color extraction on Android 12+ and fallback strategies for iOS/desktop
- [component-catalog.md](component-catalog.md) — Upstream M3 component visual reference
- [navigation-patterns.md](navigation-patterns.md) — Upstream navigation token tables and canonical layouts
