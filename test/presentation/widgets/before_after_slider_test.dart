import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/before_after_slider.dart';

/// A real 1x1 PNG - the slider has to be able to decode what it is handed.
final _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
  'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

// The same image behind two distinct providers: nothing here inspects the
// pixels, it only has to keep the two sides apart.
final _before = MemoryImage(_pixel);
final _after = MemoryImage(_pixel, scale: 2);

Widget _host() => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: BeforeAfterSlider(before: _before, after: _after),
          ),
        ),
      ),
    );

/// How much of the "before" is showing, 0..1 - measured off the laid-out
/// clip rather than read from a field, because the bug this guards against
/// was a widget quietly ignoring the fraction it was given.
double _split(WidgetTester tester) =>
    tester.getSize(find.byType(ClipRect)).width /
    tester.getSize(find.byType(BeforeAfterSlider)).width;

void main() {
  group('the two-image slider (spec 2.4)', () {
    testWidgets('shows both photographs at once', (tester) async {
      await tester.pumpWidget(_host());

      final images = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => image.image)
          .toList();

      expect(images, containsAll(<Object>[_before, _after]));
    });

    testWidgets('both photographs actually take up space', (tester) async {
      await tester.pumpWidget(_host());

      // Being in the tree is not enough: the "before" was there all along,
      // drawn at full width on top of the "after", which reads as one photo.
      final split = _split(tester);
      expect(split, greaterThan(0.0));
      expect(split, lessThan(1.0));
    });

    testWidgets('opens with the after taking the larger share',
        (tester) async {
      await tester.pumpWidget(_host());

      // The run just ended. The room is the reward, so it is what you see.
      expect(_split(tester), lessThan(0.5));
    });

    testWidgets('dragging moves the divider', (tester) async {
      await tester.pumpWidget(_host());
      final opening = _split(tester);

      await tester.drag(find.byType(BeforeAfterSlider), const Offset(120, 0));
      await tester.pump();

      expect(_split(tester), greaterThan(opening));
    });

    testWidgets('the divider stops at the edges', (tester) async {
      await tester.pumpWidget(_host());

      await tester.drag(find.byType(BeforeAfterSlider), const Offset(9999, 0));
      await tester.pump();
      expect(_split(tester), 1.0);

      await tester.drag(find.byType(BeforeAfterSlider), const Offset(-9999, 0));
      await tester.pump();
      expect(_split(tester), 0.0);
    });

    testWidgets('it says which side is which and nothing else',
        (tester) async {
      await tester.pumpWidget(_host());

      expect(find.text('BEFORE'), findsOneWidget);
      expect(find.text('AFTER'), findsOneWidget);

      // No score, no rating, no verdict on the work. The whole force of the
      // mechanic is that the app makes no claim here (§2.4).
      for (final word in ['%', 'Great', 'Nice', 'Score', 'points']) {
        expect(
          find.textContaining(word, findRichText: true),
          findsNothing,
          reason: 'the slider must not grade the room',
        );
      }
    });
  });
}
