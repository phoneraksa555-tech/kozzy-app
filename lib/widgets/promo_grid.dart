import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/layout.dart';
import '../config/site_assets.dart';
import '../providers/shop_provider.dart';
import '../screens/collection_screen.dart';

class PromoGrid extends StatelessWidget {
  const PromoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isWomen = shop.activeDepartment.toLowerCase() == 'women';
    final left = isWomen ? SiteAssets.promoWomenLeft : SiteAssets.promoMenLeft;
    final right = isWomen ? SiteAssets.promoWomenRight : SiteAssets.promoMenRight;
    final category = isWomen ? 'Women' : 'Men';

    return Padding(
      padding: SiteLayout.pagePadding(context).copyWith(top: 20, bottom: 40),
      child: Column(
        children: [
          const Text(
            'FEATURED COLLECTIONS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _tile(context, left, category)),
              const SizedBox(width: 6),
              Expanded(child: _tile(context, right, category)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String asset, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CollectionScreen(initialCategory: category),
          ),
        );
      },
      child: ColoredBox(
        color: const Color(0xFFF9F9F9),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => const AspectRatio(
            aspectRatio: 4 / 5,
            child: ColoredBox(color: Color(0xFFF3F4F6)),
          ),
        ),
      ),
    );
  }
}
