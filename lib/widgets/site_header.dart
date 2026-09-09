import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_navigator.dart';
import '../config/constants.dart';
import '../config/layout.dart';
import '../config/menu_data.dart';
import '../config/site_assets.dart';
import '../providers/shop_provider.dart';
import '../screens/about_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/login_screen.dart';
import 'marquee_bar.dart';

class SiteHeader extends StatelessWidget {
  final bool showBack;

  const SiteHeader({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MarqueeBar(),
          SiteNavbar(showBack: showBack),
          if (!SiteLayout.isPhone(context)) const _DesktopCategoryBar(),
        ],
      ),
    );
  }
}

class SiteNavbar extends StatelessWidget {
  final bool showBack;

  const SiteNavbar({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final cartCount = shop.getCartCount();
    final phone = SiteLayout.isPhone(context);
    final canPop = showBack && (Navigator.maybeOf(context)?.canPop() ?? false);

    Widget logo() {
      return GestureDetector(
        onTap: () {
          shop.closeAllDrawers();
          shop.setActiveDepartment('');
          appGoHome();
        },
        child: Image.asset(
          SiteAssets.logo,
          height: phone ? 14 : 15,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'KOZZY',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2),
          ),
        ),
      );
    }

    Widget iconBtn(IconData icon, VoidCallback onTap) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        icon: Icon(icon, size: phone ? 20 : 18, color: AppConstants.brandBlack),
        onPressed: onTap,
      );
    }

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!phone) ...[
          TextButton(
            onPressed: () => appPush(const AboutScreen()),
            child: const Text('ABOUT', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), letterSpacing: 0.6)),
          ),
          TextButton(
            onPressed: () => appPush(const ContactScreen()),
            child: const Text('CONTACT', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), letterSpacing: 0.6)),
          ),
        ],
        iconBtn(Icons.search, () {
          shop.closeAllDrawers();
          appPush(const CollectionScreen(openSearch: true));
        }),
        iconBtn(Icons.person_outline, () {
          if (!shop.isLoggedIn) {
            appPush(const LoginScreen());
            return;
          }
          shop.openProfileDrawer();
        }),
        Stack(
          clipBehavior: Clip.none,
          children: [
            iconBtn(Icons.shopping_bag_outlined, shop.openCartDrawer),
            if (cartCount > 0)
              Positioned(
                right: 2,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );

    if (!phone) {
      return SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              logo(),
              const Spacer(),
              for (final tab in menuTabs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GestureDetector(
                    onTap: () {
                      shop.setActiveDepartment(deptToCategory(tab));
                      shop.closeAllDrawers();
                      appGoHome();
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: shop.activeDepartment.toLowerCase() == deptToCategory(tab).toLowerCase()
                                ? Colors.black
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: shop.activeDepartment.toLowerCase() == deptToCategory(tab).toLowerCase()
                              ? Colors.black
                              : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              actions,
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 42,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(canPop ? Icons.arrow_back_ios_new : Icons.menu, size: canPop ? 18 : 22),
                onPressed: () {
                  if (canPop) {
                    Navigator.of(context).pop();
                  } else {
                    shop.openMenuDrawer();
                  }
                },
              ),
            ),
            Expanded(child: Center(child: logo())),
            actions,
          ],
        ),
      ),
    );
  }
}

class _DesktopCategoryBar extends StatelessWidget {
  const _DesktopCategoryBar();

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final cat in navCategories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  appPush(CollectionScreen(
                    initialCategory: shop.activeDepartment.isEmpty ? null : shop.activeDepartment,
                    initialFilter: cat.id == 'new_in' ? 'new_in' : null,
                    initialType: cat.id == 'accessories' ? 'accessories' : null,
                  ));
                },
                child: Text(
                  cat.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
