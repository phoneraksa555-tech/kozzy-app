import 'package:flutter/material.dart';
import '../config/constants.dart';
import 'orders_screen.dart';
import 'main_navigation_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double total;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 60, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppConstants.brandBlack,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for shopping with Kozzy. We have received your order and our team is preparing it for delivery.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppConstants.brandGray, height: 1.4),
              ),
              const SizedBox(height: 28),

              // Order detail card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.brandBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Reference', style: TextStyle(color: AppConstants.brandGray)),
                        Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: AppConstants.brandGray)),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppConstants.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.brandBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('VIEW MY ORDERS'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('CONTINUE SHOPPING'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
