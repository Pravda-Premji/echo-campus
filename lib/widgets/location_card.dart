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
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final CampusLocation location;
  final int activeCount;
  final HealthSnapshot health;
  final VoidCallback onTap;
  final bool isFavorite;

  /// When provided, a favourite-toggle star is shown on the card.
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final echoLabel = activeCount == 1 ? '1 active echo' : '$activeCount active echoes';

    return Semantics(
      button: true,
      label: '${location.label}. ${location.shortHint}. $echoLabel. '
          'Health ${health.score} of 100. ${health.label}.'
          '${isFavorite ? ' Favourited.' : ''}',
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 2),
                        Text(
                          location.shortHint,
                          style: Theme.of(context).textTheme.bodySmall,
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
                  if (onToggleFavorite != null)
                    Semantics(
                      button: true,
                      label: isFavorite
                          ? 'Remove ${location.label} from favourites'
                          : 'Add ${location.label} to favourites',
                      child: IconButton(
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFavorite ? EchoColors.warning : EchoColors.muted,
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.chevron_right_rounded, color: EchoColors.muted),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
