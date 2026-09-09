import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../models/order.dart';

class TrackOrderScreen extends StatelessWidget {
  final Order order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status.toLowerCase();
    int currentStep = 0;
    if (status.contains('confirm') || status.contains('processing')) currentStep = 1;
    if (status.contains('shipped') || status.contains('out')) currentStep = 2;
    if (status.contains('delivered')) currentStep = 3;

    final dateStr = order.date > 0
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(order.date))
        : 'Recently placed';

    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Order ID Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.brandBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '\$${order.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppConstants.primaryColor, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Placed on $dateStr', style: const TextStyle(fontSize: 12, color: AppConstants.brandGray)),
                const SizedBox(height: 4),
                Text('Payment: ${order.paymentMethod}', style: const TextStyle(fontSize: 12, color: AppConstants.brandDark)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tracking Milestones
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.brandBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVERY STATUS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 20),
                _buildTimelineStep(
                  title: 'Order Placed',
                  description: 'We have received your order details.',
                  isDone: currentStep >= 0,
                  isCurrent: currentStep == 0,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Processing & Packed',
                  description: 'Our warehouse team is packaging your garments.',
                  isDone: currentStep >= 1,
                  isCurrent: currentStep == 1,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Out for Delivery',
                  description: 'Courier has picked up your package.',
                  isDone: currentStep >= 2,
                  isCurrent: currentStep == 2,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Delivered',
                  description: 'Package delivered to your address.',
                  isDone: currentStep >= 3,
                  isCurrent: currentStep == 3,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Courier Support Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.brandBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.headset_mic_outlined, size: 28, color: AppConstants.brandBlack),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need Help with your Delivery?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Contact Kozzy Support on Telegram @kozzy_support', style: TextStyle(fontSize: 12, color: AppConstants.brandGray)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String description,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    final color = isDone ? AppConstants.primaryColor : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? AppConstants.primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: color,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDone ? AppConstants.brandBlack : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: isDone ? AppConstants.brandGray : Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
