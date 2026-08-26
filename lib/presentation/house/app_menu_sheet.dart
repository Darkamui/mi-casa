import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'house_providers.dart';
import '../scenes/kitchen_scene_controller.dart';
import '../widgets/mute_button.dart';

/// The one settings/menu surface in the app - opened from the title
/// screen's Settings button and from a HUD icon inside [KitchenScreen].
/// [showBackToHouse] is true only when there is a room screen underneath to
/// pop back past.
Future<void> showAppMenuSheet(
  BuildContext context, {
  bool showBackToHouse = false,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1B22),
    builder: (context) => _AppMenuSheet(showBackToHouse: showBackToHouse),
  );
}

class _AppMenuSheet extends ConsumerWidget {
  const _AppMenuSheet({required this.showBackToHouse});

  final bool showBackToHouse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(householdProvider).valueOrNull;
    final momentum =
        ref.watch(kitchenSessionProvider).valueOrNull?.momentum;
    final name = (household?.name?.trim().isNotEmpty ?? false)
        ? household!.name!
        : 'My Home';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                MuteButton(),
                SizedBox(width: 8),
                Text('Sound', style: TextStyle(color: Colors.white70)),
              ],
            ),
            if (momentum != null) ...[
              const SizedBox(height: 16),
              Text(
                'Momentum: $momentum',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (showBackToHouse) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to House'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
