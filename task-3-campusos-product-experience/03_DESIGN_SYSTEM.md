# CampusOS — Design System & Component Guidelines

**Phase:** Phase 1 — Product Research & Experience Foundation  
**Owner:** Arko (Task-3: CampusOS Product Experience)  
**Status:** Implementation-Ready Specification for Task-1  
**Source of Truth:** `docs/04_UX_DESIGN.md`, `docs/02_SRD.md`

---

## 1. Visual Language & Principles

CampusOS uses a **modern, high-contrast, clean campus-command visual style**.
- **Base Canvas:** Neutral crisp background (`#F8FAFC` light / `#0F172A` dark).
- **Brand Anchor:** Deep Collegiate Navy Blue (`#1E3A8A` / `#2563EB`) communicating authority, trust, and clarity.
- **Accents:** Semantic utility colors only (Emergency Red, Alert Amber, Success Emerald, Info Sky).
- **Elevation:** Restrained, soft modern shadows (`0px 2px 8px rgba(0, 0, 0, 0.06)`).
- **Roundness:** Standardized subtle rounding (`8px` small controls, `12px` cards, `16px` modals/bottom sheets).
- **Rule:** Color must NEVER be the sole indicator of status. Every colored status badge must be accompanied by an icon and descriptive text.

---

## 2. Color Palette (Design Tokens)

### 2.1 Brand & Neutral Tokens
| Token Name | Hex Code | Usage |
| :--- | :--- | :--- |
| `color-primary` | `#1E3A8A` | Primary app bar, prominent brand buttons, active tab |
| `color-primary-light` | `#EFF6FF` | Primary button hover / chip selection background |
| `color-primary-accent` | `#3B82F6` | Links, focused borders, subtle brand badges |
| `color-surface` | `#FFFFFF` | Card backgrounds, dialogs, sheet surfaces |
| `color-background` | `#F8FAFC` | App background, page scaffold |
| `color-text-primary` | `#0F172A` | Primary headings, titles, high-emphasis text |
| `color-text-secondary` | `#475569` | Subtitles, body descriptions, meta info |
| `color-text-muted` | `#94A3B8` | Placeholder text, disabled labels, timestamps |
| `color-border` | `#E2E8F0` | Dividers, card borders, unselected input borders |
| `color-border-focused` | `#3B82F6` | Input focus outline, active card outline |

### 2.2 Semantic & Status Tokens
| State / Level | Background Hex | Text / Icon Hex | Border Hex | Example Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Critical** | `#FEF2F2` | `#DC2626` | `#FCA5A5` | Safety alerts, outage notices, CRITICAL issues |
| **High** | `#FFF7ED` | `#EA580C` | `#FDBA74` | Equipment failure in exam hall, queue next-in-line |
| **Medium** | `#FEFCE8` | `#CA8A04` | `#FDE047` | Routine maintenance, medium priority notices |
| **Low / Neutral** | `#F1F5F9` | `#475569` | `#CBD5E1` | General notices, informational updates |
| **Assigned / Info** | `#EFF6FF` | `#2563EB` | `#BFDBFE` | Issue assigned to technician, in progress |
| **Success / Resolved** | `#ECFDF5` | `#059669` | `#6EE7B7` | Issue resolved, lost item recovered, queue served |

---

## 3. Typography Scale

Standardized on Google Font **Inter** (clean, geometric, highly legible across mobile and desktop displays):

| Style Role | Font Weight | Mobile Size / Line-Height | Desktop Size / Line-Height | Tracking |
| :--- | :--- | :--- | :--- | :--- |
| **Display / Page Title** | Bold (700) | `24px` / `32px` | `28px` / `36px` | `-0.02em` |
| **Section Header (H2)** | SemiBold (600) | `18px` / `24px` | `20px` / `28px` | `-0.01em` |
| **Card Header (H3)** | SemiBold (600) | `16px` / `22px` | `16px` / `22px` | `0em` |
| **Body Primary** | Regular (400) | `14px` / `20px` | `14px` / `20px` | `0em` |
| **Body Medium (Emphasized)**| Medium (500) | `14px` / `20px` | `14px` / `20px` | `0em` |
| **Subtext / Meta** | Regular (400) | `12px` / `16px` | `12px` / `16px` | `+0.01em` |
| **Badge / Button Label** | SemiBold (600) | `12px` / `16px` | `13px` / `18px` | `+0.02em` |

---

## 4. Spacing & Grid System

Consistent 4px/8px incremental spacing scale:
- `spacing-xxs`: `4px`
- `spacing-xs`: `8px`
- `spacing-sm`: `12px`
- `spacing-md`: `16px` (Standard screen padding on mobile)
- `spacing-lg`: `24px`
- `spacing-xl`: `32px`
- `spacing-xxl`: `48px`

