import 'package:material_ui/material_ui.dart';

class CrossWidget extends StatelessWidget {
  const CrossWidget({
    super.key,
    required this.size,
    this.color = const Color(0xFFFFFFFF),
    this.shadowColor = const Color(0x99000000),
    this.strokeWidthRatio = 0.22,
  });

  final double size;
  final Color color;
  final Color shadowColor;
  final double strokeWidthRatio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CrossPainter(
          color: color,
          shadowColor: shadowColor,
          strokeWidthRatio: strokeWidthRatio,
        ),
      ),
    );
  }
}

class CrossPainter extends CustomPainter {
  const CrossPainter({
    required this.color,
    required this.shadowColor,
    required this.strokeWidthRatio,
  });

  final Color color;
  final Color shadowColor;
  final double strokeWidthRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * strokeWidthRatio;
    final padding = strokeWidth * 0.7;

    final p1 = Offset(padding, padding);
    final p2 = Offset(size.width - padding, size.height - padding);
    final p3 = Offset(size.width - padding, padding);
    final p4 = Offset(padding, size.height - padding);

    final shadowSpread = Paint()
      ..color = shadowColor
      ..strokeWidth = strokeWidth + 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    canvas.drawLine(p1, p2, shadowSpread);
    canvas.drawLine(p3, p4, shadowSpread);

    final dropOffset = Offset(0, size.height * 0.05);
    final dropShadow = Paint()
      ..color = shadowColor.withValues(alpha: shadowColor.a * 0.85)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    canvas.drawLine(p1 + dropOffset, p2 + dropOffset, dropShadow);
    canvas.drawLine(p3 + dropOffset, p4 + dropOffset, dropShadow);

    final crossPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, crossPaint);
    canvas.drawLine(p3, p4, crossPaint);
  }

  @override
  bool shouldRepaint(covariant CrossPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.strokeWidthRatio != strokeWidthRatio;
  }
}
