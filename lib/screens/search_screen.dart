import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../models/campus_location.dart';
import '../models/echo.dart';
import '../models/echo_category.dart';
import '../models/freshness.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/echo_snack.dart';
import 'echo_detail_screen.dart';
import 'location_detail_screen.dart';

enum _SearchFilter {
  all,
  needsAttention,
  wifi,
  equipment,
  electricity,
  food,
  maintenance,
  other;

  String get label {
    switch (this) {
      case _SearchFilter.all:
        return 'All';
      case _SearchFilter.needsAttention:
        return 'Needs Attention';
      case _SearchFilter.wifi:
        return 'Wi-Fi';
      case _SearchFilter.equipment:
        return 'Equipment';
      case _SearchFilter.electricity:
        return 'Electricity';
      case _SearchFilter.food:
        return 'Food';
      case _SearchFilter.maintenance:
        return 'Maintenance';
      case _SearchFilter.other:
        return 'Other';
    }
  }

  EchoCategory? get category {
    switch (this) {
      case _SearchFilter.wifi:
        return EchoCategory.wifi;
      case _SearchFilter.equipment:
        return EchoCategory.equipment;
      case _SearchFilter.electricity:
        return EchoCategory.electricity;
      case _SearchFilter.food:
        return EchoCategory.food;
      case _SearchFilter.maintenance:
        return EchoCategory.maintenance;
      case _SearchFilter.other:
        return EchoCategory.other;
      case _SearchFilter.all:
      case _SearchFilter.needsAttention:
        return null;
    }
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  _SearchFilter _filter = _SearchFilter.all;

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = EchoScope.of(context);
    final query = _query.text.trim().toLowerCase();
    final hasQuery = query.isNotEmpty;
    final hasFilter = _filter != _SearchFilter.all;

    final matchingLocations = hasQuery
        ? repo.locations
            .where((location) =>
                location.name.toLowerCase().contains(query) ||
                location.building.toLowerCase().contains(query))
            .toList()
        : <CampusLocation>[];

    final matchingEchoes = (hasQuery || hasFilter)
        ? repo.activeEchoes.where((echo) => _matchesFilter(echo) && _matchesQuery(echo, query)).toList()
        : <Echo>[];

    final showEmptyPrompt = !hasQuery && !hasFilter;

    return Scaffold(
      appBar: AppBar(title: const Text('SEARCH ECHO')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Semantics(
                label: 'Search locations and Echoes',
                textField: true,
                child: TextField(
                  controller: _query,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search locations or observations…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: hasQuery
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Clear search',
                            onPressed: () => _query.clear(),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _SearchFilter.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _SearchFilter.values[index];
                  final selected = filter == _filter;
                  return Semantics(
                    button: true,
                    label: 'Filter by ${filter.label}',
                    child: ChoiceChip(
                      label: Text(filter.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = filter),
                      selectedColor: const Color(0xFFEEF2FF),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected ? EchoColors.indigo : EchoColors.ink,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  if (showEmptyPrompt)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icon: Icons.travel_explore_rounded,
                        title: 'Search ECHO',
                        message: 'Type to search locations and observations, or pick a filter above.',
                      ),
                    ),
                  if (matchingLocations.isNotEmpty) ...[
                    Text('LOCATIONS', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 10),
                    ...matchingLocations.map((location) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LocationResultTile(
                            location: location,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocationDetailScreen(location: location),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 18),
                  ],
                  if (matchingEchoes.isNotEmpty) ...[
                    Text('OBSERVATIONS', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 10),
                    ...matchingEchoes.map((echo) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: EchoCard(
                            echo: echo,
                            showLocation: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EchoDetailScreen(echoId: echo.id),
                              ),
                            ),
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
                  ],
                  if (!showEmptyPrompt && matchingLocations.isEmpty && matchingEchoes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No matches',
                        message: 'Try a different search term or filter.',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(Echo echo) {
    if (_filter == _SearchFilter.all) return true;
    if (_filter == _SearchFilter.needsAttention) {
      return echo.freshness() == EchoFreshness.outdated || echo.reliability() < 50;
    }
    return echo.category == _filter.category;
  }

  bool _matchesQuery(Echo echo, String query) {
    if (query.isEmpty) return true;
    final haystack = '${echo.title} ${echo.description} ${echo.location.name}'.toLowerCase();
    return haystack.contains(query);
  }
}

class _LocationResultTile extends StatelessWidget {
  const _LocationResultTile({required this.location, required this.onTap});

  final CampusLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${location.label}, ${location.shortHint}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: Row(
              children: [
                Icon(location.icon, color: EchoColors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.label, style: Theme.of(context).textTheme.titleSmall),
                      Text(location.shortHint, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: EchoColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
