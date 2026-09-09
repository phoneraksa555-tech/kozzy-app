import 'package:flutter/material.dart';
import '../config/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Kozzy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/website/about_img.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ABOUT KOZZY',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppConstants.brandBlack,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kozzy is Cambodia’s premier modern fashion and lifestyle brand, delivering thoughtfully curated apparel, everyday essentials, and contemporary beauty products across Phnom Penh and all provinces.',
              style: TextStyle(fontSize: 14, height: 1.6, color: AppConstants.brandDark),
            ),
            const SizedBox(height: 16),
            const Text(
              'Our mission is to make high quality, stylish clothing accessible with frictionless native shopping, transparent pricing, fast nationwide courier delivery, and secure payment options including ABA PayWay KHQR and Cash on Delivery.',
              style: TextStyle(fontSize: 14, height: 1.6, color: AppConstants.brandDark),
            ),
            const SizedBox(height: 28),

            // Highlights
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppConstants.brandBorder),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: AppConstants.primaryColor),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Quality Guaranteed: Rigorous fabric & craftsmanship standards.',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.bolt, color: AppConstants.primaryColor),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Fast Nationwide Delivery: Same-day & next-day options in Cambodia.',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.support_agent, color: AppConstants.primaryColor),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Customer Care: Always ready to assist via Telegram & phone.',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
