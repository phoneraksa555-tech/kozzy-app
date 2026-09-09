import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/menu_data.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_top_bar.dart';
import 'about_screen.dart';
import 'collection_screen.dart';
import 'contact_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final dept = shop.activeDepartment.toLowerCase() == 'women' ? 'WOMEN' : 'MEN';
    final collections = shop.collections;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppTopBar(showLogo: false, title: 'Menu'),
          Row(
            children: [
              for (final tab in menuTabs)
                Expanded(
                  child: GestureDetector(
                    onTap: () => shop.setActiveDepartment(deptToCategory(tab)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: dept == tab ? Colors.black : const Color(0xFFE5E7EB),
                            width: dept == tab ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: dept == tab ? Colors.black : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final cat in collections)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      cat.name.toLowerCase() == 'bags' ? 'Accessories' : cat.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    onTap: () {
                      final slug = cat.slug;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CollectionScreen(
                            initialCategory: deptToCategory(dept),
                            initialType: (slug == 'all') ? null : (slug == 'bags' ? 'accessories' : slug),
                          ),
                        ),
                      );
                    },
                  ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('About Kozzy', style: TextStyle(fontSize: 14)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Contact Us', style: TextStyle(fontSize: 14, color: AppConstants.brandGray)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
