import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../app_navigator.dart';
import '../config/constants.dart';
import '../providers/shop_provider.dart';
import '../screens/collection_screen.dart';
import '../screens/login_screen.dart';
import '../screens/place_order_screen.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final open = shop.showCartDrawer;
    final items = shop.getCartItemModels();
    final count = shop.getCartCount();
    final subtotal = shop.getCartAmount();
    final shipping = shop.getShippingFee(subtotal);
    final total = subtotal + shipping;

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
              onTap: shop.closeCartDrawer,
              child: Container(color: Colors.black38),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'YOUR BAG',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.6),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  count > 0 ? '$count item${count == 1 ? '' : 's'}' : 'No items yet',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: shop.closeCartDrawer),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('មិនទាន់មានទំនិញ', style: TextStyle(fontFamily: 'KantumruyPro', fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 16),
                                  OutlinedButton(
                                    onPressed: () {
                                      shop.closeCartDrawer();
                                      appPush(const CollectionScreen());
                                    },
                                    child: const Text('ADD ITEM'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const Divider(height: 20),
                              itemBuilder: (context, i) {
                                final item = items[i];
                                final product = item.product;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      height: 96,
                                      child: ColoredBox(
                                        color: const Color(0xFFF3F4F6),
                                        child: product != null && product.firstImage.isNotEmpty
                                            ? CachedNetworkImage(imageUrl: product.firstImage, fit: BoxFit.cover)
                                            : const SizedBox(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product?.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.size == 'OS' ? 'ទំហំសម' : 'ទំហំ ${item.size}',
                                            style: const TextStyle(fontFamily: 'KantumruyPro', fontSize: 11, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _QtyBtn(icon: Icons.remove, onTap: () => shop.updateQuantity(item.productId, item.size, item.quantity - 1)),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text('${item.quantity}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                              ),
                                              _QtyBtn(icon: Icons.add, onTap: () => shop.updateQuantity(item.productId, item.size, item.quantity + 1)),
                                              const Spacer(),
                                              Text(
                                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.primaryColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    if (items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        child: Column(
                          children: [
                            _line('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                            _line('Shipping', shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}'),
                            const SizedBox(height: 6),
                            _line('Total', '\$${total.toStringAsFixed(2)}', bold: true),
                            const SizedBox(height: 12),
                              SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  shop.closeCartDrawer();
                                  if (!shop.isLoggedIn) {
                                    appPush(const LoginScreen());
                                    return;
                                  }
                                  appPush(PlaceOrderScreen(
                                    items: items,
                                    subtotal: subtotal,
                                    shippingFee: shipping,
                                    discount: 0,
                                    total: total,
                                  ));
                                },
                                child: const Text('CHECKOUT'),
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

  Widget _line(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}
