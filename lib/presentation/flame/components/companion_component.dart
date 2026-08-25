import 'package:flame/components.dart';
import 'package:flame/events.dart';

enum CompanionMood { idle, celebrating }

/// Flame version of the companion — participates in depth-sort and
/// parallax like parent-doc §24 requires ("positioned within the Flame
/// world"). Bottom-center pivot, per §24.
class CompanionComponent extends SpriteComponent with TapCallbacks {
  CompanionComponent({
    required Sprite idleSprite,
    required Sprite celebratingSprite,
    required Vector2 position,
    required this.onTap,
    CompanionMood mood = CompanionMood.idle,
  })  : _idleSprite = idleSprite,
        _celebratingSprite = celebratingSprite,
        _mood = mood,
        super(
          sprite: mood == CompanionMood.celebrating ? celebratingSprite : idleSprite,
          position: position,
          size: idleSprite.srcSize,
          anchor: Anchor.bottomCenter,
        );

  final Sprite _idleSprite;
  final Sprite _celebratingSprite;
  final void Function() onTap;
  CompanionMood _mood;

  CompanionMood get mood => _mood;

  set mood(CompanionMood value) {
    _mood = value;
    sprite = value == CompanionMood.celebrating ? _celebratingSprite : _idleSprite;
  }

  static Future<CompanionComponent> load({
    required Vector2 position,
    required void Function() onTap,
  }) async {
    final idle = await Sprite.load('content/art/companion/companion_idle.png');
    final celebrating =
        await Sprite.load('content/art/companion/companion_excited.png');
    return CompanionComponent(
      idleSprite: idle,
      celebratingSprite: celebrating,
      position: position,
      onTap: onTap,
    );
  }

  double get floorY => position.y;

  @override
  void onTapUp(TapUpEvent event) => onTap();
}
