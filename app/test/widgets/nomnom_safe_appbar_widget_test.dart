import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/nomnom_safe_appbar.dart';

void main() {
  testWidgets('NomnomSafeAppBar shows title and has preferredSize', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: NomnomSafeAppBar(title: 'T')),
      ),
    );
    expect(find.text('T'), findsOneWidget);
    final appBar = NomnomSafeAppBar();
    expect(appBar.preferredSize.height, kToolbarHeight);
  });
}
