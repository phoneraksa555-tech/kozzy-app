import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool compact;

  const ProductCard({super.key, required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isWish = shop.isInWishlist(product.id);
    final image = product.firstImage;
    final soldOut = product.isSoldOut;
    final newIn = product.isNewIn && !soldOut;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: const Color(0xFFF0F0F0),
                  child: image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          placeholder: (_, __) => const ColoredBox(color: Color(0xFFF0F0F0)),
                          errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        )
                      : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                ),
                if (soldOut || newIn)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xF2181818),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        soldOut ? 'Sold out' : 'New In',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.25,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            Text(
                              '-${product.discount}%',
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
                            ),
                            Text(
                              '\$${product.originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => shop.toggleWishlist(product.id),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, left: 4),
                    child: Icon(
                      isWish ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isWish ? AppConstants.primaryColor : const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (product.colors.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Row(
                children: [
                  for (final color in product.colors.take(5))
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _parseHex(color.hex),
                        border: Border.all(color: const Color(0xFFD1D5DB), width: 0.6),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _parseHex(String hex) {
    var value = hex.replaceAll('#', '').trim();
    if (value.length == 3) {
      value = value.split('').map((c) => '$c$c').join();
    }
    if (value.length != 6) return const Color(0xFFD1D5DB);
    return Color(int.parse('FF$value', radix: 16));
  }
}
