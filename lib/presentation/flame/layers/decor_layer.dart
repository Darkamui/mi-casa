import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Plants, rug, jars, pictures.
class DecorLayer extends PositionComponent {
  DecorLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
