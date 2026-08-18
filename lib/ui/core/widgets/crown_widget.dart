import 'package:material_ui/material_ui.dart';
import 'package:queens/domain/models/app_settings.dart';

class CrownWidget extends StatelessWidget {
  const CrownWidget({
    super.key,
    required this.color,
    required this.size,
    this.skin = CrownSkin.classic,
  });

  final Color color;
  final double size;
  final CrownSkin skin;

  @override
  Widget build(BuildContext context) {
    if (skin.assetPath != null) {
      return Image.asset(
        skin.assetPath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
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
    
    path.moveTo(0.30 * w, 1.00 * h);
    path.lineTo(0.70 * w, 1.00 * h);
    path.cubicTo(0.86 * w, 1.00 * h, 1.00 * w, 0.73 * h, 1.00 * w, 0.38 * h);
    path.cubicTo(1.00 * w, 0.28 * h, 0.97 * w, 0.26 * h, 0.93 * w, 0.28 * h);
    path.cubicTo(0.88 * w, 0.31 * h, 0.83 * w, 0.43 * h, 0.77 * w, 0.43 * h);
    path.cubicTo(0.70 * w, 0.43 * h, 0.58 * w, 0.00 * h, 0.50 * w, 0.00 * h);
    path.cubicTo(0.42 * w, 0.00 * h, 0.30 * w, 0.43 * h, 0.23 * w, 0.43 * h);
    path.cubicTo(0.17 * w, 0.43 * h, 0.12 * w, 0.31 * h, 0.07 * w, 0.28 * h);
    path.cubicTo(0.03 * w, 0.26 * h, 0.00 * w, 0.28 * h, 0.00 * w, 0.38 * h);
    path.cubicTo(0.00 * w, 0.73 * h, 0.14 * w, 1.00 * h, 0.30 * w, 1.00 * h);
    path.close();

    final Paint borderPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

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
