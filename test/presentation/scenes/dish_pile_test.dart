import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/dish_pile.dart';

void main() {
  testWidgets('renders the dish pile prop', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DishPile()));
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    final assetImage = image.image as AssetImage;
    expect(assetImage.assetName, 'content/art/props/dish_pile.png');
  });
}
