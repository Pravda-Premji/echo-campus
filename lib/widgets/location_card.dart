import 'package:flutter/material.dart';

import '../models/campus_location.dart';
import '../services/health_service.dart';
import '../theme/app_theme.dart';
import 'health_badge.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    required this.activeCount,
    required this.health,
    required this.onTap,
  });

  final CampusLocation location;
  final int activeCount;
  final HealthSnapshot health;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final echoLabel = activeCount == 1 ? '1 active echo' : '$activeCount active echoes';

    return Semantics(
      button: true,
      label: '${location.label}. $echoLabel. Health ${health.score} of 100. ${health.label}.',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: EchoColors.indigo.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [EchoColors.indigo, EchoColors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(location.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.labelUpper,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          echoLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Health: ${health.score}/100',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            HealthBadge(snapshot: health),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: EchoColors.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
