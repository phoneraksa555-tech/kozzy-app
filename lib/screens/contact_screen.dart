import 'package:flutter/material.dart';
import '../config/constants.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/website/contact_img.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'GET IN TOUCH',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppConstants.brandBlack,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Have questions about sizing, an existing order, or styling advice? Reach out anytime.',
              style: TextStyle(fontSize: 13, color: AppConstants.brandGray),
            ),
            const SizedBox(height: 24),

            // Contact Info Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.brandBorder),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: AppConstants.primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Store: Phnom Penh, Kingdom of Cambodia',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, color: AppConstants.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Phone: +855 (0) 96 888 8888',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    children: [
                      Icon(Icons.send_outlined, color: AppConstants.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Telegram: @kozzy_online',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Inquiry Form
            const Text(
              'SEND US A MESSAGE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Your Email or Phone'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'How can we help?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sent
                    ? null
                    : () {
                        if (_messageCtrl.text.isNotEmpty) {
                          setState(() => _sent = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Message sent! Our team will respond shortly.')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_sent ? 'MESSAGE SENT' : 'SEND MESSAGE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
