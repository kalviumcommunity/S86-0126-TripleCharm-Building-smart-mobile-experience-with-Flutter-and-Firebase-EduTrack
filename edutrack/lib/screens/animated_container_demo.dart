import 'package:flutter/material.dart';

class AnimatedContainerDemo extends StatefulWidget {
  const AnimatedContainerDemo({super.key});

  @override
  State<AnimatedContainerDemo> createState() => _AnimatedContainerDemoState();
}

class _AnimatedContainerDemoState extends State<AnimatedContainerDemo> {
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedContainer Demo')),
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() => _toggled = !_toggled),
          child: AnimatedContainer(
            width: _toggled ? 220 : 120,
            height: _toggled ? 120 : 220,
            decoration: BoxDecoration(
              color: _toggled ? Colors.teal : Colors.orange,
              borderRadius: BorderRadius.circular(_toggled ? 24 : 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: const Center(
              child: Text('Tap me', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _toggled = !_toggled),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
