import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_top_bar.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isWomen = shop.activeDepartment.toLowerCase() == 'women';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppTopBar(showLogo: false, title: 'Profile'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (!shop.isLoggedIn) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text('SIGN IN / REGISTER'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text('Membership & Benefits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text(
                  'Discover our free membership program',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 148,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2A2A2A), Color(0xFF111111)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(width: 4, color: const Color(0xFFE8C547)),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'PLATINUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${shop.freeShippingThreshold.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            _perk('Apparel', '20%'),
                            _perk('Accessories', '15%'),
                            _perk('Free delivery', '0'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (shop.isLoggedIn) ...[
                  const SizedBox(height: 20),
                  _row(Icons.receipt_long_outlined, 'My Orders', () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersScreen()));
                  }),
                  _row(Icons.location_on_outlined, 'Addresses', () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen()));
                  }),
                ],
                const SizedBox(height: 28),
                const Text('Country and Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _settingRow(
                  leading: const Text('🇰🇭', style: TextStyle(fontSize: 22)),
                  title: 'Cambodia - USD(US \$)',
                  subtitle: 'Country',
                ),
                const Divider(height: 1),
                _settingRow(
                  leading: const Icon(Icons.translate, color: Colors.black),
                  title: 'English / ភាសា',
                  subtitle: 'Language/ភាសា',
                ),
                const SizedBox(height: 28),
                const Text('My Shop Preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shop Men'),
                  value: 'Men',
                  groupValue: isWomen ? 'Women' : 'Men',
                  activeColor: Colors.black,
                  onChanged: (v) => shop.setActiveDepartment(v ?? 'Men'),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shop Women'),
                  value: 'Women',
                  groupValue: isWomen ? 'Women' : 'Men',
                  activeColor: Colors.black,
                  onChanged: (v) => shop.setActiveDepartment(v ?? 'Women'),
                ),
                const SizedBox(height: 16),
                const Text('Customer Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                _row(Icons.campaign_outlined, 'Privacy Policy', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
                }),
                _row(Icons.help_outline, 'Help center', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactScreen()));
                }),
                if (shop.isLoggedIn)
                  TextButton(
                    onPressed: () => shop.logout(),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Sign out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _perk(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label $value',
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }

  Widget _settingRow({required Widget leading, required String title, required String subtitle}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _row(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
