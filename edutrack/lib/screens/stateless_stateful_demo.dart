import 'package:flutter/material.dart';

class DemoHeader extends StatelessWidget {
  final String title;

  const DemoHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CounterColorWidget extends StatefulWidget {
  const CounterColorWidget({super.key});

  @override
  State<CounterColorWidget> createState() => _CounterColorWidgetState();
}

class _CounterColorWidgetState extends State<CounterColorWidget> {
  int _count = 0;
  bool _darkMode = false;
  Color _iconColor = Colors.blue;

  void _increment() {
    setState(() => _count++);
  }

  void _toggleDark(bool value) {
    setState(() => _darkMode = value);
  }

  void _changeColor() {
    setState(() {
      _iconColor = _iconColor == Colors.blue ? Colors.red : Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = _darkMode ? Colors.grey[900] : Colors.white;
    final fg = _darkMode ? Colors.white : Colors.black;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Count: $_count', style: TextStyle(fontSize: 28, color: fg)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _increment, child: const Text('Increase')),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _changeColor,
                icon: Icon(Icons.favorite, color: _iconColor),
                tooltip: 'Toggle icon color',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Light'),
              Switch(value: _darkMode, onChanged: _toggleDark),
              const Text('Dark'),
            ],
          ),
        ],
      ),
    );
  }
}

class StatelessStatefulDemoScreen extends StatelessWidget {
  const StatelessStatefulDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateless vs Stateful Demo')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              DemoHeader(title: 'Interactive Counter Demo'),
              SizedBox(height: 8),
              CounterColorWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
