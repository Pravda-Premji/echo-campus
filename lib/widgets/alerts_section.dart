import 'package:flutter/material.dart';

import '../services/alerts_service.dart';
import '../theme/app_theme.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key, required this.alerts, required this.onTapAlert, this.maxShown = 3});

  final List<CampusAlert> alerts;
  final ValueChanged<CampusAlert> onTapAlert;
  final int maxShown;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    final shown = alerts.take(maxShown).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('IMPORTANT UPDATES', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        ...shown.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AlertTile(alert: alert, onTap: () => onTapAlert(alert)),
            )),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onTap});

  final CampusAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, tone) = switch (alert.kind) {
      AlertKind.lowReliability => (Icons.trending_down_rounded, EchoColors.danger),
      AlertKind.highlyConfirmed => (Icons.groups_rounded, EchoColors.warning),
      AlertKind.newUrgent => (Icons.fiber_new_rounded, EchoColors.indigo),
      AlertKind.recentlyResolved => (Icons.check_circle_rounded, EchoColors.success),
    };

    return Semantics(
      button: true,
      label: alert.message,
      child: Material(
        color: tone.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: tone),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tone,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
