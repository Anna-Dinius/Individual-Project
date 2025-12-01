import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

void main() {
  test('AppRoutes values are correct', () {
    expect(AppRoutes.home, '/home');
    expect(AppRoutes.menu, '/menu');
    expect(AppRoutes.restaurant, '/restaurant');
    expect(AppRoutes.signIn, '/sign-in');
    expect(AppRoutes.signUp, '/sign-up');
    expect(AppRoutes.profile, '/profile');
    expect(AppRoutes.editProfile, '/edit-profile');
  });
}
