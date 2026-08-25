import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/kitchen_screen.dart';

void main() {
  runApp(const ProviderScope(child: MiCasaApp()));
}

class MiCasaApp extends StatelessWidget {
  const MiCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MiCasa',
      debugShowCheckedModeBanner: false,
      home: KitchenScreen(),
    );
  }
}
