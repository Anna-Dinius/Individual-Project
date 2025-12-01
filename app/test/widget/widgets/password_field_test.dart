import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/password_field.dart';

void main() {
  testWidgets('PasswordField toggles visibility when enabled', (tester) async {
    final controller = TextEditingController();
    var visible = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordField(
            controller: controller,
            label: 'Password',
            isVisible: visible,
            onToggleVisibility: () => visible = !visible,
            enabled: true,
          ),
        ),
      ),
    );

    // Icon for visibility_off should be present initially
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    // Tap the suffix icon to toggle
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pumpAndSettle();

    // After toggle the local variable changed — widget rebuild not triggered here,
    // but we ensure the button existed and was tappable.
    expect(visible, isTrue);
  });

  testWidgets('PasswordField disables toggle when not enabled', (tester) async {
    final controller = TextEditingController();
    var toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordField(
            controller: controller,
            label: 'Password',
            isVisible: false,
            onToggleVisibility: () => toggled = true,
            enabled: false,
          ),
        ),
      ),
    );

    // Button should be present but disabled (onPressed null)
    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton.onPressed, isNull);
  });
}
