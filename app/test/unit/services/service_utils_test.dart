import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nomnom_safe/services/service_utils.dart';

class DummyService {}

void main() {
  testWidgets('service_utils getService returns provided instance', (
    tester,
  ) async {
    final dummy = DummyService();
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<DummyService>.value(
          value: dummy,
          child: Builder(
            builder: (context) {
              final got = getService<DummyService>(context);
              return Text(got == dummy ? 'ok' : 'bad');
            },
          ),
        ),
      ),
    );

    expect(find.text('ok'), findsOneWidget);
  });
}
