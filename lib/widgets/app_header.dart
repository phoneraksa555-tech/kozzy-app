import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/shop_provider.dart';
import '../screens/cart_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final VoidCallback? onNotificationTap;

  const AppHeader({
    super.key,
    this.title = 'KOZZY.',
    this.showSearch = true,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 5);

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final cartCount = shop.getCartCount();

    return AppBar(
      titleSpacing: 16,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: 1.2,
          color: AppConstants.brandBlack,
        ),
      ),
      actions: [
        if (showSearch)
          IconButton(
            icon: Icon(
              shop.showSearch ? Icons.close : Icons.search,
              color: AppConstants.brandBlack,
              size: 24,
            ),
            onPressed: () => shop.toggleSearch(),
          ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: AppConstants.brandBlack, size: 24),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
