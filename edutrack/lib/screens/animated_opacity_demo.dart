import 'package:flutter/material.dart';

class AnimatedOpacityDemo extends StatefulWidget {
  const AnimatedOpacityDemo({super.key});

  @override
  State<AnimatedOpacityDemo> createState() => _AnimatedOpacityDemoState();
}

class _AnimatedOpacityDemoState extends State<AnimatedOpacityDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedOpacity Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.15,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              child: const FlutterLogo(size: 150),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _visible = !_visible),
              child: Text(_visible ? 'Fade out' : 'Fade in'),
            ),
          ],
        ),
      ),
    );
  }
}
