import 'package:flutter/material.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

NavigatorState? get appNav => appNavigatorKey.currentState;

Future<T?> appPush<T>(Widget page) {
  final nav = appNav;
  if (nav == null) return Future<T?>.value(null);
  return nav.push<T>(MaterialPageRoute(builder: (_) => page));
}

void appGoHome() {
  appNav?.popUntil((route) => route.isFirst);
}
