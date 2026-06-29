import 'package:material_ui/material_ui.dart';

class CrownWidget extends StatelessWidget {
  const CrownWidget({super.key, required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrownPainter(color),
    );
  }
}

class _CrownPainter extends CustomPainter {
  final Color color;
  _CrownPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    // Draw base band
    path.moveTo(size.width * 0.15, size.height * 0.85);
    path.lineTo(size.width * 0.85, size.height * 0.85);
    path.lineTo(size.width * 0.85, size.height * 0.73);
    path.lineTo(size.width * 0.15, size.height * 0.73);
    path.close();

    // Draw peaks
    path.moveTo(size.width * 0.15, size.height * 0.70);
    path.lineTo(size.width * 0.10, size.height * 0.35); // Left Peak
    path.lineTo(size.width * 0.35, size.height * 0.58); // Left Valley
    path.lineTo(size.width * 0.50, size.height * 0.20); // Center Peak
    path.lineTo(size.width * 0.65, size.height * 0.58); // Right Valley
    path.lineTo(size.width * 0.90, size.height * 0.35); // Right Peak
    path.lineTo(size.width * 0.85, size.height * 0.70);
    path.close();

    canvas.drawPath(path, paint);

    // Draw small circles at the tips of the peaks
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.10, size.height * 0.35), size.width * 0.07, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.20), size.width * 0.07, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.90, size.height * 0.35), size.width * 0.07, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
