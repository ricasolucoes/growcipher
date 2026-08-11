---
name: Sovereign Vault
colors:
  surface: '#0e1513'
  surface-dim: '#0e1513'
  surface-bright: '#333b39'
  surface-container-lowest: '#09100e'
  surface-container-low: '#161d1b'
  surface-container: '#1a211f'
  surface-container-high: '#242b2a'
  surface-container-highest: '#2f3634'
  on-surface: '#dde4e1'
  on-surface-variant: '#bacac5'
  inverse-surface: '#dde4e1'
  inverse-on-surface: '#2b3230'
  outline: '#859490'
  outline-variant: '#3c4a46'
  surface-tint: '#3cddc7'
  primary: '#57f1db'
  on-primary: '#003731'
  primary-container: '#2dd4bf'
  on-primary-container: '#00574d'
  inverse-primary: '#006b5f'
  secondary: '#b9c8de'
  on-secondary: '#233143'
  secondary-container: '#39485a'
  on-secondary-container: '#a7b6cc'
  tertiary: '#ffd1aa'
  on-tertiary: '#4b2800'
  tertiary-container: '#ffac5a'
  on-tertiary-container: '#744000'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#62fae3'
  primary-fixed-dim: '#3cddc7'
  on-primary-fixed: '#00201c'
  on-primary-fixed-variant: '#005047'
  secondary-fixed: '#d4e4fa'
  secondary-fixed-dim: '#b9c8de'
  on-secondary-fixed: '#0d1c2d'
  on-secondary-fixed-variant: '#39485a'
  tertiary-fixed: '#ffdcc0'
  tertiary-fixed-dim: '#ffb875'
  on-tertiary-fixed: '#2d1600'
  on-tertiary-fixed-variant: '#6b3b00'
  background: '#0e1513'
  on-background: '#dde4e1'
  surface-variant: '#2f3634'
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  card-title:
    fontFamily: Hanken Grotesk
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  body-main:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  metadata:
    fontFamily: Hanken Grotesk
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 14px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style

This design system targets an audience that values security, precision, and clarity in asset management. The brand personality is authoritative yet streamlined, evoking an emotional response of total control and calm reliability.

The design style is **Corporate / Modern** with a lean toward **Minimalism**. It moves away from high-density, border-heavy layouts in favor of sophisticated background grouping. By utilizing subtle shifts in surface shades rather than explicit strokes, the UI achieves a sense of organized hierarchy that feels spacious and premium. The aesthetic is "Technical Elegance"—where every pixel serves a functional purpose within a clean, structured environment.

## Colors

The palette is anchored by a deep, dark canvas to reduce eye strain and emphasize critical data points.

- **Primary Action**: Cyan (#2dd4bf) is reserved exclusively for high-intent interactions, active navigation states, and positive confirmations.
- **Surface Strategy**: Contrast is established through layered backgrounds. Use `surface_primary` for the main background and `surface_secondary` for cards or container groupings to reduce the need for borders.
- **Semantic Logic**: 
  - **Green**: Healthy, completed, or validated states.
  - **Amber**: Attention required or pending status.
  - **Red**: Urgent alerts, overdue tasks, or critical failures.
  - **Blue-gray**: Neutral metadata, inactive states, and secondary labels.

## Typography

This design system utilizes **Hanken Grotesk** across all levels to maintain a sharp, contemporary, and technical feel. Hierarchy is established through weight and color rather than excessive size shifts.

- **Scale Increase**: Body text is moved to 13-14px to ensure high legibility in dense data environments. Metadata is standardized at 11-12px to remain readable while occupying minimal vertical space.
- **Emphasis**: Card titles at 15px use semi-bold weights to anchor container content.
- **Spacing**: Use tight letter spacing on headlines for a "locked-in" appearance, while maintaining standard spacing for body text to support scanning.

## Layout & Spacing

The system employs a **Fluid Grid** model based on a 4px baseline. To reduce visual density, the system prioritizes negative space over divider lines.

- **Background Grouping**: Instead of drawing borders between items, use `surface_secondary` backgrounds for sections. Vertical rhythm is maintained by a 16px (md) standard gap between cards.
- **Margins**: Mobile layouts use 16px side margins. Desktop layouts expand to 48px to allow the content to breathe.
- **Reflow**: On tablet and desktop, cards should transition from a single-column stack to a multi-column grid (2-3 columns depending on content complexity).

## Elevation & Depth

Hierarchy is communicated through **Tonal Layers** and **Low-contrast outlines**.

- **Surface Tiers**: `surface_primary` is the lowest level. Floating elements like cards use `surface_secondary`. Popovers or modals use `surface_tertiary`.
- **Borders**: Limit borders to high-interaction areas or to provide contrast where two similar surface colors meet. Borders should be subtle (1px, 10% opacity white/gray).
- **Shadows**: Avoid heavy shadows. Use a single, crisp, low-opacity drop shadow (0px 4px 12px rgba(0,0,0,0.3)) only for elevated components like Modals or the Center FAB.

## Shapes

The shape language is **Soft** and professional. 

- **Containers**: Standard cards and input fields use a 4px (0.25rem) radius to maintain a precise, technical look.
- **Large Components**: Buttons and larger dialogs can scale up to 8px (0.5rem) to feel more approachable.
- **Active Indicators**: Use vertical or horizontal pills (fully rounded) for status chips and active navigation markers.

## Components

### Navigation Structure
- **TopAppBar**: Minimalist header containing the screen title and secondary actions (e.g., Settings, Profile). Uses `surface_primary`.
- **BottomNavBar**: Fixed navigation with five targets: **Home, Plants, Log (Center FAB), Gallery, and More**. 
    - The **Log (Center FAB)** is emphasized with the `primary_color` (Cyan) and a circular shape to denote the primary action.
    - Active states use the `primary_color` for the icon and a small dot indicator.

### Status System
All statuses must use the **Color + Icon + Label** triad for accessibility:
- **Normal**: Blue-gray / Check icon / "Normal"
- **Warning**: Amber / Alert icon / "Warning"
- **Critical**: Red / X-Circle icon / "Critical"
- **Completed**: Green / Check-Double icon / "Completed"
- **Offline**: Gray / Cloud-Off icon / "Offline"
- **Encrypted**: Cyan / Lock icon / "Encrypted"

### Buttons & Inputs
- **Primary Button**: Solid Cyan background with dark text. 
- **Secondary Button**: `surface_tertiary` background with white text.
- **Input Fields**: Ghost-style with a `surface_tertiary` bottom border or subtle fill. No full borders unless in focus.

### Cards
- Cards do not have visible borders. They rely on the `surface_secondary` fill against the `surface_primary` background for definition. 
- Internal padding is 16px for comfortable data density.