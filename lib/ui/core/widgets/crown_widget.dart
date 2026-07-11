import 'package:material_ui/material_ui.dart';

class CrownWidget extends StatelessWidget {
  const CrownWidget({super.key, required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    const double outlineOffset = 1.8;
    // Using the image's built-in padding, we can size the image larger to fill the tile
    final double innerSize = size;
    final double centerOffset = 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Black outline/shadow behind the main image in 8 directions
          for (double dx = -outlineOffset; dx <= outlineOffset; dx += outlineOffset)
            for (double dy = -outlineOffset; dy <= outlineOffset; dy += outlineOffset)
              if (dx != 0 || dy != 0)
                Positioned(
                  left: centerOffset + dx,
                  top: centerOffset + dy,
                  child: Image.asset(
                    'assets/crown.png',
                    width: innerSize,
                    height: innerSize,
                    fit: BoxFit.contain,
                    color: const Color(0xFF000000), // Solid black
                  ),
                ),
          // Main crown image
          Positioned(
            left: centerOffset,
            top: centerOffset,
            child: Image.asset(
              'assets/crown.png',
              width: innerSize,
              height: innerSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
