# CMP Dependencies and Version Management

## Why This Matters

Wrong Maven coordinates is the #1 setup error for Compose Multiplatform beginners. Jetpack Compose and Compose Multiplatform use different artifact groups, and mixing them causes resolution failures on non-Android targets.

## Dependency Coordinates

| Library | Jetpack Compose (Android-only) | Compose Multiplatform |
|---|---|---|
| Material3 core | `androidx.compose.material3:material3` | `org.jetbrains.compose.material3:material3` |
| Material3 adaptive | `androidx.compose.material3.adaptive:adaptive-*` | Check CMP release notes for availability |
| Window size classes | `androidx.compose.material3:material3-window-size-class` | `org.jetbrains.compose.material3:material3-window-size-class` |
| Material icons core | `androidx.compose.material:material-icons-core` | `org.jetbrains.compose.material:material-icons-core` |
| Material icons extended | `androidx.compose.material:material-icons-extended` | `org.jetbrains.compose.material:material-icons-extended` |
| Compose runtime | `androidx.compose.runtime:runtime` | `org.jetbrains.compose.runtime:runtime` |
| Compose UI | `androidx.compose.ui:ui` | `org.jetbrains.compose.ui:ui` |
| Compose Foundation | `androidx.compose.foundation:foundation` | `org.jetbrains.compose.foundation:foundation` |

**Rule:** In `commonMain`, always use `org.jetbrains.compose.*` coordinates. The `androidx.compose.*` coordinates only resolve for Android targets.

**Note:** `runtime`, `ui`, and `foundation` are transitive dependencies of `material3`. You only need to declare them explicitly if you use their APIs beyond what `material3` re-exports (e.g., `foundation`'s `LazyColumn` or `runtime`'s `snapshotFlow`). The CMP Gradle plugin manages their versions — you don't need to specify version numbers.

## BOM Usage

### Jetpack Compose (Android-only)

Uses the Compose BOM to align versions:

```kotlin
// build.gradle.kts (Android module)
// BOM-dependent — version number is illustrative
dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.12.01")
    implementation(composeBom)
    implementation("androidx.compose.material3:material3")
}
```

### Compose Multiplatform

Does NOT use the Jetpack BOM. Versions are managed by the `org.jetbrains.compose` Gradle plugin:

```kotlin
// build.gradle.kts (CMP project)
// API-version-sensitive — plugin version determines all compose artifact versions
plugins {
    kotlin("multiplatform")
    id("org.jetbrains.compose") version "1.7.3" // manages all compose dependencies
    id("org.jetbrains.kotlin.plugin.compose")
}

kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(compose.material3)        // org.jetbrains.compose.material3:material3
            implementation(compose.materialIconsExtended)
            // compose.runtime, compose.foundation, compose.ui — provided automatically
        }
        androidMain.dependencies {
            // Android-specific compose dependencies if needed
            // e.g., activity-compose, lifecycle-runtime-compose
            implementation("androidx.activity:activity-compose:1.9.3")
        }
    }
}
```

The `compose.material3` accessor in the Gradle plugin resolves to the correct `org.jetbrains.compose.material3:material3` artifact.

## Version Synchronization

CMP versions do NOT map 1:1 to Jetpack Compose versions.

| Compose Multiplatform | Bundled Kotlin | Approximate Jetpack Compose |
|---|---|---|
| 1.7.x | 2.1.x | ~1.7.x (but NOT identical) |
| 1.6.x | 2.0.x | ~1.6.x |

**How to find the bundled version:**
1. Check the [JetBrains Compose Multiplatform releases](https://github.com/JetBrains/compose-multiplatform/releases)
2. Each release lists the underlying Jetpack Compose version
3. Feature availability depends on this bundled version

**Important:** Don't assume a Jetpack Compose API exists in CMP just because it exists in the Jetpack version with the same number. JetBrains may not have ported all APIs yet.

## Feature Parity Tracker

Not all Jetpack Compose Material3 APIs are available in Compose Multiplatform. Key gaps to check:

| Feature | Jetpack Compose | CMP Status |
|---|---|---|
| Material3 core components | Full | Full (mirrors Jetpack) |
| Dynamic color | Android 12+ | Android only — need expect/actual fallback |
| Material3 adaptive (list-detail, etc.) | Available | Check CMP version — may lag behind |
| Window size classes | Available | Available via compose.material3 |
| MotionScheme (Expressive) | Per BOM | Check CMP version |
| Predictive back gestures | Android | Android-only API |

**How to check:**
- [CMP releases changelog](https://github.com/JetBrains/compose-multiplatform/blob/master/CHANGELOG.md)
- Try importing the API in `commonMain` — if it doesn't resolve, it's not available yet

**Workarounds for missing features:**
- Copy the composable source from Jetpack into your project (check license)
- Use `expect/actual` to provide the feature only on Android, with a simpler fallback on other platforms
- File an issue on the [CMP issue tracker](https://github.com/JetBrains/compose-multiplatform/issues)

## Gradle Configuration Example

Complete `build.gradle.kts` for a CMP project with Material3:

```kotlin
// Illustrative — exact versions depend on your project
plugins {
    kotlin("multiplatform")
    id("org.jetbrains.compose")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.android.application") // or com.android.library
}

kotlin {
    androidTarget()
    iosX64()
    iosArm64()
    iosSimulatorArm64()
    jvm("desktop")

    sourceSets {
        commonMain.dependencies {
            implementation(compose.material3)
            implementation(compose.materialIconsExtended)
            implementation(compose.components.resources) // for Res.font, Res.drawable, etc.
        }

        androidMain.dependencies {
            implementation("androidx.activity:activity-compose:1.9.3")
            implementation("androidx.core:core-splashscreen:1.0.1")
        }

        // iosMain, desktopMain — no extra M3 dependencies needed
        // The CMP plugin provides compose.* for all targets
    }
}
```

## Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| `implementation("androidx.compose.material3:material3")` in `commonMain` | Won't resolve for iOS/Desktop targets | Use `implementation(compose.material3)` |
| Using Jetpack Compose BOM in a CMP project | BOM artifacts are Android-only | Remove BOM; CMP plugin manages versions |
| `LocalContext.current` in `commonMain` | `android.content.Context` doesn't exist on iOS | Use `expect/actual` — see [cmp-system-integration.md](cmp-system-integration.md) |
| Importing `android.os.Build` in `commonMain` | Android-only API | Guard with `expect/actual` or move to `androidMain` |
| Assuming same API surface as Jetpack | Some APIs may not be ported yet | Check CMP release notes; use `expect/actual` for gaps |
| `implementation("androidx.compose.material:material-icons-extended")` in `commonMain` | Wrong artifact group | Use `implementation(compose.materialIconsExtended)` |
