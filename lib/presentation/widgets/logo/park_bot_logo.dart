import 'package:flutter/material.dart';

class AlienCarLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const AlienCarLogo({this.size = 120, this.animate = true, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AlienCarLogoState createState() => _AlienCarLogoState();
}

class _AlienCarLogoState extends State<AlienCarLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    // Slow down the animation by increasing duration
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Increased from 1.5 seconds to 3 seconds
      vsync: this,
    );

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      // Only animate every few seconds to reduce CPU usage
      _startOccasionalAnimation();
    }
  }

  void _startOccasionalAnimation() {
    // Run animation once
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        // Wait longer between animations
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && widget.animate) {
            _startOccasionalAnimation();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(size: Size(widget.size, widget.size), painter: AlienCarPainter(primaryColor: primaryColor, blinkValue: _blinkAnimation.value, isDarkMode: isDark));
      },
    );
  }
}

class AlienCarPainter extends CustomPainter {
  final Color primaryColor;
  final double blinkValue;
  final bool isDarkMode;

  AlienCarPainter({required this.primaryColor, required this.blinkValue, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final isDarkMode = this.isDarkMode;

    final paint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * (isDarkMode ? 0.02 : 0.025);

    final fillPaint =
        Paint()
          ..color = isDarkMode ? Colors.transparent : primaryColor.withAlpha(40)
          ..style = PaintingStyle.fill;

    // Alien head (oval shape)
    final head = RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.6, size.height * 0.5), Radius.circular(size.width * 0.3));

    canvas.drawRRect(head, fillPaint);
    canvas.drawRRect(head, paint);

    // Alien eyes
    final eyePaint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill
          ..strokeWidth = 2;

    // Left eye
    canvas.drawOval(Rect.fromLTWH(size.width * 0.32, size.height * 0.25, size.width * 0.12, size.height * (0.08 * blinkValue)), eyePaint);

    // Right eye
    canvas.drawOval(Rect.fromLTWH(size.width * 0.56, size.height * 0.25, size.width * 0.12, size.height * (0.08 * blinkValue)), eyePaint);

    // Alien antennas
    final antennaPath1 = Path();
    antennaPath1.moveTo(size.width * 0.35, size.height * 0.1);
    antennaPath1.lineTo(size.width * 0.35, size.height * 0);

    final antennaPath2 = Path();
    antennaPath2.moveTo(size.width * 0.65, size.height * 0.1);
    antennaPath2.lineTo(size.width * 0.65, size.height * 0);

    canvas.drawPath(antennaPath1, paint);
    canvas.drawPath(antennaPath2, paint);

    // Car shape below the alien head
    final carPath = Path();

    // Car body
    carPath.moveTo(size.width * 0.15, size.height * 0.65);
    carPath.lineTo(size.width * 0.15, size.height * 0.8);
    carPath.lineTo(size.width * 0.85, size.height * 0.8);
    carPath.lineTo(size.width * 0.85, size.height * 0.65);

    // Car roof
    carPath.lineTo(size.width * 0.7, size.height * 0.65);
    carPath.lineTo(size.width * 0.6, size.height * 0.55);
    carPath.lineTo(size.width * 0.4, size.height * 0.55);
    carPath.lineTo(size.width * 0.3, size.height * 0.65);
    carPath.close();

    canvas.drawPath(carPath, fillPaint);
    canvas.drawPath(carPath, paint);

    // Car wheels
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.85), size.width * 0.08, paint);

    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.85), size.width * 0.08, paint);

    // Parking "P" inside the car
    final textPainter = TextPainter(
      text: TextSpan(text: 'P', style: TextStyle(color: primaryColor, fontSize: size.width * 0.15, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.65 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant AlienCarPainter oldDelegate) {
    return oldDelegate.blinkValue != blinkValue || oldDelegate.primaryColor != primaryColor;
  }
}
