import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Offline. Showing campus information stored on this device.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 18, color: EchoColors.indigo),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Offline — showing campus information stored on this device',
                style: TextStyle(
                  color: EchoColors.indigo,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
