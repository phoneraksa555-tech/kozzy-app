import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';

class MarqueeBar extends StatefulWidget {
  const MarqueeBar({super.key});

  @override
  State<MarqueeBar> createState() => _MarqueeBarState();
}

class _MarqueeBarState extends State<MarqueeBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    if (!shop.marqueeEnabled) return const SizedBox.shrink();

    final text = shop.marqueeMessages.join('    •    ');
    final style = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
    );

    return ColoredBox(
      color: Colors.black,
      child: SizedBox(
        height: 22,
        width: double.infinity,
        child: ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_controller.value * 420, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$text    •    $text    •    $text    •    ', style: style),
                  Text('$text    •    $text    •    $text    •    ', style: style),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
