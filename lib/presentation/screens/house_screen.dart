import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../simulation/models/room_type_definition.dart';
import '../house/house_providers.dart';
import '../scenes/kitchen_scene_controller.dart' show databaseProvider;
import 'kitchen_screen.dart';

/// The house hub (room selection), reached only after "Enter House" on the
/// title screen (spec §2.3 step 1a). Room availability is content-driven -
/// unlocking a room later is a `content/rooms/room_types.json` edit, never
/// a code change here.
class HouseScreen extends ConsumerWidget {
  const HouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomTypes = ref.watch(roomTypesProvider);
    final household = ref.watch(householdProvider).valueOrNull;
    final name = (household?.name?.trim().isNotEmpty ?? false)
        ? household!.name!
        : 'My Home';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B22),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _renameHousehold(context, ref, household?.name),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: switch (roomTypes) {
                AsyncData(value: final types) => _tiles(types),
                AsyncError(:final error) => Center(
                    child: Text(
                      'Could not load rooms.\n$error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tiles(List<RoomTypeDefinition> types) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(24),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [for (final type in types) _RoomTile(type: type)],
    );
  }

  Future<void> _renameHousehold(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final controller = TextEditingController(text: current ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name your home'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final trimmed = result.trim();
    await ref
        .read(databaseProvider)
        .householdDao
        .setName(trimmed.isEmpty ? null : trimmed);
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.type});

  final RoomTypeDefinition type;

  @override
  Widget build(BuildContext context) {
    final locked = !type.available;
    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: Material(
        color: const Color(0xFF2A2530),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: locked ? null : () => _open(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  locked ? Icons.lock_outline : _iconFor(type.id),
                  color: Colors.white70,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(type.name, style: const TextStyle(color: Colors.white)),
                if (locked) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Coming soon',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String id) => switch (id) {
        'kitchen' => Icons.kitchen_outlined,
        _ => Icons.door_front_door_outlined,
      };

  void _open(BuildContext context) {
    if (type.id != 'kitchen') return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KitchenScreen()),
    );
  }
}
