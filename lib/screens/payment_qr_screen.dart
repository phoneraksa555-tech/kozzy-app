import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/constants.dart';
import '../providers/shop_provider.dart';
import '../services/payment_service.dart';
import 'order_success_screen.dart';

class PaymentQRScreen extends StatefulWidget {
  final Map<String, dynamic> qrData;
  final Map<String, dynamic> orderData;

  const PaymentQRScreen({
    super.key,
    required this.qrData,
    required this.orderData,
  });

  @override
  State<PaymentQRScreen> createState() => _PaymentQRScreenState();
}

class _PaymentQRScreenState extends State<PaymentQRScreen> {
  final PaymentService _paymentService = PaymentService();
  int _secondsLeft = 360; // 6 minutes
  Timer? _timer;
  Timer? _pollTimer;
  bool _checking = false;
  bool _completed = false;

  late String _transactionId;
  late String _qrString;

  @override
  void initState() {
    super.initState();
    _transactionId = widget.qrData['tranId']?.toString() ??
        widget.qrData['transactionId']?.toString() ??
        widget.qrData['orderId']?.toString() ??
        '';
    _qrString = widget.qrData['qrString']?.toString() ??
        widget.qrData['qr']?.toString() ??
        _transactionId;

    _startCountdown();
    _startPolling();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkStatus(silent: true);
    });
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_transactionId.isEmpty || _completed) return;
    if (!silent) setState(() => _checking = true);

    try {
      final res = await _paymentService.checkPaywayStatus(_transactionId);
      if (res['success'] == true && res['isPaid'] == true) {
        _completed = true;
        _timer?.cancel();
        _pollTimer?.cancel();

        if (!mounted) return;
        final shop = context.read<ShopProvider>();
        shop.clearCart();
        shop.refreshProducts();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: res['orderId']?.toString() ?? _transactionId,
              total: (widget.orderData['amount'] as num?)?.toDouble() ?? 0.0,
            ),
          ),
        );
      } else if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment not detected yet. Please make sure the transfer completed.')),
        );
      }
    } catch (_) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not verify payment status')),
        );
      }
    } finally {
      if (!silent && mounted) setState(() => _checking = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  String _formatTimer() {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABA PayWay KHQR'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ABA KHQR Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.brandBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // KHQR Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC00000),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'KHQR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bakong Payment',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                    ),
                    child: _qrString.isNotEmpty
                        ? QrImageView(
                            data: _qrString,
                            version: QrVersions.auto,
                            size: 220.0,
                          )
                        : const SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(child: Text('Invalid QR Data')),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Amount
                  Text(
                    '\$${((widget.orderData['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppConstants.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transaction ID: $_transactionId',
                    style: const TextStyle(fontSize: 12, color: AppConstants.brandGray),
                  ),

                  const Divider(height: 30),

                  // Countdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 18, color: AppConstants.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'Expires in: ${_formatTimer()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.brandBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOW TO PAY:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  SizedBox(height: 8),
                  Text('1. Open ABA Mobile or any banking app supporting Bakong KHQR.'),
                  SizedBox(height: 4),
                  Text('2. Tap "QR Pay" / "Scan QR" and point your camera at this QR code.'),
                  SizedBox(height: 4),
                  Text('3. Confirm payment. Your order will update automatically!'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Check Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checking ? null : () => _checkStatus(silent: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.brandBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('I HAVE PAID • CHECK STATUS'),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel and return to checkout', style: TextStyle(color: AppConstants.brandGray)),
            ),
          ],
        ),
      ),
    );
  }
}
