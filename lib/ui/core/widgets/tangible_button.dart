import 'package:flutter/material.dart';
import 'package:queens/ui/core/theme/app_colors.dart';

class TangibleButton extends StatefulWidget {
  const TangibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.height = 56,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final double height;

  @override
  State<TangibleButton> createState() => _TangibleButtonState();
}

class _TangibleButtonState extends State<TangibleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onPressed != null;
    final isPressedNow = _isPressed && isInteractive;

    final Color buttonBg = widget.isSecondary 
        ? Colors.white 
        : const Color(0xFFB5E2FA); // Pastel Sky Blue

    final Color borderColor = AppColors.headingDark;
    final Color textColor = AppColors.headingDark;

    return GestureDetector(
      onTapDown: (_) {
        if (isInteractive) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (isInteractive) {
          setState(() => _isPressed = false);
          if (widget.onPressed != null) widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (isInteractive) setState(() => _isPressed = false);
      },
      child: Transform.translate(
        offset: isPressedNow ? const Offset(2.5, 2.5) : Offset.zero,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: buttonBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 2.5,
            ),
            boxShadow: [
              if (!isPressedNow)
                BoxShadow(
                  color: borderColor,
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'BebasNeue',
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