### Breakpoints & Layout Adapters
- **Mobile Handset (`< 600px`):** Single column, 16px horizontal page margins, Bottom Navigation Bar.
- **Tablet / Small Laptop (`600px - 1024px`):** 2-column adaptive layout, 24px margins, Collapsible Navigation Drawer.
- **Desktop (`> 1024px`):** Multi-column dashboard grid, 32px margins, Persistent Left Sidebar Navigation (260px fixed width).

---

## 5. UI Component Specifications

### 5.1 Buttons
1. **Primary Button:**
   - Background: `color-primary` (`#1E3A8A`), Text: White, Corner Radius: `10px`, Min Height: `48px` (touch-target compliance).
   - State: Hover `#1E40AF`, Active `#172554`, Disabled `#94A3B8`.
2. **Secondary / Outlined Button:**
   - Background: `transparent`, Border: `1.5px solid color-border` (`#E2E8F0`), Text: `color-primary`.
   - Hover: Background `#F8FAFC`.
3. **Destructive / Danger Button:**
   - Background: `#DC2626`, Text: White, Corner Radius: `10px`.
4. **Icon Button:**
   - Circular or rounded square (`44px` x `44px` touch target), centered icon (`20px`).

### 5.2 Cards & Containers
- Background: `#FFFFFF`, Border: `1px solid #E2E8F0`, Radius: `12px`.
- Padding: `16px` internal padding.
- Interactive Cards: Tap feedback with ink ripple (mobile) or subtle 2px transform / hover border `#3B82F6` (desktop).

### 5.3 Form Inputs
- **Text Field / Dropdown:**
  - Height: `48px`.
  - Border: `1.5px solid #CBD5E1`. On focus: `2px solid #3B82F6`.
  - Background: `#FFFFFF`.
  - Label: Floating or static top label in `12px` SemiBold (`#475569`).
  - Helper / Error Text: `12px` displayed below field (`#DC2626` on validation failure).
- **Category Chips / Selectors:**
  - Pill shape, border `1px solid #E2E8F0`.
  - Selected state: Background `#EFF6FF`, Border `#3B82F6`, Text `#1E3A8A` + Checkmark icon.

### 5.4 Stepper / Progress Bar (For CampusFix & Verification)
- Horizontal stepper for mobile cards; vertical detailed stepper for detail screens.
- **Completed Step:** Solid filled circle with checkmark (`#059669`).
- **Current Step:** Pulsing or solid blue circle with number (`#2563EB`).
- **Upcoming Step:** Muted outline circle (`#CBD5E1`).
- Connecting lines: Solid `2px` colored for finished transitions, dashed for future transitions.

### 5.5 Status Badges & Priority Indicators
Each badge must have:
1. Container pill with rounded radius (`999px`).
2. Padding: `4px 10px`.
3. Leading Icon (`14px` x `14px`).
4. Typography: `12px` SemiBold uppercase/titlecase.

*Examples:*
- `[🔴 CRITICAL]` — Background `#FEF2F2`, Text `#DC2626`, Icon: `warning_rounded`
- `[🟠 HIGH]` — Background `#FFF7ED`, Text `#EA580C`, Icon: `error_outline_rounded`
- `[🟡 MEDIUM]` — Background `#FEFCE8`, Text `#CA8A04`, Icon: `info_outline_rounded`
- `[🔵 ASSIGNED]` — Background `#EFF6FF`, Text `#2563EB`, Icon: `person_rounded`
- `[🟢 RESOLVED]` — Background `#ECFDF5`, Text `#059669`, Icon: `check_circle_rounded`

---

## 6. Icons
Standardized on **Material Icons (Rounded)**:
- Home: `dashboard_rounded`
- Lost & Found: `search_rounded` / `inventory_2_rounded`
- CampusFix: `build_circle_rounded` / `report_problem_rounded`
- Queue: `hourglass_top_rounded` / `confirmation_number_rounded`
- Notices: `campaign_rounded` / `notifications_active_rounded`
- My Activity: `history_toggle_off_rounded` / `timeline_rounded`
- Admin: `admin_panel_settings_rounded`
- Camera / Upload: `photo_camera_rounded` / `cloud_upload_rounded`

---

## 7. Accessibility (a11y) Standards

- **Contrast Ratios:** Minimum `4.5:1` contrast for body text against backgrounds, and `3:1` for UI components and headers (meets WCAG AA).
- **Minimum Touch Targets:** All interactive buttons, chips, and links must have a minimum bounding box of `48px` x `48px` on touch screens.
- **Screen Reader Semantics:**
  - Steppers announced with `Step X of Y: Status`.
  - Badges announce severity level: `"Priority: Critical"`.
- **Keyboard Navigation (Web):**
  - Logical tab order on all forms.
  - Visible focus ring (`2px solid #3B82F6` with `2px offset`) on all interactive elements.
