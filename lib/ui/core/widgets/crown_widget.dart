import 'package:material_ui/material_ui.dart';

class CrownWidget extends StatelessWidget {
  const CrownWidget({super.key, required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CrownPainter(color: color),
      ),
    );
  }
}

class CrownPainter extends CustomPainter {
  final Color color;

  CrownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path path = Path();
    
    // Precision-crafted path tracing the target image:
    // https://framerusercontent.com/images/qBuoCENHzL2l9KkMZuRNwmH1zj8.png?width=512&height=512
    path.moveTo(0.30 * w, 1.00 * h);
    path.lineTo(0.70 * w, 1.00 * h);
    
    // Bottom-right corner and up right side
    path.cubicTo(0.86 * w, 1.00 * h, 1.00 * w, 0.73 * h, 1.00 * w, 0.38 * h);
    
    // Right peak tip
    path.cubicTo(1.00 * w, 0.28 * h, 0.97 * w, 0.26 * h, 0.93 * w, 0.28 * h);
    
    // Down to right valley
    path.cubicTo(0.88 * w, 0.31 * h, 0.83 * w, 0.43 * h, 0.77 * w, 0.43 * h);
    
    // Up to center peak
    path.cubicTo(0.70 * w, 0.43 * h, 0.58 * w, 0.00 * h, 0.50 * w, 0.00 * h);
    
    // Center peak tip and down to left valley
    path.cubicTo(0.42 * w, 0.00 * h, 0.30 * w, 0.43 * h, 0.23 * w, 0.43 * h);
    
    // Up to left peak
    path.cubicTo(0.17 * w, 0.43 * h, 0.12 * w, 0.31 * h, 0.07 * w, 0.28 * h);
    
    // Left peak tip
    path.cubicTo(0.03 * w, 0.26 * h, 0.00 * w, 0.28 * h, 0.00 * w, 0.38 * h);
    
    // Down left side and bottom-left corner
    path.cubicTo(0.00 * w, 0.73 * h, 0.14 * w, 1.00 * h, 0.30 * w, 1.00 * h);
    
    path.close();

    // 1. Draw outline/border (black/dark stroke)
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // 2. Draw fill
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CrownPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
