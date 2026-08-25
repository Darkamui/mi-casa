import 'package:flame/components.dart';

import '../components/restoration_effect_component.dart';

class EffectsLayer extends PositionComponent {
  EffectsLayer({required this.restorationEffect}) {
    add(restorationEffect);
  }

  final RestorationEffectComponent restorationEffect;
}
