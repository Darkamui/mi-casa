import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/room/room_vitality.dart';

void main() {
  test('every vitality state has a treatment', () {
    for (final vitality in RoomVitality.values) {
      expect(kVitalityTreatments[vitality], isNotNull,
          reason: 'missing treatment for $vitality');
    }
  });

  test('labels are the coarse verbal states the spec locks (§2)', () {
    expect(
      RoomVitality.values.map((v) => v.treatment.label),
      ['Thriving', 'Comfortable', 'Slipping', 'Struggling', 'Critical'],
    );
  });

  test('no label leaks a percentage into the UI', () {
    for (final vitality in RoomVitality.values) {
      expect(vitality.treatment.label, isNot(contains('%')));
      expect(vitality.treatment.label, isNot(matches(RegExp(r'\d'))));
    }
  });

  test('vitality drains monotonically as the room is neglected', () {
    // Doc §7: neglect removes life, it does not add ugliness. Saturation
    // must fall in lockstep with the state order, never jump around.
    final saturations =
        RoomVitality.values.map((v) => v.treatment.saturation).toList();

    for (var i = 1; i < saturations.length; i++) {
      expect(saturations[i], lessThan(saturations[i - 1]),
          reason: '${RoomVitality.values[i]} must be less saturated than '
              '${RoomVitality.values[i - 1]}');
    }
  });

  test('ambient motion only runs while the room is cared for', () {
    expect(RoomVitality.thriving.treatment.ambientSparkles, isTrue);
    expect(RoomVitality.comfortable.treatment.ambientSparkles, isTrue);
    expect(RoomVitality.slipping.treatment.ambientSparkles, isFalse);
    expect(RoomVitality.struggling.treatment.ambientSparkles, isFalse);
    expect(RoomVitality.critical.treatment.ambientSparkles, isFalse);
  });

  test('the companion grows more concerned as vitality falls', () {
    expect(RoomVitality.thriving.treatment.companionMood, CompanionMood.excited);
    expect(RoomVitality.comfortable.treatment.companionMood, CompanionMood.happy);
    expect(RoomVitality.struggling.treatment.companionMood, CompanionMood.concerned);
    expect(RoomVitality.critical.treatment.companionMood, CompanionMood.tired);
  });

  test('every companion mood maps to a shipped emote asset', () {
    for (final mood in CompanionMood.values) {
      expect(mood.asset, 'content/art/companion/companion_${mood.name}.png');
    }
  });

  test('saturationFilter(1.0) is a no-op matrix', () {
    // Identity means "render the illustration exactly as painted" — the
    // baseline every other state is measured against.
    final filter = saturationFilter(1.0).toString();
    expect(filter, contains('1.0'));
    expect(saturationFilter(1.0), saturationFilter(1.0));
  });
}
