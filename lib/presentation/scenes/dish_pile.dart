import 'package:flutter/material.dart';

class DishPile extends StatelessWidget {
  const DishPile({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'content/art/props/dish_pile.png',
      fit: BoxFit.contain,
    );
  }
}
