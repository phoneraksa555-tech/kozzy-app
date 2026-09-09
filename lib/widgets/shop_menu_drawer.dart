import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_navigator.dart';
import '../config/menu_data.dart';
import '../config/site_assets.dart';
import '../providers/shop_provider.dart';
import '../screens/about_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/contact_screen.dart';

class ShopMenuDrawer extends StatelessWidget {
  const ShopMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final open = shop.showMenuDrawer;
    final deptKey = shop.activeDepartment.toLowerCase() == 'women' ? 'WOMEN' : 'MEN';
    final isWomen = deptKey == 'WOMEN';

    return IgnorePointer(
      ignoring: !open,
      child: ExcludeFocus(
        excluding: !open,
        child: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: open ? 1 : 0,
            child: GestureDetector(
              onTap: shop.closeMenuDrawer,
              child: Container(color: Colors.black54),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            left: open ? 0 : -320,
            top: 0,
            bottom: 0,
            width: math.min(320.0, MediaQuery.sizeOf(context).width * 0.78),
            child: Material(
              color: Colors.white,
              elevation: 16,
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final tab in menuTabs)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                shop.setActiveDepartment(deptToCategory(tab));
                                shop.closeMenuDrawer();
                                appGoHome();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: deptKey == tab ? Colors.black : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tab,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                    color: deptKey == tab ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: shop.closeMenuDrawer,
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                        children: [
                          for (final cat in navCategories)
                            _Accordion(
                              category: cat,
                              isWomen: isWomen,
                              department: shop.activeDepartment,
                              onClose: shop.closeMenuDrawer,
                            ),
                          const SizedBox(height: 16),
                          const Divider(),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('About Us', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            onTap: () {
                              shop.closeMenuDrawer();
                              appPush(const AboutScreen());
                            },
                          ),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Contact & Support', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            onTap: () {
                              shop.closeMenuDrawer();
                              appPush(const ContactScreen());
                            },
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
}

class _Accordion extends StatefulWidget {
  final MenuNavCategory category;
  final bool isWomen;
  final String department;
  final VoidCallback onClose;

  const _Accordion({
    required this.category,
    required this.isWomen,
    required this.department,
    required this.onClose,
  });

  @override
  State<_Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<_Accordion> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.category.label,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Column(
            children: [
              for (final item in widget.category.items)
                InkWell(
                  onTap: () {
                    widget.onClose();
                    appPush(CollectionScreen(
                      initialCategory: widget.department.isEmpty ? deptToCategory('MEN') : widget.department,
                      initialType: (item.type == null || item.type == 'all') ? null : item.type,
                      initialQuery: item.query,
                      initialFilter: item.filter,
                      initialPath: item.path,
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            SiteAssets.categoryTile(item.imageKey, women: widget.isWomen),
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFFF3F4F6),
                              child: Text(item.label[0], style: const TextStyle(fontSize: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(item.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 6),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }
}
