# CMP Platform Adaptation

## Why This Matters

The #1 question Compose Multiplatform developers ask about Material Design 3 is: "Will this feel wrong on iOS?" This guide answers that question component by component, documents where iOS users may feel friction, and provides clear guidance on when to use M3 as-is vs when to consider platform-specific adaptation.

## Skill Position

This skill takes the **M3 pure cross-platform** position:

- Material Design 3 IS the design system. Use it consistently across platforms.
- M3 provides a cohesive, polished UI that works well everywhere.
- We document where iOS users may feel friction, but we do NOT prescribe replacing M3 with native iOS components as a default approach.
- Breaking M3 for platform convention is sometimes necessary — this guide tells you exactly when.

## Component-by-Component Analysis

| Component | M3 Behavior | iOS Expectation | Friction | Guidance |
|---|---|---|---|---|
| NavigationBar | Bottom, 3-5 items, indicator pill | UITabBar with different styling and transitions | Medium | **Use M3.** Bottom navigation is universal. The visual style differs from UITabBar but users adapt quickly. |
| BottomSheet | M3 drag handle, scrim, continuous drag | iOS detent system, snap points, rubber-band physics | High | **Consider platform-specific.** iOS users have strong expectations about sheet physics. If sheets are central to your UX, consider `expect/actual` with UIKit sheets on iOS. |
| DatePicker | M3 calendar grid / text input toggle | iOS wheel picker (UIDatePicker) | High | **Document both options.** Some apps use M3 picker everywhere; others use `expect/actual` to show the iOS wheel on iOS. User testing recommended. |
| Dialog | M3 centered dialog with actions at bottom-right | iOS alert with centered text and stacked/side-by-side buttons | Medium | **Use M3.** Dialogs are functional; the style difference is minor. iOS users understand centered dialogs. |
| Snackbar | M3 bottom-aligned, temporary message | No direct iOS equivalent (closest: toast/banner) | Low | **Use M3.** iOS has no standard snackbar, so there's no conflicting expectation. |
| FAB | M3 floating action button, bottom-right | No iOS equivalent | Low | **Use M3.** FABs are uncommon on iOS but not unfamiliar. Android apps popularized the pattern. |
| TopAppBar | M3 center-aligned or large collapsing | UINavigationBar with specific title behavior, back button | Medium | **Use M3.** The visual style differs but the function is clear. Note: iOS users expect swipe-back gesture, which is a separate concern (see iOS-Specific Considerations). |
| TextField | M3 outlined/filled with label animation | iOS rounded rect with no floating label | Low-Medium | **Use M3.** The animated label is actually an improvement over iOS defaults. |
| Switch | M3 switch with optional icon | iOS UISwitch with different visual style | Low | **Use M3.** Functionally identical; visual difference is minor. |
| Slider | M3 slider with thumb and track | iOS UISlider with different visual style | Low | **Use M3.** Functionally identical. |
| Tabs | M3 primary/secondary tabs with indicator | iOS segmented control (for 2-3 items) or custom | Low-Medium | **Use M3.** Tabs are a universal pattern. |

### Summary by Friction Level

- **Low friction (use M3 confidently):** Snackbar, FAB, Switch, Slider, TextField, Tabs
- **Medium friction (use M3, acceptable):** NavigationBar, Dialog, TopAppBar
- **High friction (consider platform-specific):** BottomSheet, DatePicker

## Haptics and Ripple

### Android
Ripple `Indication` is the standard M3 interaction feedback. Android users expect a visible ripple expanding from the touch point.

### iOS
iOS users expect a brief highlight (opacity change) on tap, NOT a ripple. The ripple effect feels distinctly "Android" to iOS users.

### How CMP Handles This
In Compose Multiplatform, the default `Indication` is ripple on all platforms. This is because CMP uses the Material `Indication` system, which is platform-agnostic.

### Should You Customize?

**For most apps: no.** The ripple is subtle enough that most iOS users don't notice or care, especially if the rest of the app follows M3 consistently. Changing indication per platform adds complexity for marginal UX gain.

**When to consider customizing:** If your app specifically targets iOS-first users, or if user testing reveals the ripple as a friction point. In that case:

```kotlin
// commonMain — expect/actual for platform indication
// API-version-sensitive: Indication API may vary by CMP version
expect fun platformIndication(): Indication

// androidMain
actual fun platformIndication(): Indication = ripple()

// iosMain
actual fun platformIndication(): Indication {
    // Custom highlight indication
    // Implementation depends on your CMP version and Indication API
}
```

### Haptics as Semantic Effects

Model haptics as semantic effects via interface + DI (not `expect/actual`) because haptics involve platform-specific behavior and benefit from fakes in testing:

```kotlin
// commonMain — interface
enum class HapticType { Confirm, Error, Selection }

interface Haptics {
    fun perform(type: HapticType)
}

// androidMain — implementation
class AndroidHaptics(private val view: View) : Haptics {
    override fun perform(type: HapticType) {
        when (type) {
            HapticType.Confirm -> view.performHapticFeedback(HapticFeedbackConstants.CONFIRM)
            HapticType.Error -> view.performHapticFeedback(HapticFeedbackConstants.REJECT)
            HapticType.Selection -> view.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK)
        }
    }
}

// iosMain — implementation via UIKit interop
class IosHaptics : Haptics {
    override fun perform(type: HapticType) {
        // UIImpactFeedbackGenerator / UINotificationFeedbackGenerator via interop
    }
}

// Test — fake
class FakeHaptics : Haptics {
    val performed = mutableListOf<HapticType>()
    override fun perform(type: HapticType) { performed += type }
}
```

