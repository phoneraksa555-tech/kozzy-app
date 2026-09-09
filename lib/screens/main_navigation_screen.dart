import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/shop_provider.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/profile_drawer.dart';
import '../widgets/shop_menu_drawer.dart';
import 'collection_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final wishCount = shop.wishlist.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          CollectionScreen(showBack: false, showSiteHeader: false, openSearch: true),
          MenuScreen(),
          WishlistScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              activeIcon: Icon(Icons.menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: _badge(Icons.bookmark_border, wishCount),
              activeIcon: _badge(Icons.bookmark, wishCount),
              label: 'Wishlist',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          top: -4,
          right: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: const BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class ShopOverlayHost extends StatelessWidget {
  final Widget? child;

  const ShopOverlayHost({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Stack(
      fit: StackFit.expand,
      children: [
        child ?? const SizedBox.shrink(),
        if (shop.showMenuDrawer) const Positioned.fill(child: ShopMenuDrawer()),
        if (shop.showCartDrawer) const Positioned.fill(child: CartDrawer()),
        if (shop.showProfileDrawer) const Positioned.fill(child: ProfileDrawer()),
      ],
    );
  }
}
