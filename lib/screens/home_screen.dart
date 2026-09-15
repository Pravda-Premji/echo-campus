import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../models/campus_location.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_snack.dart';
import '../widgets/location_card.dart';
import '../widgets/offline_banner.dart';
import 'add_echo_screen.dart';
import 'admin_dashboard_screen.dart';
import 'location_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = EchoScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ECHO',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              letterSpacing: 1.4,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'THE INVISIBLE CAMPUS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: EchoColors.purple,
                            ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Toggle larger text',
                  child: IconButton(
                    tooltip: 'Larger text',
                    onPressed: repo.toggleLargeText,
                    icon: Icon(
                      repo.largeText ? Icons.text_fields_rounded : Icons.format_size_rounded,
                      color: EchoColors.indigo,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Open admin dashboard',
                  child: IconButton(
                    tooltip: 'Admin mode',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings_rounded, color: EchoColors.indigo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const OfflineBanner(),
            const SizedBox(height: 24),
            Text(
              'What should you know?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover what other students noticed before you.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 22),
            Semantics(
              button: true,
              label: 'Add an Echo',
              child: FilledButton.icon(
                onPressed: () async {
                  final posted = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const AddEchoScreen()),
                  );
                  if (posted == true && context.mounted) {
                    showEchoSnack(context, '✓ Echo added successfully');
                  }
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('+ Add an Echo'),
              ),
            ),
            const SizedBox(height: 22),
            ...CampusLocation.values.map((location) {
              final active = repo.activeFor(location);
              final health = repo.healthFor(location);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: LocationCard(
                  location: location,
                  activeCount: active.length,
                  health: health,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LocationDetailScreen(location: location),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Information shouldn’t disappear just because the person who discovered it walked away.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
