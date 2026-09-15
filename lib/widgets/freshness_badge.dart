import 'package:flutter/material.dart';

import '../models/freshness.dart';
import '../theme/app_theme.dart';

class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({super.key, required this.freshness});

  final EchoFreshness freshness;

  @override
  Widget build(BuildContext context) {
    late final Color tone;
    late final IconData icon;
    late final String mark;
    switch (freshness) {
      case EchoFreshness.fresh:
        tone = EchoColors.success;
        icon = Icons.bolt_rounded;
        mark = 'Fresh';
      case EchoFreshness.aging:
        tone = EchoColors.warning;
        icon = Icons.schedule_rounded;
        mark = 'Aging';
      case EchoFreshness.outdated:
        tone = EchoColors.danger;
        icon = Icons.hourglass_bottom_rounded;
        mark = 'Possibly outdated';
    }

    return Semantics(
      label: freshness.semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: tone.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: tone),
            const SizedBox(width: 4),
            Text(
              mark,
              style: TextStyle(
                color: tone,
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
