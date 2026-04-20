# GG TAXI Design System

Complete reference for UI components, colors, typography, and spacing for GG TAXI.

## 🎨 Color Palette

### Primary Colors
| Color | Hex | Usage |
|-------|-----|-------|
| **Brand Orange** | `#FE8C00` | Buttons, highlights, active states |
| **Orange Dark** | `#E07C00` | Hover/pressed states |
| **Orange Light** | `#FFB84D` | Disabled states, overlays |

### Secondary Colors
| Color | Hex | Usage |
|-------|-----|-------|
| **Green** | `#00A85C` | Success, positive actions |
| **Blue** | `#1F77F3` | Information, links |
| **Red** | `#E53935` | Errors, alerts |
| **Amber** | `#FFA500` | Warnings |

### Neutral Colors
| Color | Hex | Usage |
|-------|-----|-------|
| **Light Background** | `#FAFAFA` | Page backgrounds |
| **Surface** | `#FFFFFF` | Cards, surfaces |
| **Divider** | `#E5E7EB` | Borders, separators |
| **Shadow** | `#1A000000` | Drop shadows |

### Text Colors
| Color | Hex | Usage |
|-------|-----|-------|
| **Primary Text** | `#1F2937` | Headlines, body text |
| **Secondary Text** | `#6B7280` | Descriptions, captions |
| **Tertiary Text** | `#9CA3AF` | Placeholder, helper text |
| **Disabled** | `#D1D5DB` | Disabled states |

## 📝 Typography

### Font Family
- **Primary**: Roboto (Android), SF Pro (iOS)
- **Monospace**: Roboto Mono (for codes/amounts)

### Type Scales

#### Display
```dart
// Display Large
fontSize: 32
fontWeight: 700 (Bold)
letterSpacing: -0.5

// Display Medium
fontSize: 28
fontWeight: 700
letterSpacing: -0.5
```

#### Headlines
```dart
// Headline Large
fontSize: 24
fontWeight: 700

// Headline Medium
fontSize: 20
fontWeight: 600
letterSpacing: 0.15

// Headline Small
fontSize: 18
fontWeight: 600
letterSpacing: 0.15
```

#### Body Text
```dart
// Body Large
fontSize: 16
fontWeight: 400
letterSpacing: 0.5

// Body Medium (default)
fontSize: 14
fontWeight: 400
letterSpacing: 0.25

// Body Small
fontSize: 12
fontWeight: 400
letterSpacing: 0.4
```

#### Labels
```dart
// Label Large (buttons)
fontSize: 14
fontWeight: 500
letterSpacing: 0.1

// Label Medium
fontSize: 12
fontWeight: 500
letterSpacing: 0.5

// Label Small
fontSize: 11
fontWeight: 500
letterSpacing: 0.5
```

## 📐 Spacing & Layout

### Spacing Scale (4px base unit)
```
4px   = 1 unit (xs)
8px   = 2 units (sm)
12px  = 3 units (md)
16px  = 4 units (lg)
24px  = 6 units (xl)
32px  = 8 units (2xl)
48px  = 12 units (3xl)
```

### Common Padding
- **Screen padding**: 16px horizontal, 24px vertical
- **Card padding**: 16px
- **List item padding**: 12px horizontal, 16px vertical
- **Button padding**: 12px vertical, 24px horizontal

### Common Gap
- **Section gap**: 24px
- **Item gap**: 16px
- **Tight gap**: 8px

## 🔲 Corners & Radius

```dart
// Small (chips, tags)
borderRadius: 8dp

// Medium (cards, dialogs)
borderRadius: 12dp

// Large (sheets, containers)
borderRadius: 16dp

// Full circle (avatars)
borderRadius: BorderRadius.circular(999)
```

## 🎯 Components Library

### Buttons

#### Primary Button (Elevated)
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Request Ride'),
)
```
- **Background**: #FE8C00
- **Text**: White
- **Padding**: 12px vertical, 24px horizontal
- **Border Radius**: 12dp
- **Height**: 48px (touch target minimum)

#### Secondary Button (Outlined)
```dart
OutlinedButton(
  onPressed: () {},
  child: Text('Cancel'),
)
```
- **Border**: 1.5px solid #FE8C00
- **Text**: #FE8C00
- **Padding**: Same as primary
- **Border Radius**: 12dp

#### Text Button
```dart
TextButton(
  onPressed: () {},
  child: Text('Learn More'),
)
```
- **Text**: #FE8C00
- **No background**
- **Padding**: 8px vertical, 16px horizontal

### Input Fields

#### Text Input
```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    labelText: 'Phone Number',
    prefixIcon: Icon(Icons.phone),
  ),
)
```
- **Border**: 1px solid #E5E7EB
- **Border Radius**: 12dp
- **Padding**: 12px vertical, 16px horizontal
- **Focus Border**: 2px solid #FE8C00

### Cards

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)
```
- **Background**: #FFFFFF
- **Border Radius**: 12dp
- **Elevation**: 1
- **Padding**: 16px

