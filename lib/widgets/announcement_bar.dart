import 'package:flutter/material.dart';
import '../config/constants.dart';

class AnnouncementBar extends StatelessWidget {
  final String text;

  const AnnouncementBar({
    super.key,
    this.text = 'FREE DELIVERY ON ORDERS OVER \$30 • CASH ON DELIVERY & ABA KHQR',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppConstants.brandBlack,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping_outlined, color: Colors.white70, size: 14),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
