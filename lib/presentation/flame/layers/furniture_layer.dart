import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Fridge, stove, cabinets, sink, shelves.
class FurnitureLayer extends PositionComponent {
  FurnitureLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
