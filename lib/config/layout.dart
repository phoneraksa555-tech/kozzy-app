import 'package:flutter/material.dart';

class SiteLayout {
  static const phone = 640.0;
  static const desktop = 1024.0;

  static bool isPhone(BuildContext context) => MediaQuery.sizeOf(context).width < phone;

  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktop) return const EdgeInsets.symmetric(horizontal: 80);
    if (w >= phone) return const EdgeInsets.symmetric(horizontal: 40);
    return const EdgeInsets.symmetric(horizontal: 8);
  }

  static double railCardWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final inner = w - pagePadding(context).horizontal;
    if (w < phone) return (inner - 6) / 2.38;
    if (w < desktop) return (inner - 12) / 3.2;
    return (inner - 24) / 4.2;
  }

  static int collectionColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktop) return 4;
    if (w >= phone) return 3;
    return 2;
  }
}
