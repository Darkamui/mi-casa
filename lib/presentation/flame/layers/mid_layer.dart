import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Island, table, stools.
class MidLayer extends PositionComponent {
  MidLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
