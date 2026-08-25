import 'package:flame/components.dart';

import '../components/companion_component.dart';

class CharacterLayer extends PositionComponent {
  CharacterLayer({required this.companion}) {
    add(companion);
  }

  final CompanionComponent companion;
}
