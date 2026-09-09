import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/site_assets.dart';
import '../providers/shop_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/collection_screen.dart';

class AppTopBar extends StatelessWidget {
  final bool showLogo;
  final bool showBack;
  final String title;
  final VoidCallback? onBellTap;

  const AppTopBar({
    super.key,
    this.showLogo = true,
    this.showBack = false,
    this.title = '',
    this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final cartCount = shop.getCartCount();

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                  )
                else if (showLogo)
                  IconButton(
                    onPressed: onBellTap ??
                        () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => const _NotificationsSheet(),
                          );
                        },
                    icon: const Icon(Icons.notifications_none, size: 24, color: Colors.black),
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: showLogo
                        ? Image.asset(
                            SiteAssets.logo,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) => const Text(
                              'KOZZY',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: 1.4,
                              ),
                            ),
                          )
                        : Text(
                            title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined, size: 24, color: Colors.black),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShippingBanner extends StatelessWidget {
  const ShippingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final threshold = context.watch<ShopProvider>().freeShippingThreshold;
    final label = threshold >= 200
        ? 'FREE SHIPPING UP TO \$${threshold.toStringAsFixed(0)}+'
        : 'FREE SHIPPING ON ORDERS OVER \$${threshold.toStringAsFixed(0)}';
    return Container(
      width: double.infinity,
      color: const Color(0xFFEEEEEE),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Colors.black, child: Text('⚡', style: TextStyle(fontSize: 16))),
              title: const Text('New In Collection Drop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Discover the freshest arrivals and street styles.'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CollectionScreen(initialFilter: 'new_in')),
                );
              },
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Color(0xFFF3F4F6), child: Icon(Icons.local_shipping_outlined, color: Colors.black)),
              title: Text('Fast Shipping Available', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text('Kozzy Express · 7:00 AM – 5:00 PM'),
            ),
          ],
        ),
      ),
    );
  }
}
