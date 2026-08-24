import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/clutter_state_loader.dart';

void main() {
  const loader = ClutterStateLoader();

  test('parses a JSON object of named clutter states', () {
    const source = '''
    {
      "pristine": [],
      "messy": [
        { "layer": "entropy", "sprite": "garbage_bag", "anchor": "floor" }
      ]
    }
    ''';

    final result = loader.parseClutterStates(source);

    expect(result['pristine'], isEmpty);
    expect(result['messy'], hasLength(1));
    expect(result['messy']!.first.layer, 'entropy');
    expect(result['messy']!.first.sprite, 'garbage_bag');
    expect(result['messy']!.first.anchor, 'floor');
  });

  test('loadClutterStates reads and parses the real content file', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final result = await loader.loadClutterStates();

    expect(result.containsKey('pristine'), isTrue);
    expect(result.containsKey('messy'), isTrue);
    expect(result['messy']!.single.sprite, 'garbage_bag');
  });
}
