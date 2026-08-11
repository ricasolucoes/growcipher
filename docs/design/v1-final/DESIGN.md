---
name: Sovereign Vault
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#bacac5'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#859490'
  outline-variant: '#3c4a46'
  surface-tint: '#3cddc7'
  primary: '#57f1db'
  on-primary: '#003731'
  primary-container: '#2dd4bf'
  on-primary-container: '#00574d'
  inverse-primary: '#006b5f'
  secondary: '#b9c7e0'
  on-secondary: '#233144'
  secondary-container: '#3c4a5e'
  on-secondary-container: '#abb9d2'
  tertiary: '#a8e7cd'
  on-tertiary: '#003829'
  tertiary-container: '#8ccbb2'
  on-tertiary-container: '#155743'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#62fae3'
  primary-fixed-dim: '#3cddc7'
  on-primary-fixed: '#00201c'
  on-primary-fixed-variant: '#005047'
  secondary-fixed: '#d5e3fd'
  secondary-fixed-dim: '#b9c7e0'
  on-secondary-fixed: '#0d1c2f'
  on-secondary-fixed-variant: '#3a485c'
  tertiary-fixed: '#b0f0d6'
  tertiary-fixed-dim: '#95d3ba'
  on-tertiary-fixed: '#002117'
  on-tertiary-fixed-variant: '#0b513d'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style

The design system is built on the principles of **digital sovereignty and industrial-grade security**. It targets professionals who prioritize the privacy of their cultivation data above all else. The aesthetic avoids overused botanical tropes, opting instead for a **Sober Technical** style that blends Corporate Modernism with subtle Tactical influences.

The UI must evoke the feeling of a high-security physical vault: heavy, immutable, and impenetrable. This is achieved through a structured hierarchy, precision-engineered alignment, and a "Dark-First" philosophy that ensures discretion in low-light environments. The interface is functional and utilitarian, prioritizing data density and clarity over decorative flair.

## Colors

The palette is rooted in **Deep Slate and Obsidian tones** to provide a secure, low-profile foundation. 
- **Primary:** A sharp "Cipher Teal" used sparingly for critical actions and active states, providing high legibility against dark backgrounds.
- **Secondary:** "Slate Shield" grays for structural elements, borders, and secondary surfaces.
- **Tertiary:** "Forest Shade" deep greens used for subtle semantic reinforcement of the cannabis industry without becoming a primary visual driver.
- **Neutral:** A range of high-contrast slates and off-whites for text and iconography.

While the system supports a Light mode for high-glare environments, it is optimized for Dark mode to maintain user discretion and reduce ocular strain during long-term data logging.

## Typography

This design system utilizes a high-contrast typographic pairing to balance modern tech with data precision. 
- **Headlines:** Use **Hanken Grotesk** for a sharp, contemporary, and professional appearance.
- **Body:** **Inter** is utilized for maximum legibility in complex data tables and long-form logs. 
- **Data & Metadata:** **JetBrains Mono** is assigned to labels, timestamps, and encrypted strings to reinforce the "Cipher" and technical nature of the application.

Typography follows the Material 3 scale, ensuring clear information architecture even in data-heavy screens.

## Layout & Spacing

The layout employs a **strict 8px baseline grid** to ensure mathematical precision across all components.
- **Mobile:** 4-column fluid grid with 16px margins.
- **Tablet:** 8-column fluid grid with 24px margins.
- **Desktop:** 12-column grid with a maximum content width of 1440px.

Data density is a priority; padding is tight (8px-16px) within data-heavy modules to allow for maximum information visibility without scrolling, while outer container margins (24px) provide the necessary visual breathing room to prevent cognitive overload.

## Elevation & Depth

To maintain a "vault-like" feel, this design system rejects heavy shadows in favor of **Tonal Layering** and **Structural Outlines**.
- **Surface Levels:** Depth is communicated through increasing brightness. The base background is the darkest shade, with containers and cards being progressively lighter shades of Slate.
- **Outlines:** Low-contrast borders (1px) in `secondary_color` are used to define boundaries.
- **Interaction Depth:** Active states may use a subtle 0-2-4px ambient shadow with a teal tint to indicate "pressable" height without breaking the flat, technical aesthetic.

## Shapes

The shape language is **Soft (0.25rem)**. This provides enough definition to feel modern and accessible while maintaining the rigid, architectural feel of a professional tool. Sharp corners are avoided to prevent a "hostile" feel, but large radii (pills) are strictly forbidden as they conflict with the sober, vault-like narrative. Large containers and cards use `rounded-lg` (0.5rem) to subtly distinguish primary content areas.

## Components

- **Buttons:** Primary buttons use a solid Teal fill with Dark Slate text. Secondary buttons use an outlined style with a 1px Slate border. All buttons have a fixed height of 40px or 48px to ensure a substantial, tactile feel.
- **Cards:** Cards should not have shadows. Use a subtle background-color difference (e.g., Slate-900 on Slate-950) and a 1px border.
- **Input Fields:** Use "Filled" style with a bottom-only indicator or a "Fully Outlined" style. Labels should use the Monospace font to emphasize the "entry" of technical data.
- **Lists:** Data rows should be separated by thin, low-opacity dividers. Use `label-sm` (Monospace) for secondary data points like timestamps or SKU numbers.
- **Chips:** Used for "Strains" or "Status" tags. These should have 2px roundedness (near-sharp) and use muted, desaturated versions of semantic colors (e.g., dull red for "Alert", deep teal for "Stable").
- **Security Indicator:** A persistent "Vault Status" component in the navigation bar should indicate encryption state and offline-sync status using a lock icon and Monospace typography.