### List Items

```dart
ListTile(
  leading: CircleAvatar(),
  title: Text('Driver Name'),
  subtitle: Text('5.0 ⭐ • 1,234 rides'),
  trailing: Icon(Icons.arrow_forward),
)
```
- **Height**: 56px minimum
- **Padding**: 12px horizontal

### Bottom Sheet

```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  builder: (context) => Container(...),
)
```
- **Border Radius**: 16dp (top only)
- **Padding**: 24px
- **Background**: #FFFFFF

### Chips / Tags

```dart
Chip(
  label: Text('Economy'),
  avatar: Icon(Icons.directions_car),
)
```
- **Border Radius**: 8dp
- **Padding**: 6px horizontal 12px
- **Background**: Light #FE8C00
- **Text**: #FE8C00

## 🎨 Shadows

### Elevation Levels

```dart
// Level 0: None
elevation: 0

// Level 1: Subtle (cards, lists)
elevation: 1
shadowColor: #1A000000

// Level 2: Medium (dialogs, menus)
elevation: 4
shadowColor: #1A000000

// Level 3: High (floating action buttons, modals)
elevation: 8
shadowColor: #1A000000
```

## 🌊 States

### Hover/Pressed
- **Background**: Darken by 12% (or use `primaryDark`)
- **Opacity**: 0.8

### Disabled
- **Background**: #E5E7EB
- **Text**: #D1D5DB
- **Opacity**: 0.6

### Loading
- **Show spinner**: #FE8C00
- **Spinner size**: 24px

### Error
- **Text color**: #E53935
- **Border color**: #E53935
- **Supporting text**: "This field is required"

## 🎬 Animations

### Timing
- **Fast**: 200ms (button feedback, state changes)
- **Normal**: 300ms (screen transitions)
- **Slow**: 500ms (complex animations)

### Easing
- **Standard**: `Curves.easeInOut`
- **Entrance**: `Curves.easeOut`
- **Exit**: `Curves.easeIn`
- **Elastic**: `Curves.elasticOut`

### Common Animations
- **Button press**: 200ms scale (0.95)
- **Screen transition**: 300ms slide + fade
- **Loading spinner**: Continuous rotation
- **Ride tracking**: Smooth map marker movement

## 📱 Responsive Breakpoints

```dart
// Mobile (< 600dp)
- Single column layouts
- Full-width buttons
- Large touch targets (48dp+)

// Tablet (600-840dp)
- Two-column layouts
- Side-by-side navigation

// Desktop (840dp+)
- Three+ column layouts
- Dense layouts
```

## ♿ Accessibility

### Minimum Touch Targets
- **Buttons**: 48dp × 48dp
- **Icons**: 40dp × 40dp
- **List items**: 56dp height

### Contrast Ratios
- **WCAG AA**: 4.5:1 for text
- **WCAG AAA**: 7:1 for text

### Labels & Hints
- All inputs must have `labelText` or semantic label
- Form fields use `hintText` for examples
- Icons include `semanticLabel` for screen readers

### Colors Not Alone
- Don't convey information through color only
- Use icons, text, or patterns alongside colors

---

## Implementation Guide

All design tokens are defined in `lib/core/theme/app_theme.dart`:

```dart
class AppTheme {
  static const Color primaryColor = Color(0xFFFE8C00);
  static const Color primaryDark = Color(0xFFE07C00);
  // ... rest of colors
  
  static ThemeData lightTheme() {
    return ThemeData(
      // All component themes defined here
    );
  }
}
```

**Usage in widgets**:
```dart
// Use theme colors
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).primaryColor,
  ),
  child: const Text('Book Ride'),
)

// Use typography
Text(
  'Welcome',
  style: Theme.of(context).textTheme.headlineLarge,
)
```

---

**Last Updated**: April 2026  
**Next Review**: October 2026
