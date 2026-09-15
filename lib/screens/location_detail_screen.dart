import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../models/campus_location.dart';
import '../models/echo.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_card.dart';
import '../widgets/echo_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/health_badge.dart';
import '../widgets/summary_card.dart';
import 'add_echo_screen.dart';
import 'echo_detail_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  const LocationDetailScreen({super.key, required this.location});

  final CampusLocation location;

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  bool _showBriefing = false;

  @override
  Widget build(BuildContext context) {
    final repo = EchoScope.of(context);
    final location = widget.location;
    final health = repo.healthFor(location);
    final active = repo.activeFor(location);
    final resolved = repo.resolvedFor(location);

    return Scaffold(
      appBar: AppBar(
        title: Text(location.labelUpper),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: EchoColors.indigo.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.labelUpper,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'CAMPUS HEALTH',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: EchoColors.muted,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${health.score}/100',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
                HealthBadge(snapshot: health),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'What should I know? Generate a local summary of active echoes.',
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showBriefing = true),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('✨ What should I know?'),
            ),
          ),
          if (_showBriefing) ...[
            const SizedBox(height: 12),
            SummaryCard(summary: repo.briefingFor(location)),
          ],
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Add Echo for ${location.label}',
            child: FilledButton.icon(
              onPressed: () async {
                final posted = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AddEchoScreen(initialLocation: location),
                  ),
                );
                if (posted == true && context.mounted) {
                  showEchoSnack(context, '✓ Echo added successfully');
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('+ Add Echo'),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Things you should know',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (active.isEmpty)
            const EmptyState(
              icon: Icons.spa_rounded,
              title: 'No active echoes',
              message: 'Nothing urgent here right now. Add an observation if you notice something.',
            )
          else
            ...active.map((echo) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: EchoCard(
                    echo: echo,
                    onTap: () => _openDetail(echo),
                    onStillTrue: () {
                      repo.confirmStillTrue(echo.id);
                      showEchoSnack(context, '✓ Echo confirmed');
                    },
                    onFixed: () {
                      repo.markResolved(echo.id);
                      showEchoSnack(context, '✓ Marked as resolved');
                    },
                  ),
                )),
          if (resolved.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recently resolved',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ...resolved.map((echo) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Opacity(
                    opacity: 0.78,
                    child: EchoCard(
                      echo: echo,
                      showActions: false,
                      onStillTrue: () {},
                      onFixed: () {},
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  void _openDetail(Echo echo) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EchoDetailScreen(echoId: echo.id)),
    );
  }
}
