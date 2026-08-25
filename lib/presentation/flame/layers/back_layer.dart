import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Wall, window, curtain — parent-doc §14/§15. The wall itself is a plain
/// painted background handled at the screen level (no rendered wall
/// sprite exists — parent-doc §15 explicitly allows this), so this layer
/// only holds wall-mounted props like window/curtain.
class BackLayer extends PositionComponent {
  BackLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
