import 'package:flutter/material.dart';

import '../models/echo.dart';
import '../models/freshness.dart';
import '../theme/app_theme.dart';
import 'freshness_badge.dart';

class EchoCard extends StatelessWidget {
  const EchoCard({
    super.key,
    required this.echo,
    required this.onStillTrue,
    required this.onFixed,
    this.showLocation = false,
    this.showActions = true,
    this.onTap,
  });

  final Echo echo;
  final VoidCallback onStillTrue;
  final VoidCallback onFixed;
  final bool showLocation;
  final bool showActions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Confirmed-ago, not posted-ago: this is the same clock the decay
    // formula uses, so the chip and the reliability number stay in sync.
    final age = _relativeTime(echo.lastConfirmedAt);
    final freshness = echo.freshness();
    final reliability = echo.reliability();
    final isOutdated = freshness == EchoFreshness.outdated;
    final freshnessTone = switch (freshness) {
      EchoFreshness.fresh => EchoColors.success,
      EchoFreshness.aging => EchoColors.warning,
      EchoFreshness.outdated => EchoColors.danger,
    };

    // Outdated Echoes are visually deprioritized: they stay visible (a
    // student should still be able to confirm or dismiss them) but read as
    // less prominent than fresh, trustworthy ones.
    return Opacity(
      opacity: isOutdated ? 0.7 : 1.0,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isOutdated
                    ? EchoColors.danger.withOpacity(0.18)
                    : Colors.black.withOpacity(0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(echo.category.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        echo.title.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    FreshnessBadge(freshness: freshness),
                  ],
                ),
                if (showLocation) ...[
                  const SizedBox(height: 8),
                  Text(
                    echo.location.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EchoColors.indigo,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  '"${echo.description}"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.verified_rounded,
                      label: '$reliability% reliability',
                      color: freshnessTone,
                    ),
                    _MetaChip(
                      icon: Icons.people_alt_rounded,
                      label: '${echo.confirmations} confirmed',
                    ),
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: age,
                    ),
                  ],
                ),
                if (showActions) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Still true, confirm this echo',
                          child: FilledButton(
                            onPressed: onStillTrue,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEEF2FF),
                              foregroundColor: EchoColors.indigo,
                            ),
                            child: const Text('STILL TRUE'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Fixed, mark this echo as resolved',
                          child: OutlinedButton(
                            onPressed: onFixed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EchoColors.success,
                              side: const BorderSide(color: EchoColors.success),
                            ),
                            child: const Text('FIXED'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime since) {
    final delta = DateTime.now().difference(since);
    if (delta.inMinutes < 60) {
      final mins = delta.inMinutes.clamp(1, 59);
      return '$mins min ago';
    }
    if (delta.inHours < 24) {
      return '${delta.inHours} ${delta.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    return '${delta.inDays} ${delta.inDays == 1 ? 'day' : 'days'} ago';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? EchoColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? EchoColors.canvas,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tone),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tone),
          ),
        ],
      ),
    );
  }
}
