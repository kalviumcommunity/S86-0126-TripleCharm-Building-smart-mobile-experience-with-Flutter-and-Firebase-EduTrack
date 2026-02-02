# Assets Setup — EduTrack

This file documents the asset setup and quick verification steps for the EduTrack project.

1) Folders (create under project root):

  - assets/images/
    - logo.png (app logo)
    - background.png (optional banner/background)
  - assets/icons/
    - profile.png (optional)

2) Register assets in `pubspec.yaml` (already done):

```
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

3) Use assets in code:

Image.asset('assets/images/logo.png', width: 120, height: 120);

4) Quick run & test commands:

```bash
cd edutrack
flutter pub get
flutter run -d chrome    # or flutter run -d windows (requires Developer Mode on Windows)
```

5) Troubleshooting:

- If images do not appear, confirm files exist and run `flutter pub get`.
- On Windows, enable Developer Mode for symlink support: `start ms-settings:developers`.

6) Notes

- `lib/screens/asset_demo.dart` uses a graceful fallback if assets are not present.
- After adding assets, capture screenshots and place them in the project for the PR.
