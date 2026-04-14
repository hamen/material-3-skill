# CMP System Integration

## Why This Matters

System UI integration is where "write once, run everywhere" breaks down in Compose Multiplatform. Edge-to-edge rendering, safe areas, status bar styling, system fonts, and Android `Context` dependencies all differ by platform. These patterns are needed in virtually every CMP project.

## Edge-to-Edge and Insets

### Android

Android uses `enableEdgeToEdge()` and the `WindowInsets` API:

```kotlin
// androidMain — Activity setup
import androidx.activity.enableEdgeToEdge

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent { App() }
    }
}
```

In composables, use `WindowInsets` modifiers:

```kotlin
// Works in androidMain or commonMain (when targeting Android)
Scaffold(
    contentWindowInsets = WindowInsets.systemBars
) { innerPadding ->
    Content(Modifier.padding(innerPadding))
}

// Or apply individually:
Box(
    modifier = Modifier
        .statusBarsPadding()
        .navigationBarsPadding()
        .imePadding()
)
```

### iOS

iOS uses Safe Area insets. In Compose for iOS, the Compose view is typically hosted in a `UIViewController`, and safe area handling depends on how the Compose view is embedded.

```kotlin
// iosMain — typical setup in MainViewController.kt
import androidx.compose.ui.window.ComposeUIViewController

fun MainViewController() = ComposeUIViewController { App() }
```

Safe area insets in CMP for iOS are handled automatically by the framework when using `Scaffold` — the `contentWindowInsets` respect iOS safe areas. Verify this with your CMP version.

### CMP Pattern

For most apps, `Scaffold` with `contentWindowInsets` handles insets cross-platform:

```kotlin
// commonMain — works on all platforms
// API-version-sensitive — WindowInsets.safeDrawing availability depends on CMP version
@Composable
fun AppScreen() {
    Scaffold(
        topBar = { TopAppBar(title = { Text("My App") }) },
        contentWindowInsets = WindowInsets.safeDrawing // adapts per platform
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier.padding(innerPadding),
            contentPadding = PaddingValues(16.dp)
        ) {
            // Content
        }
    }
}
```

If you need more granular control, `WindowInsets` APIs are available in `commonMain` in recent CMP versions. Check your version for:
- `WindowInsets.safeDrawing` — safe area on all platforms
- `WindowInsets.statusBars` — status bar area
- `WindowInsets.navigationBars` — navigation bar / home indicator area
- `WindowInsets.ime` — software keyboard

**Libraries:** If built-in insets are insufficient, consider community libraries like `moko-resources` or platform-specific `expect/actual` wrappers.

## System Fonts

### Platform Defaults

| Platform | Default System Font | Notes |
|---|---|---|
| Android | Roboto | Standard M3 typeface. Available on all Android devices. |
| iOS | San Francisco | Cannot be explicitly loaded by name. System provides it. |
| Desktop (macOS) | San Francisco | Same as iOS. |
| Desktop (Windows) | Segoe UI | Microsoft system font. |
| Desktop (Linux) | Varies | Depends on distribution and user config. |

### FontFamily.Default

In Compose Multiplatform, `FontFamily.Default` resolves to the system font on each platform automatically:

```kotlin
// commonMain — uses system font per platform
Text(
    text = "Hello",
    fontFamily = FontFamily.Default // Roboto on Android, SF on iOS, etc.
)
```

This is the correct default for M3 since the spec uses Roboto as the baseline, and `FontFamily.Default` provides the platform-appropriate equivalent.

### Loading Custom Fonts

Use `compose.components.resources` (the Compose Resources library) to load custom fonts cross-platform:

```kotlin
// commonMain — loading a custom font (CMP)
// API-version-sensitive — Compose Resources API may change between CMP versions
// Place font files in commonMain/composeResources/font/
import your_project.composeapp.generated.resources.Res
import your_project.composeapp.generated.resources.montserrat_regular
import your_project.composeapp.generated.resources.montserrat_bold

// In CMP, Font(Res.font.*) is @Composable — build FontFamily inside composition
// See "CMP Font() Gotcha" below for why this must be a @Composable function
@Composable
fun appTypography(): Typography {
    val fontFamily = FontFamily(
        Font(Res.font.montserrat_regular, FontWeight.Normal),
        Font(Res.font.montserrat_bold, FontWeight.Bold),
    )
    return Typography(
        displayLarge = TextStyle(fontFamily = fontFamily, fontWeight = FontWeight.Normal, fontSize = 57.sp),
        // ... define all type scale styles
    )
}

// Use in theme:
@Composable
fun AppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        typography = appTypography(), // Called inside composition
        content = content,
    )
}
```

Resource path: `commonMain/composeResources/font/montserrat_regular.ttf`

### Recommendation

- **Use a custom font** for brand consistency across platforms. This ensures Android and iOS users see the same typeface.
- **Use `FontFamily.Default`** only when you intentionally want the platform-native feel (e.g., a system utility app that should blend into the OS).
- **Never hardcode `Roboto`** in `commonMain`. It works on Android but won't resolve correctly on iOS/Desktop. Use `FontFamily.Default` if you want the system font, or load a custom font.

### CMP Font() Gotcha (Critical)

