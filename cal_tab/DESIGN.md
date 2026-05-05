---
name: Vitality Minimalist
colors:
  surface: "#faf9fe"
  surface-dim: "#dad9df"
  surface-bright: "#faf9fe"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#f4f3f8"
  surface-container: "#eeedf3"
  surface-container-high: "#e9e7ed"
  surface-container-highest: "#e3e2e7"
  on-surface: "#1a1b1f"
  on-surface-variant: "#3d4a3c"
  inverse-surface: "#2f3034"
  inverse-on-surface: "#f1f0f5"
  outline: "#6d7b6b"
  outline-variant: "#bccbb8"
  surface-tint: "#006e28"
  primary: "#006e28"
  on-primary: "#ffffff"
  primary-container: "#34c759"
  on-primary-container: "#004d1a"
  inverse-primary: "#53e16f"
  secondary: "#8c5000"
  on-secondary: "#ffffff"
  secondary-container: "#fe9400"
  on-secondary-container: "#633700"
  tertiary: "#c0000a"
  on-tertiary: "#ffffff"
  tertiary-container: "#ff8e80"
  on-tertiary-container: "#890005"
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  primary-fixed: "#72fe88"
  primary-fixed-dim: "#53e16f"
  on-primary-fixed: "#002107"
  on-primary-fixed-variant: "#00531c"
  secondary-fixed: "#ffdcbf"
  secondary-fixed-dim: "#ffb874"
  on-secondary-fixed: "#2d1600"
  on-secondary-fixed-variant: "#6a3b00"
  tertiary-fixed: "#ffdad5"
  tertiary-fixed-dim: "#ffb4aa"
  on-tertiary-fixed: "#410001"
  on-tertiary-fixed-variant: "#930005"
  background: "#faf9fe"
  on-background: "#1a1b1f"
  surface-variant: "#e3e2e7"
typography:
  display:
    fontFamily: Inter
    fontSize: 34px
    fontWeight: "700"
    lineHeight: 41px
    letterSpacing: -0.5px
  h1:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: "700"
    lineHeight: 34px
    letterSpacing: -0.4px
  h2:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: "600"
    lineHeight: 28px
    letterSpacing: -0.3px
  body-lg:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: "400"
    lineHeight: 22px
    letterSpacing: -0.2px
  body-sm:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: "400"
    lineHeight: 20px
    letterSpacing: 0px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "600"
    lineHeight: 16px
    letterSpacing: 0.5px
  caption:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: "400"
    lineHeight: 18px
    letterSpacing: 0px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  container-padding: 20px
  gutter: 16px
---

## Brand & Style

The brand personality focuses on clarity, health, and effortless tracking. The target audience includes health-conscious individuals who value efficiency and aesthetic harmony. The UI evokes a sense of calm and control, removing the "clutter" often associated with nutritional data.

This design system utilizes a **Minimalist** approach with strong influences from **Apple’s Human Interface Guidelines**. It prioritizes heavy whitespace to reduce cognitive load and uses high-quality typography to establish a clear information hierarchy. Elements are soft and approachable, using generous rounded corners and subtle depth to make the digital experience feel as tactile as a physical health journal.

## Colors

The palette is rooted in functional clarity. The primary green is reserved for positive reinforcement—hitting goals and remaining within caloric limits. Warning and exceeded states use orange and red respectively to provide immediate, non-intrusive feedback.

The neutral scale is critical for depth; use the lighter grays for secondary surfaces and background fills, while the darker grays are reserved for secondary text and icons. In dark mode, the background shifts to a near-black to maintain high contrast while reducing eye strain.

## Typography

This design system uses **Inter** to emulate the clean, neo-grotesque feel of SF Pro. The hierarchy is established through dramatic weight contrasts. Headlines are bold and tight-set to grab attention, while body text remains legible with generous leading.

Secondary information should use the `caption` or `body-sm` styles in a medium gray tint to maintain the "Apple-like" layered information architecture. Use `label-caps` sparingly for section headers or small data categories.

## Layout & Spacing

The system follows a strict **8pt grid** to ensure mathematical harmony across all screen sizes. Layouts should utilize a **fluid grid** with fixed side margins of 20px on mobile.

Whitespace is a functional element, not a void; use `xxl` spacing to separate major content groups and `md` spacing for internal card padding. Elements should be grouped logically using proximity, with larger gaps between unrelated sections to guide the user's eye through their daily stats.

## Elevation & Depth

Depth is created through **ambient shadows** and **tonal layers** rather than heavy lines. Surfaces should feel physically lifted off the background.

Shadows should be extremely soft: a Y-offset of 4px to 10px with a large blur radius (20px+) and very low opacity (5-10%). For secondary depth, use tonal layering—placing a white card on a `#F2F2F7` background. Avoid using borders unless they are very faint (1px, 5% opacity) to define edges in high-brightness environments.

## Shapes

The shape language is defined by high-radius **Rounded** corners. Standard cards and containers use a minimum of 20px (`rounded-lg`) to create a friendly, modern aesthetic.

Buttons and small interactive elements like chips should use `rounded-xl` or fully circular (pill) shapes. The objective is to eliminate sharp points entirely, reinforcing the soft, approachable nature of the brand.

## Components

**Buttons**  
Primary buttons are pill-shaped with the primary accent color and white text. Secondary buttons use a light gray fill with dark text. Both should have a subtle scale-down transform on press.

**Cards**  
The core of the UI. Cards must have a 20px+ corner radius, a soft ambient shadow, and a white (light) or dark gray (dark) surface. Use cards to group food entries or daily summaries.

**Progress Rings**  
Inspired by the "Activity Rings" style. Use the primary green for the active stroke. The background stroke should be a very faint version of the same hue (10% opacity) rather than gray, to maintain color vibrance.

**List Items**  
Clean, edge-to-edge separators within cards. Use a subtle 0.5px line or simple vertical spacing to distinguish items. Include a chevron icon for navigable rows.

**Tab Bar**  
A modern, translucent (Backdrop Blur) tab bar at the bottom. Icons should be thin-line style when inactive and filled/colored when active. No visible border at the top; use a very soft shadow or 1px light gray line.

**Input Fields**  
Large, clear inputs with a subtle background fill instead of a bottom line. Ensure the "Add Food" search bar has a 12px-16px corner radius and a clear placeholder.
