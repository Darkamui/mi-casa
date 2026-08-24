import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'kitchen_room.dart';

class KitchenGame extends FlameGame {
  KitchenGame({required this.onCompanionTap})
      : super(
            camera:
                CameraComponent.withFixedResolution(width: 1280, height: 720));

  final void Function() onCompanionTap;

  late final KitchenRoom kitchenRoom;
  late final _DragCaptureComponent _dragCapture;

  @override
  Future<void> onLoad() async {
    // Rendered props live under content/art/rendered/props/, not Flame's
    // default assets/images/ prefix.
    Flame.images.prefix = '';

    kitchenRoom = await KitchenRoom.create(onCompanionTap: onCompanionTap);
    await world.add(kitchenRoom);

    _dragCapture = _DragCaptureComponent(size: Vector2(1280, 720));
    await camera.viewport.add(_dragCapture);
  }

  @override
  void update(double dt) {
    super.update(dt);
    kitchenRoom.applyParallax(_dragCapture.dragOffset);
  }

  /// Test-only seam — see kitchen_game_test.dart for why driving a real
  /// DragUpdateEvent headlessly is avoided.
  void handleDragForTest(Vector2 delta) {
    _dragCapture.dragOffset += delta;
  }
}

/// Screen-fixed (added to camera.viewport, not world) so it captures pan
/// gestures regardless of camera position — parallax reacts to drag, not
/// device tilt.
class _DragCaptureComponent extends PositionComponent with DragCallbacks {
  _DragCaptureComponent({required super.size});

  Vector2 dragOffset = Vector2.zero();

  @override
  void onDragUpdate(DragUpdateEvent event) {
    dragOffset += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) => dragOffset = Vector2.zero();

  @override
  void onDragCancel(DragCancelEvent event) => dragOffset = Vector2.zero();
}
