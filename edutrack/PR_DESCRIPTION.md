# Using Provider or Riverpod for Scalable State Management

As apps grow, managing state across multiple screens becomes challenging. Passing data through constructors or relying on `setState` alone quickly becomes unmanageable. To build scalable Flutter applications, we use state management solutions such as Provider or Riverpod. These allow global state to be shared, updated, listened to, and consumed from anywhere in the app without tight coupling or messy code.

This lesson will guide you through setting up Provider or Riverpod, creating reactive state objects, updating shared state, and using this state across multiple screens.

## 1. Why Scalable State Management Matters

- Eliminates prop drilling across screens.
- Makes UI reactive and automatically updates on data changes.
- Helps structure clean architecture with separation of UI, state, and logic.
- Essential for larger apps with authentication, shopping carts, settings, dashboards, and more.
- Reduces boilerplate and improves testability.

## Option A: Using Provider (Most Common Beginner Choice)

### 2. Add Dependency

```yaml
dependencies:
	provider: ^latest
```

### 3. Create a State Class

```dart
class CounterState with ChangeNotifier {
	int count = 0;

	void increment() {
		count++;
		notifyListeners();
	}
}
```

### 4. Register Provider at App Root

```dart
void main() {
	runApp(
		ChangeNotifierProvider(
			create: (_) => CounterState(),
			child: const MyApp(),
		),
	);
}
```

### 5. Reading and Updating State in UI

Reading:

```dart
final counter = context.watch<CounterState>();
Text("Count: ${counter.count}");
```

Updating:

```dart
context.read<CounterState>().increment();
```

This triggers UI rebuilds automatically.

## Option B: Using Riverpod (Advanced, More Scalable Choice)

### 6. Add Dependency

```yaml
dependencies:
	flutter_riverpod: ^latest
```

### 7. Create a StateProvider

```dart
final counterProvider = StateProvider<int>((ref) => 0);
```

### 8. Wrap App With ProviderScope

```dart
void main() {
	runApp(const ProviderScope(child: MyApp()));
}
```

### 9. Reading and Updating State in UI

Read:

```dart
final count = ref.watch(counterProvider);
Text("Count: $count");
```

Update:

```dart
ref.read(counterProvider.notifier).state++;
```

Riverpod ensures immutability and predictable updates.

## 10. Multi-Screen Shared State

Example: A favorites list used across multiple screens.

Provider example:

```dart
class Favorites extends ChangeNotifier {
	final List<String> items = [];

	void addItem(String item) {
		items.add(item);
		notifyListeners();
	}
}
```

Used in screen A:

```dart
context.read<Favorites>().addItem("Book");
```

Read in screen B:

```dart
ListView(
	children: context.watch<Favorites>().items.map(Text.new).toList(),
);
```

Your UI stays in sync everywhere.

## 11. Best Practices

- Never store heavy objects like controllers or contexts in providers.
- Keep business logic in providers, UI logic in widgets.
- Prefer Riverpod for large apps; Provider is better for small or medium apps.
- Break complex state into multiple providers.
- Use immutable patterns and avoid deep widget rebuilding.

## 12. Common Issues and Fixes

| Issue | Cause | Fix |
| --- | --- | --- |
| UI not updating | Forgot `notifyListeners()` or used wrong listener | Use `watch()` and ensure `notifyListeners()` is called |
| Multiple instances of provider | Provider not declared at root | Move provider to highest possible scope |
| Riverpod read or update errors | Wrong read or watch syntax | Use `ref.watch`, `ref.read`, `provider.notifier` correctly |
| Performance drops | Too many rebuilds | Selectively watch only needed values |
