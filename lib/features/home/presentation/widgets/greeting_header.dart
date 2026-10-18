import 'package:flutter/material.dart';

/// "Hi, $USER 👋"
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hi, $username 👋',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
    );
  }
}
