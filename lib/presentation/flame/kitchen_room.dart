import 'package:flame/components.dart';

import 'clutter_state_loader.dart';
import 'components/companion_component.dart';
import 'components/prop_sprite_component.dart';
import 'components/restoration_effect_component.dart';
import 'depth_sort.dart';
import 'layers/back_layer.dart';
import 'layers/character_layer.dart';
import 'layers/decor_layer.dart';
import 'layers/effects_layer.dart';
import 'layers/entropy_layer.dart';
import 'layers/foreground_layer.dart';
import 'layers/furniture_layer.dart';
import 'layers/mid_layer.dart';
import 'parallax_controller.dart';

const String _propsRoot = 'content/art/rendered/props';

/// Fixed placement points clutter entries' `anchor` field resolves
/// against (spec §7). Phase 0 has exactly one room layout, so these are
/// hardcoded rather than data-driven.
Vector2 anchorPosition(String anchor) {
  switch (anchor) {
    case 'floor':
      return Vector2(1080, 660);
    default:
      throw ArgumentError('Unknown clutter anchor: $anchor');
  }
}

/// Root component for the kitchen diorama — builds the 8 layers as
/// children, in order (spec §6).
class KitchenRoom extends PositionComponent {
  KitchenRoom._({
    required this.backLayer,
    required this.furnitureLayer,
    required this.midLayer,
    required this.decorLayer,
    required this.entropyLayer,
    required this.characterLayer,
    required this.effectsLayer,
    required this.foregroundLayer,
    required Map<String, List<ClutterEntry>> clutterStates,
  }) : _clutterStates = clutterStates {
    addAll([
      backLayer,
      furnitureLayer,
      midLayer,
      decorLayer,
      entropyLayer,
      characterLayer,
      effectsLayer,
      foregroundLayer,
    ]);
  }

  final BackLayer backLayer;
  final FurnitureLayer furnitureLayer;
  final MidLayer midLayer;
  final DecorLayer decorLayer;
  final EntropyLayer entropyLayer;
  final CharacterLayer characterLayer;
  final EffectsLayer effectsLayer;
  final ForegroundLayer foregroundLayer;
  final Map<String, List<ClutterEntry>> _clutterStates;

  late final Map<PositionComponent, double> _parallaxRates = {
    backLayer: 0.15,
    furnitureLayer: 0.30,
    midLayer: 0.50,
    decorLayer: 0.50,
    entropyLayer: 0.50,
    characterLayer: 0.65,
    effectsLayer: 0.65,
    foregroundLayer: 0.80,
  };

  static Future<KitchenRoom> create({
    required void Function() onCompanionTap,
  }) async {
    final clutterStates = await const ClutterStateLoader().loadClutterStates();

    final backLayer = BackLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/window/window_000.png',
        position: Vector2(560, 190),
        pivot: PropPivot.verticalCenter,
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/curtain/curtain_000.png',
        position: Vector2(700, 190),
        pivot: PropPivot.verticalCenter,
      ),
    ]);

    final furnitureLayer = FurnitureLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/fridge/fridge_000.png',
        position: Vector2(150, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/stove/stove_000.png',
        position: Vector2(350, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/sink/sink_000.png',
        position: Vector2(550, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/cabinet/cabinet_000.png',
        position: Vector2(750, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/cabinet/cabinet_045.png',
        position: Vector2(900, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/shelf/shelf_000.png',
        position: Vector2(1050, 620),
      ),
    ]);

    final midLayer = MidLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/stool/stool_000.png',
        position: Vector2(650, 660),
      ),
    ]);

    final decorLayer = DecorLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/plant_01/plant_01_000.png',
        position: Vector2(80, 650),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/plant_02/plant_02_000.png',
        position: Vector2(1200, 650),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/rug/rug_000.png',
        position: Vector2(500, 700),
      ),
    ]);

    final entropyLayer = EntropyLayer();

    final companion = await CompanionComponent.load(
      position: Vector2(950, 700),
      onTap: onCompanionTap,
    );
    final characterLayer = CharacterLayer(companion: companion);

    final effectsLayer = EffectsLayer(
      restorationEffect:
          RestorationEffectComponent(position: anchorPosition('floor')),
    );

    final foregroundLayer = ForegroundLayer();

    final room = KitchenRoom._(
      backLayer: backLayer,
      furnitureLayer: furnitureLayer,
      midLayer: midLayer,
      decorLayer: decorLayer,
      entropyLayer: entropyLayer,
      characterLayer: characterLayer,
      effectsLayer: effectsLayer,
      foregroundLayer: foregroundLayer,
      clutterStates: clutterStates,
    );

    room._applyDepthSort();
    // Scripted demo starts non-pristine so there's visible mess to clear
    // (spec §8).
    await room.setClutterState('messy');

    return room;
  }

  void _applyDepthSort() {
    final depthOwners = <PositionComponent>[
      ...furnitureLayer.children.whereType<PositionComponent>(),
      ...midLayer.children.whereType<PositionComponent>(),
      ...decorLayer.children.whereType<PositionComponent>(),
      ...entropyLayer.children.whereType<PositionComponent>(),
      ...characterLayer.children.whereType<PositionComponent>(),
    ];

    final entries = <DepthEntry>[];
    for (var i = 0; i < depthOwners.length; i++) {
      final owner = depthOwners[i];
      final floorY = owner is PropSpriteComponent
          ? owner.floorY
          : (owner as CompanionComponent).floorY;
      entries.add(DepthEntry(id: 'p$i', floorY: floorY));
    }

    final priorities = assignDepthPriorities(entries);
    for (var i = 0; i < depthOwners.length; i++) {
      depthOwners[i].priority = priorities['p$i']!;
    }
  }

  Future<void> setClutterState(String state) async {
    final entries = _clutterStates[state] ?? const [];
    final props = await Future.wait(entries.map(
      (entry) => PropSpriteComponent.load(
        assetPath: '$_propsRoot/${entry.sprite}/${entry.sprite}_000.png',
        position: anchorPosition(entry.anchor),
      ),
    ));
    await entropyLayer.setProps(props);
  }

  /// completeTask -> celebrating (spec §8): clutter clears, restoration
  /// effect fires at the relevant anchor, companion celebrates.
  Future<void> celebrateCompletion() async {
    await setClutterState('pristine');
    effectsLayer.restorationEffect.fire();
    characterLayer.companion.mood = CompanionMood.celebrating;
  }

  void applyParallax(Vector2 dragOffset) {
    for (final entry in _parallaxRates.entries) {
      entry.key.position = computeParallaxOffset(
        dragOffset: dragOffset,
        layerRate: entry.value,
      );
    }
  }
}
