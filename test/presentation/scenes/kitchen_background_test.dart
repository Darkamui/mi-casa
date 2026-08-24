import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_background.dart';

void main() {
  testWidgets('renders the kitchen illustration', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: KitchenBackground()));
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    final assetImage = image.image as AssetImage;
    expect(assetImage.assetName, 'content/art/kitchen/kitchen_structure.png');
  });
}
