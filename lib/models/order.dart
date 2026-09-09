class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String size;
  final String image;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
    required this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String parseImg(dynamic img) {
      if (img is List && img.isNotEmpty) return img[0].toString();
      if (img is String) return img;
      return '';
    }

    return OrderItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Item',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
      size: json['size']?.toString() ?? '',
      image: parseImg(json['image']),
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double amount;
  final dynamic address;
  final String status;
  final String paymentMethod;
  final bool payment;
  final int date;

  Order({
    required this.id,
    required this.items,
    required this.amount,
    required this.address,
    required this.status,
    required this.paymentMethod,
    required this.payment,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parseItems(dynamic rawItems) {
      if (rawItems is List) {
        return rawItems
            .whereType<Map>()
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    return Order(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      items: parseItems(json['items']),
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      address: json['address'],
      status: json['status']?.toString() ?? 'Order Placed',
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      payment: json['payment'] == true,
      date: (json['date'] is num) ? (json['date'] as num).toInt() : 0,
    );
  }
}
