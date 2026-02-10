# PR: [Sprint-2] Reusable Custom Widgets – Triple Charm

## Summary

This PR introduces a small set of reusable UI components and a responsive demo screen to demonstrate adaptive layouts using `MediaQuery` and `LayoutBuilder`.

Files added:

- `lib/widgets/custom_button.dart` — reusable Elevated/Outlined button with optional icon
- `lib/widgets/info_card.dart` — small Card+ListTile component for consistent info display
- `lib/widgets/like_button.dart` — simple stateful like (favorite) icon
- `lib/widgets/README_WIDGETS.md` — usage examples and reflection
- `lib/screens/responsive_demo.dart` — demo showing `MediaQuery` + `LayoutBuilder`

Files updated:

- `lib/screens/home_screen.dart` — replaced several buttons with `CustomButton`
- `lib/screens/second_screen.dart` — replaced Card with `InfoCard`, added `LikeButton`, replaced buttons with `CustomButton`
- `README.md` — documented new widgets and responsive demo

## How to run

```bash
flutter pub get
flutter run
```

Navigate to Home -> View Widget Demo or Responsive Demo (route `/responsive` or `/demo` depending on app routing).

## Screenshots (placeholders)

- Phone view: `screenshots/responsive-phone.png`  
- Tablet view: `screenshots/responsive-tablet.png`  
- Home screen showing reused `CustomButton`: `screenshots/home-custombutton.png`  
- Second screen showing `InfoCard` & `LikeButton`: `screenshots/second-infocard.png`

Please add the actual screenshot files at `screenshots/` and update this PR accordingly.

## Reflection

- Reusable widgets improve development efficiency by reducing duplication and centralizing style and behavior.
- Challenges: designing small, focused APIs (constructor params) that are flexible without being overly complex.
- Team application: place common UI patterns in `lib/widgets/` and enforce through code reviews; adopt design tokens for colors and sizes.

## Checklist

- [x] Added reusable widgets and demo screen
- [x] Updated screens to reuse components
- [x] Updated README with usage notes
- [ ] Added screenshots (please attach)
- [ ] Recorded 1–2 minute demo video and linked it here: (video link)

## Commit message

`feat: created and reused custom widgets for modular UI design`

---

If you want, I can try to create the GitHub PR now using the `gh` CLI. If `gh` is not installed or you prefer not to authorize it here, please create the PR manually and paste this file as the PR body.
