import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import '../providers/shop_provider.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';
import 'order_success_screen.dart';
import 'payment_qr_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;

  const PlaceOrderScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Phnom Penh');
  final _orderService = OrderService();
  final _paymentService = PaymentService();

  String _paymentMethod = 'COD'; // 'COD' or 'ABA_KHQR'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final shop = context.read<ShopProvider>();
    if (shop.addresses.isNotEmpty) {
      final defaultAddr = shop.addresses.firstWhere((a) => a.isDefault, orElse: () => shop.addresses.first);
      _firstNameCtrl.text = defaultAddr.firstName;
      _lastNameCtrl.text = defaultAddr.lastName;
      _phoneCtrl.text = defaultAddr.phone;
      _streetCtrl.text = defaultAddr.street;
      _cityCtrl.text = defaultAddr.city;
    } else if (shop.userProfile != null) {
      final names = shop.userProfile!.name.split(' ');
      _firstNameCtrl.text = names.isNotEmpty ? names.first : '';
      _lastNameCtrl.text = names.length > 1 ? names.sublist(1).join(' ') : '';
      _phoneCtrl.text = shop.userProfile!.phone;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final shop = context.read<ShopProvider>();

    try {
      final addressData = {
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'street': _streetCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'country': 'Cambodia',
      };

      // Save address locally if new
      shop.addAddress(Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: shop.userProfile?.email ?? '',
        phone: _phoneCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _cityCtrl.text.trim(),
      ));

      final itemsPayload = widget.items.map((it) => {
        '_id': it.productId,
        'size': it.size,
        'quantity': it.quantity,
      }).toList();

      final orderPayload = {
        'address': addressData,
        'items': itemsPayload,
        'amount': widget.total,
        'paymentMethod': _paymentMethod,
        'paymentSuccess': _paymentMethod == 'COD',
      };

      if (_paymentMethod == 'ABA_KHQR') {
        // Create ABA PayWay QR
        final qrRes = await _paymentService.createPaywayQr({
          'amount': widget.total,
          'orderData': orderPayload,
        });

        if (qrRes['success'] == true) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentQRScreen(
                qrData: qrRes,
                orderData: orderPayload,
              ),
            ),
          );
          return;
        } else {
          throw Exception(qrRes['message'] ?? 'Could not create ABA KHQR payment');
        }
      }

      // COD order
      final res = await _orderService.placeOrder(orderPayload);
      if (res['success'] == true) {
        shop.clearCart();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: res['orderId']?.toString() ?? 'KOZZY-${DateTime.now().millisecondsSinceEpoch}',
              total: widget.total,
            ),
          ),
        );
      } else {
        throw Exception(res['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section 1: Delivery Address
            const Text(
              'DELIVERY ADDRESS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'First Name *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Last Name *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Cambodia) *',
                prefixText: '+855 ',
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Phone required for courier' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _streetCtrl,
              decoration: const InputDecoration(labelText: 'House / Street / Sangkat / Khan *'),
              validator: (v) => (v == null || v.isEmpty) ? 'Address required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'City / Province *'),
              validator: (v) => (v == null || v.isEmpty) ? 'City required' : null,
            ),

            const SizedBox(height: 28),

            // Section 2: Payment Method
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),

            // COD Option
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _paymentMethod == 'COD' ? AppConstants.brandBlack : AppConstants.brandBorder,
                  width: _paymentMethod == 'COD' ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: _paymentMethod == 'COD' ? const Color(0xFFF9FAFB) : Colors.white,
              ),
              child: RadioListTile<String>(
                value: 'COD',
                groupValue: _paymentMethod,
                activeColor: AppConstants.brandBlack,
                title: const Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Pay with cash upon arrival at your doorstep in Cambodia.'),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
            ),

            const SizedBox(height: 10),

            // ABA PayWay Option
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _paymentMethod == 'ABA_KHQR' ? AppConstants.primaryColor : AppConstants.brandBorder,
                  width: _paymentMethod == 'ABA_KHQR' ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: _paymentMethod == 'ABA_KHQR' ? AppConstants.primaryLight : Colors.white,
              ),
              child: RadioListTile<String>(
                value: 'ABA_KHQR',
                groupValue: _paymentMethod,
                activeColor: AppConstants.primaryColor,
                title: Row(
                  children: [
                    const Text('ABA PayWay / Bakong KHQR', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('INSTANT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                subtitle: const Text('Scan KHQR with ABA Mobile or any Bakong banking app.'),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
            ),

            const SizedBox(height: 28),

            // Section 3: Summary
            const Text(
              'ORDER SUMMARY',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppConstants.brandBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items (${widget.items.length})'),
                      Text('\$${widget.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping Fee'),
                      Text(widget.shippingFee == 0 ? 'FREE' : '\$${widget.shippingFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  if (widget.discount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount', style: TextStyle(color: Colors.green)),
                        Text('-\$${widget.discount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '\$${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppConstants.primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _paymentMethod == 'ABA_KHQR' ? 'PROCEED TO KHQR PAYMENT' : 'CONFIRM ORDER (COD)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
