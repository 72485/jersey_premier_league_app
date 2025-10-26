import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTapCallback; // New optional callback

  // ⚡ FIX: Mark the constructor as const
  const GridItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // 1. Execute the provided callback first (e.g., navigation)
          onTapCallback?.call();

          // 2. Fallback/default action: show SnackBar if no specific callback was provided
          if (onTapCallback == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tapped on $title'),
                duration: const Duration(milliseconds: 800),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            // ⚡ FIX: Set mainAxisAlignment to spaceBetween or start to better utilize space
            mainAxisAlignment: MainAxisAlignment.start, // Changed from center to start
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Icon(icon, size: 40, color: Colors.white), // Slightly reduce icon size for safety (from 48 to 40)
              const SizedBox(height: 8), // Reduce spacing slightly

              // ⚡ FIX: Use an Expanded/Flexible widget around the text
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2, // Ensure it doesn't try to grow endlessly
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Slightly reduce font size for safety (from 18 to 16)
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
