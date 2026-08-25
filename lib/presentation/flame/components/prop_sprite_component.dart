import 'package:flame/components.dart';

enum PropPivot { floorContact, verticalCenter }

/// Generic pivot-aware sprite wrapper — every furniture/decor/entropy
/// sprite in the kitchen is one of these. `floorContact` (default) anchors
/// bottom-center, matching Spec A's floor-contact pivot convention.
/// `verticalCenter` anchors center, for wall-mounted assets (window,
/// curtain, picture).
class PropSpriteComponent extends SpriteComponent {
  PropSpriteComponent({
    required Sprite sprite,
    required Vector2 position,
    this.pivot = PropPivot.floorContact,
  }) : super(
          sprite: sprite,
          position: position,
          size: sprite.srcSize,
          anchor: pivot == PropPivot.floorContact
              ? Anchor.bottomCenter
              : Anchor.center,
        );

  final PropPivot pivot;

  static Future<PropSpriteComponent> load({
    required String assetPath,
    required Vector2 position,
    PropPivot pivot = PropPivot.floorContact,
  }) async {
    final sprite = await Sprite.load(assetPath);
    return PropSpriteComponent(sprite: sprite, position: position, pivot: pivot);
  }

  /// The prop's floor-contact Y in world space, for depth sorting
  /// (depth_sort.dart) regardless of pivot mode.
  double get floorY => pivot == PropPivot.floorContact
      ? position.y
      : position.y + size.y / 2;
}
