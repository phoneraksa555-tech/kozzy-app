import 'product.dart';

class CartItem {
  final String productId;
  final String size;
  int quantity;
  final Product? product;

  CartItem({
    required this.productId,
    required this.size,
    required this.quantity,
    this.product,
  });

  double get totalPrice {
    if (product == null) return 0.0;
    return product!.price * quantity;
  }
}
