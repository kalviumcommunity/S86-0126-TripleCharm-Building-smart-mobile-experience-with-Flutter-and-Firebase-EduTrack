import 'package:flutter/material.dart';

class RotateLogoDemo extends StatefulWidget {
  const RotateLogoDemo({super.key});

  @override
  State<RotateLogoDemo> createState() => _RotateLogoDemoState();
}

class _RotateLogoDemoState extends State<RotateLogoDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explicit Animation Demo')),
      body: Center(
        child: RotationTransition(
          turns: _controller,
          child: const FlutterLogo(size: 120),
        ),
      ),
    );
  }
}
