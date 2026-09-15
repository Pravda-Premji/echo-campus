import 'package:flutter/material.dart';

import '../services/health_service.dart';
import '../theme/app_theme.dart';

class HealthBadge extends StatelessWidget {
  const HealthBadge({super.key, required this.snapshot});

  final HealthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final color = switch (snapshot.status) {
      HealthStatus.good => EchoColors.success,
      HealthStatus.attention => EchoColors.warning,
      HealthStatus.needsAttention => EchoColors.danger,
    };

    return Semantics(
      label: 'Campus health ${snapshot.score} out of 100, ${snapshot.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              snapshot.status == HealthStatus.good
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              snapshot.label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
