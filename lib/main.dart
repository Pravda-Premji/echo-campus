import 'package:flutter/material.dart';

import 'data/echo_repository.dart';
import 'data/echo_scope.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(EchoApp(repository: EchoRepository()));
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key, required this.repository});

  final EchoRepository repository;

  @override
  Widget build(BuildContext context) {
    return EchoScope(
      repository: repository,
      child: AnimatedBuilder(
        animation: repository,
        builder: (context, _) {
          return MaterialApp(
            title: 'ECHO — The Invisible Campus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(largeText: repository.largeText),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
