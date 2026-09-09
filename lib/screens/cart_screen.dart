import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/shop_provider.dart';
import '../models/cart_item.dart';
import 'place_order_screen.dart';
import 'collection_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponCtrl = TextEditingController();
  double _discountAmount = 0.0;
  String? _appliedCoupon;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final items = shop.getCartItemModels();
    final subtotal = shop.getCartAmount();
    final shippingFee = shop.getShippingFee(subtotal);
    final total = (subtotal + shippingFee - _discountAmount).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Bag'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Bag?'),
                    content: const Text('Are you sure you want to remove all items from your bag?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          shop.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: AppConstants.primaryColor)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: AppConstants.primaryColor)),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, size: 56, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Bag is Empty',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore our collection and add your favorite pieces.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppConstants.brandGray),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const CollectionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.brandBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: const Text('EXPLORE COLLECTION'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return _buildCartRow(context, shop, item);
                    },
                  ),
                ),

                // Bottom summary & checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Coupon Code Field
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _couponCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Promo / Coupon code',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final code = _couponCtrl.text.trim();
                                if (code.toUpperCase() == 'KOZZY10') {
                                  setState(() {
                                    _discountAmount = subtotal * 0.10;
                                    _appliedCoupon = 'KOZZY10';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Promo KOZZY10 applied (10% off)!')),
                                  );
                                } else if (code.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid coupon code')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.brandBlack,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              ),
                              child: const Text('APPLY'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Calculation Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: AppConstants.brandGray)),
                            Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Shipping', style: TextStyle(color: AppConstants.brandGray)),
                            Text(
                              shippingFee == 0 ? 'FREE' : '\$${shippingFee.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: shippingFee == 0 ? Colors.green : AppConstants.brandBlack,
                              ),
                            ),
                          ],
                        ),
                        if (_discountAmount > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount ($_appliedCoupon)', style: const TextStyle(color: Colors.green)),
                              Text('-\$${_discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Proceed button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlaceOrderScreen(
                                    items: items,
                                    subtotal: subtotal,
                                    shippingFee: shippingFee,
                                    discount: _discountAmount,
                                    total: total,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartRow(BuildContext context, ShopProvider shop, CartItem item) {
    final product = item.product;
    final image = product?.firstImage ?? '';
    final name = product?.name ?? 'Item ${item.productId}';
    final price = product?.price ?? 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 75,
          height: 95,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: image.isNotEmpty
              ? CachedNetworkImage(imageUrl: image, fit: BoxFit.cover)
              : const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(width: 14),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Size: ${item.size}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.brandGray),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
        ),

        // Stepper
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
              onPressed: () => shop.updateQuantity(item.productId, item.size, 0),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppConstants.brandBorder),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => shop.updateQuantity(item.productId, item.size, item.quantity - 1),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => shop.updateQuantity(item.productId, item.size, item.quantity + 1),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
