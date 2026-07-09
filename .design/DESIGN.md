---
name: Mercantile Bloom
colors:
  surface: "#f9f9f9"
  surface-dim: "#dadada"
  surface-bright: "#f9f9f9"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#f3f3f3"
  surface-container: "#eeeeee"
  surface-container-high: "#e8e8e8"
  surface-container-highest: "#e2e2e2"
  on-surface: "#1a1c1c"
  on-surface-variant: "#504444"
  inverse-surface: "#2f3131"
  inverse-on-surface: "#f0f1f1"
  outline: "#837473"
  outline-variant: "#d5c2c2"
  surface-tint: "#7d5454"
  primary: "#7d5454"
  on-primary: "#ffffff"
  primary-container: "#fcc6c6"
  on-primary-container: "#795051"
  inverse-primary: "#eebaba"
  secondary: "#635d5d"
  on-secondary: "#ffffff"
  secondary-container: "#e9e0e0"
  on-secondary-container: "#696363"
  tertiary: "#635d5d"
  on-tertiary: "#ffffff"
  tertiary-container: "#dad1d1"
  on-tertiary-container: "#5f5959"
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  primary-fixed: "#ffdad9"
  primary-fixed-dim: "#eebaba"
  on-primary-fixed: "#301314"
  on-primary-fixed-variant: "#623d3d"
  secondary-fixed: "#e9e0e0"
  secondary-fixed-dim: "#cdc5c4"
  on-secondary-fixed: "#1e1b1b"
  on-secondary-fixed-variant: "#4b4646"
  tertiary-fixed: "#eae0e0"
  tertiary-fixed-dim: "#cdc4c4"
  on-tertiary-fixed: "#1f1a1b"
  on-tertiary-fixed-variant: "#4b4546"
  background: "#f9f9f9"
  on-background: "#1a1c1c"
  surface-variant: "#e2e2e2"
typography:
  display-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: "700"
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: "600"
    lineHeight: 32px
  headline-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: "600"
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: "600"
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "400"
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "500"
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "500"
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  edge_margin: 16px
  gutter: 12px
---

## Brand & Style

The design system is engineered for a boutique retail environment where efficiency meets warmth. The brand personality is **welcoming, organized, and artisanal**, aimed at shop owners who balance high-volume transactions with personalized customer relationships.

The aesthetic follows a **refined Material Design 3** approach. It leverages the structural logic of MD3—such as clear hierarchies and functional motion—but softens the industrial edge with a warm, pastel-influenced palette. The goal is to reduce "POS fatigue" by creating a digital workspace that feels as curated as the souvenir shop itself.

The interface prioritizes **tactile clarity**, ensuring that every interactive surface is optimized for high-frequency touch interactions in a physical retail setting.

## Colors

The color strategy centers on the primary `#FCC6C6` (Bloom Pink), a soft yet energetic hue that signals action without aggression.

- **Primary:** Reserved for high-intent actions (FABs, primary buttons) and active navigation states. Text and icons placed on this background must use the dark `on_primary` value for AA accessibility.
- **Surface Strategy:** The background uses a "Neutral White" (`#FAFAFA`) to provide a clean canvas for product photography. Secondary containers and card backgrounds use a "Soft Gray" (`#F4F0F0`) to create subtle grouping without heavy borders.
- **Accents:** Feedback states (success/error) should be muted to align with the pastel primary, avoiding harsh vibrates.

## Typography

The typographic system pairs the friendly, contemporary curves of **Be Vietnam Pro** for headlines with the utilitarian precision of **Inter** for data-heavy CRM tasks.

- **Headlines:** Use Be Vietnam Pro to inject brand character into the "Welcome" screens and section headers.
- **Data & UI:** Use Inter for all transaction lists, product names, and price points. The high x-height of Inter ensures legibility during fast-paced scanning at the counter.
- **Scaling:** For mobile POS views, the `display-lg` is used sparingly for total sale amounts, while `label-md` is the workhorse for metadata like SKU numbers and timestamps.

## Layout & Spacing

This design system utilizes a **8px rhythmic grid** to ensure visual balance.

- **Grid System:** Product catalogs use a 2-column or 3-column `GridView` depending on screen width. Gutters are kept at a strict `12px` to maximize image real estate while preventing visual crowding.
- **Touch Targets:** Minimum touch targets for any interactive element (buttons, list items, toggles) are `48x48px` to accommodate rapid, error-free input during checkout.
- **Safe Areas:** A mandatory `16px` (md) edge margin is applied to all screens. Floating Action Buttons (FABs) are anchored `16px` from the bottom-right corner of the safe area.

## Elevation & Depth

In alignment with Material 3, depth is communicated through **tonal elevation** and soft, ambient shadows.

- **Level 0 (Flat):** Main background and inactive list items.
- **Level 1 (Subtle):** Product cards in the GridView. These use a 4px blur, 0% spread, and 5% black opacity shadow to appear "resting" on the surface.
- **Level 2 (Active):** AppBars and BottomNavigationBars. These use a slightly more pronounced shadow (8px blur) or a subtle 1dp stroke in `surface_variant` to indicate they sit above the content.
- **Level 3 (Override):** Dialogs and FABs. These use the highest elevation to draw immediate focus, paired with a slight background dimming (scrim).

## Shapes

The design system uses **Category 2 (Rounded)** shapes to echo the friendly nature of a gift shop.

- **Small Components:** Checkboxes and Chips use a `4px` radius.
- **Medium Components:** Product cards and text fields use a `8px` (rounded-md) radius.
- **Large Components:** Bottom sheets and large modal containers use a `16px` (rounded-lg) radius on top corners.
- **Full Round:** Buttons and search bars follow the MD3 "Pill" style to distinguish them from content containers.

## Components

- **Floating Action Button (FAB):** The primary engine for "New Sale" or "Add Product." Must be `primary_color_hex` with an `on_primary` icon.
- **AppBar:** Clean and minimalist. Use `headline-sm` for titles. Status badges (e.g., "Online/Offline" or "Syncing") should be placed to the right of the title using small icons.
- **Product Cards:** Rectangular with `roundedness: 2`. Images should take the top 60% of the card, with title and price in the bottom 40% using `label-lg` and `title-lg` respectively.
- **BottomNavigationBar:** Uses a pill-shaped indicator around the active icon. Active icons are filled; inactive icons are outlined. Labels use `label-md`.
- **Transaction Lists:** High-density `ListView`. Use a `1px` stroke separator in `surface_variant` between items. Price should be right-aligned in `title-lg`.
- **Input Fields:** Outlined style with a `1px` border. Active state transitions to a `2px` border in `primary_color_hex`.
