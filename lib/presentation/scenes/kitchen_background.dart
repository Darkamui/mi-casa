import 'package:flutter/material.dart';

class KitchenBackground extends StatelessWidget {
  const KitchenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'content/art/kitchen/kitchen_structure.png',
      fit: BoxFit.cover,
    );
  }
}