In Compose Multiplatform, `Font(Res.font.*)` is **`@Composable`** — unlike Jetpack Compose where `Font()` is a regular function. This means you **cannot** construct `FontFamily` or `Typography` as a top-level `val`. The `appTypography()` example above uses the correct `@Composable` function pattern.

For contrast, Jetpack Compose Android allows top-level construction because its `Font()` is a plain function:

```kotlin
// Jetpack Android — Font() is NOT @Composable, can be a top-level val
val InterFont = FontFamily(
    Font(R.font.inter_regular, FontWeight.Normal),
    Font(R.font.inter_bold, FontWeight.Bold),
)

val AppTypography = Typography(
    bodyLarge = TextStyle(fontFamily = InterFont, fontSize = 16.sp),
)
```

This is one of the most common CMP migration surprises. If you see `@Composable invocations can only happen from the context of a @Composable function` when constructing `Typography`, this is the cause.

## Status Bar Styling

### Android

```kotlin
// androidMain — controlling status bar appearance
import androidx.activity.enableEdgeToEdge
import androidx.activity.SystemBarStyle

// In Activity.onCreate():
enableEdgeToEdge(
    statusBarStyle = SystemBarStyle.auto(
        lightScrim = android.graphics.Color.TRANSPARENT,
        darkScrim = android.graphics.Color.TRANSPARENT,
    )
)
```

Or use `WindowInsetsController` for dynamic changes:

```kotlin
// androidMain
val controller = WindowCompat.getInsetsController(window, window.decorView)
controller.isAppearanceLightStatusBars = !isDarkTheme // light icons on dark bg
```

### iOS

Status bar style on iOS is controlled by the `UIViewController`:

```kotlin
// iosMain — status bar style
// Override in your UIViewController or set via Info.plist:
// UIViewControllerBasedStatusBarAppearance = YES
// Then override preferredStatusBarStyle in your ViewController
```

In practice, iOS handles light/dark status bar icons automatically based on the current trait collection (dark mode). Manual control requires platform-specific UIKit code via `expect/actual`.

### CMP Pattern

For most apps, you don't need to manually control status bar styling — `enableEdgeToEdge()` on Android and iOS's automatic trait handling are sufficient. If you need explicit control:

```kotlin
// commonMain
expect fun setStatusBarStyle(isDark: Boolean)

// androidMain
actual fun setStatusBarStyle(isDark: Boolean) {
    // Use WindowInsetsController as shown above
}

// iosMain
actual fun setStatusBarStyle(isDark: Boolean) {
    // UIKit interop or no-op if automatic handling is sufficient
}
```

## Context-Free Patterns

### The Problem

Many Android M3 APIs require `android.content.Context`:
- `dynamicLightColorScheme(context)` / `dynamicDarkColorScheme(context)`
- `calculateWindowSizeClass(activity)`
- Resource loading, connectivity, system services

But `commonMain` code cannot reference `Context` — it doesn't exist on iOS or Desktop.

### Solution 1: expect/actual That Hides Context

The `expect` function takes no platform-specific parameters. The `actual` on Android obtains `Context` internally.

```kotlin
// commonMain
expect fun platformColorScheme(darkTheme: Boolean): ColorScheme?

// androidMain — uses @Composable to access LocalContext
// API-version-sensitive — dynamic color requires Android 12+ (API 31+)
@Composable
actual fun platformColorScheme(darkTheme: Boolean): ColorScheme? {
    val context = LocalContext.current
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    } else null
}
```

This is the pattern used in [cmp-dynamic-color.md](cmp-dynamic-color.md) for dynamic color.

### Solution 2: Dependency Injection (Koin, etc.)

Provide platform-specific implementations via a DI framework:

```kotlin
// commonMain — define the interface
interface PlatformContext {
    fun getWindowSizeClass(): WindowSizeClass
}

// androidMain — implement with actual Context
class AndroidPlatformContext(private val activity: Activity) : PlatformContext {
    override fun getWindowSizeClass() = calculateWindowSizeClass(activity)
}

// iosMain — implement without Context
class IosPlatformContext : PlatformContext {
    override fun getWindowSizeClass() = /* calculate from UIScreen.main.bounds */
}
```

### Solution 3: LocalPlatformContext

Some CMP versions provide `LocalPlatformContext` — a `CompositionLocal` that provides a platform-appropriate context object. Check your CMP version:

```kotlin
// commonMain — if available in your CMP version
// API-version-sensitive — LocalPlatformContext availability varies by CMP version
val platformContext = LocalPlatformContext.current
// Use for platform-specific operations
```

### Common APIs That Need Context-Free Treatment

| API | Android Dependency | CMP Solution |
|---|---|---|
| Dynamic color | `Context` | `expect/actual` — see [cmp-dynamic-color.md](cmp-dynamic-color.md) |
| Window size class | `Activity` | `expect/actual` or CMP adaptive APIs |
| String resources | `Context.getString()` | `compose.components.resources` (`Res.string.*`) |
| Haptic feedback | `View` | `expect/actual` with platform vibration APIs |
| Share intent | `Context.startActivity()` | `expect/actual` with platform share sheet |
| File I/O | `Context.filesDir` | `okio` or `kotlinx-io` for cross-platform file access |
| Preferences | `SharedPreferences` / `Context` | `multiplatform-settings` or `DataStore` (check CMP support) |
