import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/nav/route_tracker.dart';
import 'package:flutter/material.dart';

void main() {
  test('routeObserver is a RouteObserver and currentRouteName can be set', () {
    expect(routeObserver, isA<RouteObserver<PageRoute>>());
    // default currentRouteName is null
    expect(currentRouteName, isNull);

    // set and read
    currentRouteName = '/test-route';
    expect(currentRouteName, '/test-route');

    // reset
    currentRouteName = null;
    expect(currentRouteName, isNull);
  });
}
