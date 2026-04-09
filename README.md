# Material Design 3 Skill for Claude Code

A comprehensive [Claude Code](https://claude.ai/claude-code) skill for implementing Google's [Material Design 3](https://m3.material.io/) (Material You) UI system.

## Table of contents

- [What it does](#what-it-does)
- [How this skill was built](#how-this-skill-was-built)
  - [Sources](#sources)
  - [Process](#process)
  - [What this means for accuracy](#what-this-means-for-accuracy)
- [Installation](#installation)
- [Usage](#usage)
  - [Build MD3 components](#build-md3-components)
  - [Generate a theme](#generate-a-theme)
  - [Scaffold an app](#scaffold-an-app)
  - [Audit MD3 compliance](#audit-md3-compliance)
- [What's included](#whats-included)
- [License](#license)

## What it does

- Guides Claude in generating **MD3-compliant UI code** with correct design tokens, components, theming, layout, and accessibility
- Covers **30+ components** with web element names, attributes, and code examples
- Supports **web** (`@material/web`), **Flutter**, and **Jetpack Compose**
- Includes an **MD3 compliance audit** mode that scores apps across 10 categories
- Covers the **M3 Expressive** update (May 2025): spring motion, emphasized typography, shape morphing

## How this skill was built

This skill was created collaboratively between a human and [Claude Code](https://claude.ai/claude-code) (Anthropic's coding agent). The information in the skill files is **distilled from publicly available sources** — it is not original design system documentation, but a curated reference assembled from what exists on the web and in Claude's training data.

### Sources

All design token values, component specs, layout breakpoints, color roles, typography scales, and implementation patterns in this skill were gathered from:

- **[m3.material.io](https://m3.material.io/)** — Google's official Material Design 3 documentation site, browsed live using Claude Code's Chrome browser automation tools
- **Claude's training data** — which includes publicly available Material Design documentation, `@material/web` API references, Flutter and Jetpack Compose documentation, and community guides published before the training cutoff
- **[@material/web](https://github.com/nicegoodthings/material-web) source code** — the official web component library for MD3, used to verify element names, attributes, and import paths

### Process

1. **Planning phase** — We outlined the skill structure: a main `SKILL.md` covering philosophy, decision trees, token overview, component tables, implementation patterns, and an audit procedure, plus 6 focused reference files.

2. **Live site research** — Because m3.material.io is a JavaScript-rendered single-page application (standard `fetch`/`curl` returns an empty shell), we used Claude Code's **Chrome browser automation** (via MCP tools) to navigate the live site, read rendered content, take screenshots, and click through tabbed sections. This was essential for verifying current token values, the full component list, elevation levels, color roles, and the M3 Expressive update details (May 2025) that may not yet be reflected in training data.

3. **Cross-referencing with training data** — The live site content was cross-referenced with Claude's existing knowledge of Material Design 3 to fill in implementation details, code examples, CSS custom property names, Flutter/Compose APIs, and patterns that the site covers at a conceptual level but doesn't always spell out as copy-paste code.

4. **Distillation into skill format** — The raw information was condensed into the skill's markdown files. Token values were organized into lookup tables. Component specs were normalized into a consistent template (element name, import path, attributes, code example, customization properties, accessibility notes). Layout and navigation patterns were turned into complete, working code examples.

5. **Audit system design** — We designed a 10-category MD3 compliance audit (color, typography, shape, elevation, components, layout, navigation, motion, accessibility, theming) that can analyze both source code and live applications, producing a scored report with specific remediation steps.

### What this means for accuracy

The skill represents a **best-effort distillation** of Material Design 3 as of early 2025. Because it was assembled from public web sources and training data:

- Token values and component specs reflect what was published on m3.material.io at the time of creation
- Code examples use `@material/web` APIs that were current at the time — some components (marked with `—` in the catalog) don't have official web component implementations yet
- The M3 Expressive update (spring motion, emphasized typography, shape morphing) is covered, but some features (like shape morphing on web) are noted as unavailable on certain platforms
- If Google updates the spec, this skill may drift — contributions and corrections are welcome

## Installation

Copy the skill into your Claude Code skills directory:

```bash
# Clone the repo
git clone https://github.com/nicegoodthings/material-3-skill.git

# Copy to Claude Code skills directory
cp -r material-3-skill ~/.claude/skills/material-3
```

Or symlink for easy updates:

```bash
ln -s /path/to/material-3-skill ~/.claude/skills/material-3
```

## Usage

### Build MD3 components

```
/material-3 component Create a login form with email and password fields
```

### Generate a theme

```
/material-3 theme Generate a theme from seed color #1A73E8
```

### Scaffold an app

```
/material-3 scaffold Create a responsive app shell with navigation
```

### Audit MD3 compliance

```
/material-3 audit [URL or file path]
```

The audit scores your app across 10 categories (color tokens, typography, shape, elevation, components, layout, navigation, motion, accessibility, theming) and produces a detailed report with specific fixes.

## What's included

| File | Description |
|------|-------------|
| `SKILL.md` | Main skill: philosophy, decision trees, token overview, component table, web implementation patterns, audit procedure |
| `references/color-system.md` | All 29+ color roles, tonal palettes, dynamic color, baseline scheme CSS |
| `references/component-catalog.md` | All 30+ components with `@material/web` elements, attributes, code examples |
| `references/theming-and-dynamic-color.md` | Theme generation, brand colors, dark mode, runtime switching |
| `references/typography-and-shape.md` | Type scale (30 styles), shape corner tokens, elevation levels, motion tokens |
| `references/navigation-patterns.md` | Nav component selection, responsive transitions, complete responsive shell |
| `references/layout-and-responsive.md` | 5 breakpoints, 3 canonical layouts, CSS Grid implementation |

## License

MIT
