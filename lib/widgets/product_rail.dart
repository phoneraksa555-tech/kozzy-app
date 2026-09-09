import 'package:flutter/material.dart';
import '../config/layout.dart';
import '../models/product.dart';
import 'product_card.dart';

class ProductRail extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final List<Product> products;
  final bool loading;

  const ProductRail({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.products,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading && products.isEmpty) return const SizedBox.shrink();

    final padding = SiteLayout.pagePadding(context);
    final cardWidth = SiteLayout.railCardWidth(context);
    final railHeight = cardWidth * 4 / 3 + 92;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: padding.copyWith(top: 0, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onSeeAll,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text(
                    'ទិញឥឡូវ',
                    style: TextStyle(
                      fontFamily: 'KantumruyPro',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: railHeight,
            child: ListView.separated(
              padding: padding,
              scrollDirection: Axis.horizontal,
              itemCount: loading && products.isEmpty ? 4 : products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (loading && products.isEmpty) {
                  return Container(width: cardWidth, color: const Color(0xFFF0F0F0));
                }
                return SizedBox(
                  width: cardWidth,
                  child: ProductCard(product: products[index], compact: true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
