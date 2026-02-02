import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final bool outline;
  final Color? foregroundColor;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = Colors.teal,
    this.icon,
    this.outline = false,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.circle_outlined),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? color,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.check_circle_outline),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }
}
