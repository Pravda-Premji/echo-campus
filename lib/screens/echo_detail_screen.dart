import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_card.dart';
import '../widgets/echo_snack.dart';
import '../widgets/empty_state.dart';

class EchoDetailScreen extends StatelessWidget {
  const EchoDetailScreen({super.key, required this.echoId});

  final String echoId;

  @override
  Widget build(BuildContext context) {
    final repo = EchoScope.of(context);
    final matches = repo.echoes.where((echo) => echo.id == echoId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('ECHO')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Echo not found',
            message: 'This observation is no longer available on this device.',
          ),
        ),
      );
    }
    final echo = matches.first;

    return Scaffold(
      appBar: AppBar(title: const Text('ECHO DETAILS')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            echo.location.labelUpper,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: EchoColors.purple,
                ),
          ),
          const SizedBox(height: 8),
          EchoCard(
            echo: echo,
            showLocation: true,
            showActions: !echo.resolved,
            onStillTrue: () {
              repo.confirmStillTrue(echo.id);
              showEchoSnack(context, '✓ Echo confirmed');
            },
            onFixed: () {
              repo.markResolved(echo.id);
              showEchoSnack(context, '✓ Marked as resolved');
            },
          ),
        ],
      ),
    );
  }
}
