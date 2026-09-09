import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  /// Live Kozzy API. Flutter web on a random localhost port is blocked by
  /// production CORS, so debug web uses the local proxy in tool/cors_proxy.dart.
  static String get backendUrl {
    if (kIsWeb && kDebugMode) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        if (Uri.base.hasPort && Uri.base.port == 8081) {
          return 'https://api.kozzy.online';
        }
        return 'http://127.0.0.1:8099';
      }
    }
    return 'https://api.kozzy.online';
  }
  static const String tokenKey = 'kozzy_token';
  static const String cartKey = 'kozzy_guest_cart';
  static const String wishlistKey = 'kozzy_wishlist';
  static const String addressesKey = 'kozzy_addresses';

  // Brand Colors
  static const Color primaryColor = Color(0xFFC00000);
  static const Color primaryDark = Color(0xFF990000);
  static const Color primaryLight = Color(0xFFFFF1F2);
  static const Color brandBlack = Color(0xFF111827);
  static const Color brandDark = Color(0xFF1F2937);
  static const Color brandGray = Color(0xFF6B7280);
  static const Color brandLightGray = Color(0xFF9CA3AF);
  static const Color brandBorder = Color(0xFFE5E7EB);
  static const Color brandBackground = Color(0xFFF9FAFB);
  static const Color cardColor = Colors.white;

  // Currency
  static const String currency = '\$';
}
