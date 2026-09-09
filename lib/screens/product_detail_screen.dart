import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../widgets/site_header.dart';
import 'login_screen.dart';
import 'place_order_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _activeImageIndex = 0;
  String? _selectedSize;
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final Product? product = shop.findProductById(widget.productId);

    if (product == null) {
      return const Scaffold(
        body: Column(
          children: [
            SafeArea(bottom: false, child: SiteHeader(showBack: true)),
            Expanded(child: Center(child: Text('Product not found'))),
          ],
        ),
      );
    }

    final isWish = shop.isInWishlist(product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SafeArea(bottom: false, child: SiteHeader(showBack: true)),
          Expanded(
            child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: product.images.isNotEmpty ? product.images.length : 1,
                    onPageChanged: (i) => setState(() => _activeImageIndex = i),
                    itemBuilder: (context, i) {
                      if (product.images.isEmpty) {
                        return Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                        );
                      }
                      return CachedNetworkImage(
                        imageUrl: product.images[i],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image_outlined, size: 48),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton.filledTonal(
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                      onPressed: () => shop.toggleWishlist(product.id),
                      icon: Icon(
                        isWish ? Icons.favorite : Icons.favorite_border,
                        color: isWish ? AppConstants.primaryColor : AppConstants.brandBlack,
                      ),
                    ),
                  ),
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _activeImageIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _activeImageIndex == index
                                  ? AppConstants.primaryColor
                                  : Colors.black26,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.brandGray,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppConstants.brandBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppConstants.brandBlack,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Size selection
                  if (product.sizes.isNotEmpty) ...[
                    const Text(
                      'SELECT SIZE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppConstants.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        final isAvailable = product.isAvailableInSize(size);

                        return GestureDetector(
                          onTap: isAvailable
                              ? () => setState(() => _selectedSize = size)
                              : null,
                          child: Container(
                            width: 50,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppConstants.brandBlack
                                  : (isAvailable ? Colors.white : const Color(0xFFF3F4F6)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppConstants.brandBlack
                                    : (isAvailable ? AppConstants.brandBorder : Colors.transparent),
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isAvailable ? AppConstants.brandBlack : Colors.black26),
                                decoration: isAvailable ? null : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppConstants.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Authentic high-grade Kozzy apparel and lifestyle product.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppConstants.brandDark,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Service guarantees
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.brandBorder),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 20, color: AppConstants.brandBlack),
                            SizedBox(width: 12),
                            Text(
                              'Free delivery over \$30 in Cambodia',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Divider(height: 20),
                        Row(
                          children: [
                            Icon(Icons.payment_outlined, size: 20, color: AppConstants.brandBlack),
                            SizedBox(width: 12),
                            Text(
                              'Cash on Delivery & ABA KHQR accepted',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Divider(height: 20),
                        Row(
                          children: [
                            Icon(Icons.verified_outlined, size: 20, color: AppConstants.brandBlack),
                            SizedBox(width: 12),
                            Text(
                              '100% Original Authentic Kozzy Goods',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isAdding
                      ? null
                      : () async {
                          if (product.sizes.isNotEmpty && _selectedSize == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please choose a size first')),
                            );
                            return;
                          }

                          setState(() => _isAdding = true);
                          final sizeToUse = _selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : 'ONE SIZE');
                          final messenger = ScaffoldMessenger.of(context);
                          final err = await shop.addToCart(product.id, sizeToUse);
                          if (mounted) setState(() => _isAdding = false);

                          if (err != null) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                          } else {
                            shop.openCartDrawer();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.brandBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'ADD TO BAG',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (product.sizes.isNotEmpty && _selectedSize == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please choose a size first')),
                      );
                      return;
                    }
                    final sizeToUse = _selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : 'ONE SIZE');
                    final nav = Navigator.of(context);
                    await shop.addToCart(product.id, sizeToUse);
                    if (!mounted) return;
                    if (!shop.isLoggedIn) {
                      nav.push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                      return;
                    }
                    final items = shop.getCartItemModels();
                    final subtotal = shop.getCartAmount();
                    final shippingFee = shop.getShippingFee(subtotal);
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => PlaceOrderScreen(
                          items: items,
                          subtotal: subtotal,
                          shippingFee: shippingFee,
                          discount: 0,
                          total: subtotal + shippingFee,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'BUY NOW',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
