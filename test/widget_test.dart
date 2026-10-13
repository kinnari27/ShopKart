import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_kart/core/widgets/app_empty_state.dart';

void main() {
  testWidgets('AppEmptyState displays title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            title: 'No items',
            message: 'Your list is currently empty.',
          ),
        ),
      ),
    );

    expect(find.text('No items'), findsOneWidget);
    expect(find.text('Your list is currently empty.'), findsOneWidget);
  });
}
