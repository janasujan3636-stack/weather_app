import 'package:flutter/material.dart';
import 'glass_container.dart';

class WeatherInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtext;
  final Color iconColor;

  const WeatherInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtext,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
