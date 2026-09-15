import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_snack.dart';
import '../widgets/empty_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = EchoScope.of(context);
    final urgent = repo.activeEchoes.where((echo) {
      final health = repo.healthFor(echo.location).score;
      return health < 50 || echo.confidence >= 85;
    }).length;
    final active = repo.activeEchoes.length;
    final resolved = repo.resolvedEchoes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('ECHO ADMIN')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text('CAMPUS OVERVIEW', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  mark: 'Urgent',
                  value: '$urgent',
                  icon: Icons.priority_high_rounded,
                  color: EchoColors.danger,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  mark: 'Active',
                  value: '$active',
                  icon: Icons.graphic_eq_rounded,
                  color: EchoColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  mark: 'Resolved',
                  value: '$resolved',
                  icon: Icons.check_circle_rounded,
                  color: EchoColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAMPUS INSIGHT', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(
                  repo.campusInsight,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('ACTIVE CAMPUS ISSUES', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (repo.activeEchoes.isEmpty)
            const EmptyState(
              icon: Icons.verified_rounded,
              title: 'All clear',
              message: 'There are no active campus issues to resolve.',
            )
          else
            ...repo.activeEchoes.map((echo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(echo.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${echo.location.label} · ${echo.confidence}% confidence',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Semantics(
                          button: true,
                          label: 'Mark ${echo.title} as resolved',
                          child: FilledButton(
                            onPressed: () {
                              repo.markResolved(echo.id);
                              showEchoSnack(context, '✓ Issue marked as resolved');
                            },
                            child: const Text('MARK RESOLVED'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.mark,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String mark;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$mark $value',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              mark,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
