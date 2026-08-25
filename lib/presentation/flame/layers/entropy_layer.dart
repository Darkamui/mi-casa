import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Dishes, mug, crumbs, trash — driven by the scripted clutter state.
/// The only mutable layer in Phase 0: setProps swaps its whole content in
/// one call, matching the scripted demo's "completion clears everything
/// at once" behavior (spec §8).
class EntropyLayer extends PositionComponent {
  EntropyLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }

  Future<void> setProps(List<PropSpriteComponent> props) async {
    removeAll(children.toList());
    addAll(props);
  }
}
