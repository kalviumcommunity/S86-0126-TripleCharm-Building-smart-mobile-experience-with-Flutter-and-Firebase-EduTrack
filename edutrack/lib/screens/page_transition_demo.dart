import 'package:flutter/material.dart';

class PageTransitionDemo extends StatelessWidget {
  const PageTransitionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Transition Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              pageBuilder: (context, animation, secondaryAnimation) => const _SecondPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final tween = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOut));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ));
          },
          child: const Text('Go to next page with slide'),
        ),
      ),
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This page arrived with a slide transition.'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
