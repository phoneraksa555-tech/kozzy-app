import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/site_assets.dart';
import '../models/store_collection.dart';
import '../providers/shop_provider.dart';
import '../screens/collection_screen.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final tiles = shop.collections;
    if (tiles.isEmpty) return const SizedBox.shrink();

    final isWomen = shop.activeDepartment.toLowerCase() == 'women';
    final visible = tiles.where((t) => t.slug != 'shoes' && t.slug != 'shoe').toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _tile(context, shop, visible[i], isWomen)),
          ],
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, ShopProvider shop, StoreCollection cat, bool isWomen) {
    final slug = cat.slug;
    final displayName = (cat.name.toLowerCase() == 'bags' || cat.name.toLowerCase() == 'bag')
        ? 'Accessories'
        : cat.name;
    final targetSlug = (slug == 'bags' || slug == 'bag') ? 'accessories' : slug;
    final asset = SiteAssets.categoryTile(slug, women: isWomen);
    final networkImage = isWomen && cat.imageWomen.isNotEmpty ? cat.imageWomen : cat.image;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CollectionScreen(
              initialCategory: shop.activeDepartment.isEmpty ? null : shop.activeDepartment,
              initialType: targetSlug == 'all' ? null : targetSlug,
            ),
          ),
        );
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ColoredBox(
              color: const Color(0xFFE8E8E8),
              child: networkImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: networkImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      placeholder: (_, __) => Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => const SizedBox.expand(),
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => const SizedBox.expand(),
                      ),
                    )
                  : Image.asset(
                      asset,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.expand(),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
