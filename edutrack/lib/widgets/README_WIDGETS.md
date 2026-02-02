# Reusable Widgets

This folder contains small, reusable widgets used across the EduTrack demo.

Widgets included:

- `CustomButton` — a single button component that can render as an Elevated or Outlined button with an optional icon.
- `InfoCard` — a simple `Card` + `ListTile` widget for displaying a title, subtitle and icon.
- `LikeButton` — a small stateful heart icon that toggles between liked/unliked.

Example usage (in a screen):

```dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/info_card.dart';

// inside build()
CustomButton(
  label: 'Go to Second Screen',
  icon: Icons.arrow_forward,
  color: const Color(0xFF6C63FF),
  onPressed: () => Navigator.pushNamed(context, '/second'),
),

InfoCard(
  title: 'Navigation Stack Info',
  subtitle: 'This screen was pushed onto the navigation stack.',
  icon: Icons.info_outline,
),
```

Reflection

- Reusable widgets reduce duplication and make consistent styling easy to enforce.
- Designing small, focused APIs (clear constructor params) helps adoption across screens.
