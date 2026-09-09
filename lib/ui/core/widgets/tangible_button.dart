import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:queens/ui/core/theme/app_colors.dart';

class TangibleButton extends StatefulWidget {
  const TangibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.height = 56,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  State<TangibleButton> createState() => _TangibleButtonState();
}

class _TangibleButtonState extends State<TangibleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onPressed != null;
    final isPressedNow = _isPressed && isInteractive;

    final Color buttonBg = widget.backgroundColor ??
        (widget.isSecondary ? AppColors.surface : AppColors.primary);

    final Color textColor = widget.textColor ?? AppColors.headingDark;
    final Color borderColor = widget.borderColor ?? AppColors.border;

    return GestureDetector(
      onTapDown: (_) {
        if (isInteractive) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        }
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
      child: Opacity(
        opacity: isPressedNow ? 0.8 : 1.0,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: buttonBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
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
