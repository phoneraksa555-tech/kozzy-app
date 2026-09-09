import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_navigator.dart';
import '../providers/shop_provider.dart';
import '../screens/about_screen.dart';
import '../screens/addresses_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/wishlist_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final open = shop.showProfileDrawer;
    final profile = shop.userProfile;
    final name = (profile?.name.isNotEmpty == true ? profile!.name : 'Kozzy').split(' ').first;

    return IgnorePointer(
      ignoring: !open,
      child: ExcludeFocus(
        excluding: !open,
        child: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: open ? 1 : 0,
            child: GestureDetector(
              onTap: shop.closeProfileDrawer,
              child: Container(color: Colors.black38),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            right: open ? 0 : -420,
            top: 0,
            bottom: 0,
            width: MediaQuery.sizeOf(context).width.clamp(280, 400),
            child: Material(
              color: Colors.white,
              elevation: 16,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: shop.closeProfileDrawer),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        children: [
                          Text('Hi, $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          if (profile?.email != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(profile!.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _gridBtn(context, Icons.receipt_long_outlined, 'Orders', () {
                                shop.closeProfileDrawer();
                                appPush(const OrdersScreen());
                              }),
                              const SizedBox(width: 10),
                              _gridBtn(context, Icons.favorite_border, 'Favourites', () {
                                shop.closeProfileDrawer();
                                appPush(const WishlistScreen());
                              }),
                              const SizedBox(width: 10),
                              _gridBtn(context, Icons.location_on_outlined, 'Addresses', () {
                                shop.closeProfileDrawer();
                                appPush(const AddressesScreen());
                              }),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _row(Icons.help_outline, 'Help center', () {
                            shop.closeProfileDrawer();
                            appPush(const ContactScreen());
                          }),
                          _row(Icons.storefront_outlined, 'About Kozzy', () {
                            shop.closeProfileDrawer();
                            appPush(const AboutScreen());
                          }),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () async {
                              shop.closeProfileDrawer();
                              await shop.logout();
                              appPush(const LoginScreen());
                            },
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _gridBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: const Color(0xFF4B5563)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22, color: const Color(0xFF374151)),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
