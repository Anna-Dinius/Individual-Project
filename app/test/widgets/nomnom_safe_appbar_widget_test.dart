import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/nomnom_appbar.dart';

void main() {
  testWidgets('NomnomAppBar shows title and has preferredSize', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: NomnomAppBar(title: 'T')),
      ),
    );
    expect(find.text('T'), findsOneWidget);
    final appBar = NomnomAppBar();
    expect(appBar.preferredSize.height, kToolbarHeight);
  });
}