Inject via Koin or your DI framework. This follows the interface+DI pattern because haptics are a **service with platform-specific behavior** — not a stateless fact.

## When to Break M3 for Platform Convention

### Break M3 For:

- **OS-level navigation gestures**: iOS swipe-back, Android predictive back. These are system-level interactions that users expect regardless of the app's design system.
- **System-level interactions**: Share sheets, permissions dialogs, in-app purchases, camera/photo picker. These invoke native OS UI that should look and feel native.
- **Accessibility services**: If TalkBack (Android) or VoiceOver (iOS) has specific expectations for a component type, follow the platform's accessibility conventions.

### Never Break M3 For:

- **Color**: The M3 color system (tonal palette, dynamic color) IS the app's visual identity. Don't mix M3 colors with iOS system colors.
- **Typography**: Use the M3 type scale. Don't switch to SF Text/Display styles just because you're on iOS.
- **Shape**: The M3 shape system (rounded corners, shape tokens) should be consistent. Don't use iOS-style squircles.
- **Elevation**: M3 tonal elevation is the depth cue system. Don't switch to iOS-style shadows.
- **Spacing and layout**: M3 layout tokens (margins, gutters, breakpoints) work cross-platform.

### Rule of Thumb

> If the user interacts with the **OS** (share, permissions, navigation gestures), follow the platform.
> If the user interacts with **your app** (buttons, cards, lists, forms), follow M3.

## Interface vs expect/actual Decision Framework

When bridging platform differences in CMP, choose the right pattern:

| Need | Pattern | Why |
|---|---|---|
| Service with lifecycle/state/async (haptics, analytics, file I/O) | Interface + DI | Testable with fakes, swappable, lifecycle-aware |
| Stateless platform fact (UUID, platform name, default font, dynamic color availability) | `expect/actual` function | No DI overhead for a one-liner |
| Reuse existing platform type in common signature | `expect class` + `actual typealias` | Rare — prefer interface |

**Rule of thumb:** If you'd want to fake it in a test, use an interface. If it's a pure function with no dependencies, use `expect/actual`.

Examples in this skill:
- Dynamic color → `expect/actual` (stateless platform fact) — see [cmp-dynamic-color.md](cmp-dynamic-color.md)
- Haptics → interface + DI (platform service) — see Haptics section above
- Status bar styling → `expect/actual` (simple platform bridge) — see [cmp-system-integration.md](cmp-system-integration.md)

## Platform-Specific Implementation Patterns

### expect/actual for Components

When you need different component behavior per platform:

```kotlin
// commonMain
// API-version-sensitive: DatePickerState API may change across CMP releases
@Composable
expect fun PlatformDatePicker(
    state: DatePickerState,
    onDismiss: () -> Unit,
)

// androidMain — use M3 DatePicker
@Composable
actual fun PlatformDatePicker(state: DatePickerState, onDismiss: () -> Unit) {
    DatePickerDialog(
        onDismissRequest = onDismiss,
        confirmButton = { TextButton(onClick = { onDismiss() }) { Text("OK") } }
    ) {
        DatePicker(state = state)
    }
}

// iosMain — use UIKit date picker via interop (if desired)
@Composable
actual fun PlatformDatePicker(state: DatePickerState, onDismiss: () -> Unit) {
    // Option 1: Use the same M3 DatePicker (simplest, works fine)
    DatePickerDialog(
        onDismissRequest = onDismiss,
        confirmButton = { TextButton(onClick = { onDismiss() }) { Text("OK") } }
    ) {
        DatePicker(state = state)
    }
    // Option 2: UIKit interop for native iOS wheel picker (more complex)
}
```

### Checking Platform at Runtime

```kotlin
// commonMain
expect val currentPlatform: Platform

enum class Platform { Android, IOS, Desktop }

// Use for minor conditional adjustments — NOT for wholesale component replacement
@Composable
fun AppContent() {
    val showBackArrow = currentPlatform != Platform.IOS // iOS uses swipe-back
    TopAppBar(
        navigationIcon = {
            if (showBackArrow) {
                IconButton(onClick = { /* navigate back */ }) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                }
            }
        },
        title = { Text("Screen Title") }
    )
}
```

**Use runtime platform checks sparingly.** Prefer `expect/actual` for structural differences and reserve runtime checks for small conditional adjustments.

## iOS-Specific Considerations

### Swipe-Back Gesture
iOS users expect to swipe from the left edge to go back. In CMP, this depends on your navigation library:
- **Decompose / Voyager**: May support iOS swipe-back gestures via configuration
- **Navigation Compose**: Check CMP version for iOS gesture support
- **Custom**: You may need `expect/actual` to bridge with iOS `UINavigationController` behavior

### Keyboard Handling
- iOS keyboard includes a toolbar with Done/Next buttons that Android doesn't have
- `Modifier.imePadding()` works cross-platform in recent CMP versions
- Text field scroll-into-view behavior may differ — test on both platforms

### Text Selection
- iOS has different text selection handles and magnifying glass behavior
- CMP renders its own text selection UI, which may differ from native iOS
- This is generally acceptable — most users don't notice the difference

### Status Bar Tap to Scroll
iOS users expect tapping the status bar to scroll a list to the top. This is a UIKit behavior that requires explicit implementation in CMP:

```kotlin
// This requires iOS-specific interop to detect status bar taps
// Consider implementing only if scroll-heavy content is central to your UX
```

### Large Title / Collapsing Header
iOS apps commonly use large collapsing titles (UINavigationBar with large title). M3's `LargeTopAppBar` provides a similar pattern but with M3 visual styling. This is one area where M3 and iOS conventions actually align well.
