import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../models/campus_location.dart';
import '../models/echo_category.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_snack.dart';
import '../widgets/empty_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = EchoScope.of(context);
    final locations = repo.locations;
    final activeEchoes = repo.activeEchoes;
    final resolvedEchoes = repo.resolvedEchoes;

    final urgent = activeEchoes.where((echo) {
      final health = repo.healthFor(echo.location).score;
      return health < 50 || echo.reliability() >= 85;
    }).length;
    final active = activeEchoes.length;
    final resolved = resolvedEchoes.length;
    final total = active + resolved;

    final healthScores = locations.map((location) => repo.healthFor(location).score).toList();
    final avgHealth = healthScores.isEmpty
        ? 100
        : (healthScores.reduce((a, b) => a + b) / healthScores.length).round();

    final needsAttention = locations.where((location) => repo.healthFor(location).score < 75).toList()
      ..sort((a, b) => repo.healthFor(a).score.compareTo(repo.healthFor(b).score));

    final mostReported = [...locations]
      ..sort((a, b) => repo.historyFor(b).length.compareTo(repo.historyFor(a).length));
    final topReported = mostReported.where((location) => repo.historyFor(location).isNotEmpty).take(3).toList();

    final categoryCounts = <EchoCategory, int>{};
    for (final echo in activeEchoes) {
      categoryCounts[echo.category] = (categoryCounts[echo.category] ?? 0) + 1;
    }
    final maxCategoryCount = categoryCounts.values.fold(0, (max, count) => count > max ? count : max);

    final newLast24h = repo.echoes.where((echo) => DateTime.now().difference(echo.createdAt).inHours < 24).length;
    final newPrevious24h = repo.echoes.where((echo) {
      final age = DateTime.now().difference(echo.createdAt).inHours;
      return age >= 24 && age < 48;
    }).length;

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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  mark: 'Total Echoes',
                  value: '$total',
                  icon: Icons.dataset_rounded,
                  color: EchoColors.indigo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  mark: 'Campus Health',
                  value: '$avgHealth/100',
                  icon: Icons.favorite_rounded,
                  color: EchoColors.purple,
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
                const SizedBox(height: 10),
                Text(
                  newLast24h >= newPrevious24h
                      ? '$newLast24h new report${newLast24h == 1 ? '' : 's'} in the last 24h (up from $newPrevious24h the day before).'
                      : '$newLast24h new report${newLast24h == 1 ? '' : 's'} in the last 24h (down from $newPrevious24h the day before).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (needsAttention.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('LOCATIONS NEEDING ATTENTION', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            ...needsAttention.map((location) => _LocationStatRow(
                  location: location,
                  trailing: '${repo.healthFor(location).score}/100',
                  tone: EchoColors.danger,
                )),
          ],
          if (topReported.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('MOST REPORTED LOCATIONS', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            ...topReported.map((location) => _LocationStatRow(
                  location: location,
                  trailing: '${repo.historyFor(location).length} echoes',
                  tone: EchoColors.indigo,
                )),
          ],
          if (categoryCounts.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('CATEGORY DISTRIBUTION', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              child: Column(
                children: EchoCategory.values.where((c) => categoryCounts.containsKey(c)).map((category) {
                  final count = categoryCounts[category]!;
                  final fraction = maxCategoryCount == 0 ? 0.0 : count / maxCategoryCount;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Semantics(
                      label: '${category.label}: $count active',
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text('${category.emoji} ${category.label}', style: Theme.of(context).textTheme.bodySmall),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) => Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: EchoColors.canvas,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  Container(
                                    height: 10,
                                    width: constraints.maxWidth * fraction,
                                    decoration: BoxDecoration(
                                      color: EchoColors.indigo,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$count', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Text('ACTIVE CAMPUS ISSUES', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (activeEchoes.isEmpty)
            const EmptyState(
              icon: Icons.verified_rounded,
              title: 'All clear',
              message: 'There are no active campus issues to resolve.',
            )
          else
            ...activeEchoes.map((echo) {
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
                        '${echo.location.label} · ${echo.reliability()}% reliability',
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

class _LocationStatRow extends StatelessWidget {
  const _LocationStatRow({required this.location, required this.trailing, required this.tone});

  final CampusLocation location;
  final String trailing;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${location.label}: $trailing',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Row(
            children: [
              Icon(location.icon, size: 18, color: tone),
              const SizedBox(width: 10),
              Expanded(child: Text(location.label, style: Theme.of(context).textTheme.bodyLarge)),
              Text(trailing, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: tone)),
            ],
          ),
        ),
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
