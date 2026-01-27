# Stateless vs Stateful Widgets — Demo

Project Title: Stateless vs Stateful Widgets Demo

Short description:
This small demo demonstrates the difference between `StatelessWidget` and `StatefulWidget` in Flutter. It includes a static header (stateless) and an interactive area (stateful) that increments a counter, toggles a dark mode, and changes an icon color.

What to run:
- From the project root (`edutrack`), run:

```bash
flutter pub get
flutter run -d chrome
```

Then navigate to the route `/demo` in the running app or open the screen programmatically by navigating to `StatelessStatefulDemoScreen`.

Explanation:
- `DemoHeader` (Stateless): Displays a static title. It does not manage any internal state and will only rebuild if its parent provides new parameters.
- `CounterColorWidget` (Stateful): Maintains `_count`, `_darkMode`, and `_iconColor` state variables. Uses `setState()` to update the UI when these values change.

Core code snippets (see `lib/screens/stateless_stateful_demo.dart`):

Stateless header example:

```dart
class DemoHeader extends StatelessWidget {
  final String title;
  const DemoHeader({super.key, required this.title});
  @override Widget build(BuildContext context) => Text(title);
}
```

Stateful interactive example:

```dart
class CounterColorWidget extends StatefulWidget { ... }

class _CounterColorWidgetState extends State<CounterColorWidget> {
  int _count = 0;
  void _increment() => setState(() => _count++);
  @override Widget build(BuildContext context) => Text('Count: \\$_count');
}
```

Screenshots:
- `demo/stateless_initial.png` — initial UI (to add)
- `demo/stateless_after.png` — after increments / toggles (to add)

Reflection:
- Stateful widgets make Flutter apps dynamic by encapsulating mutable state and triggering partial rebuilds via `setState()`.
- Separating static (`StatelessWidget`) and reactive (`StatefulWidget`) parts improves performance, readability, and testability.

Submission notes:
- Commit with message: `feat: implemented demo showing stateless and stateful widgets`
- PR title: `[Sprint-2] Stateless vs Stateful Widgets – TeamName`
