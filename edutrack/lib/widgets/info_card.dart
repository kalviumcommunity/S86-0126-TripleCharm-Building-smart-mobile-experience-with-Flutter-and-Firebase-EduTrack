import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const InfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 36, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
