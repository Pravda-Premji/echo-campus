import 'package:flutter/material.dart';

enum EchoCategory {
  wifi,
  equipment,
  electricity,
  food,
  maintenance,
  other;

  String get label {
    switch (this) {
      case EchoCategory.wifi:
        return 'Wi-Fi';
      case EchoCategory.equipment:
        return 'Equipment';
      case EchoCategory.electricity:
        return 'Electricity';
      case EchoCategory.food:
        return 'Food';
      case EchoCategory.maintenance:
        return 'Maintenance';
      case EchoCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case EchoCategory.wifi:
        return Icons.wifi_rounded;
      case EchoCategory.equipment:
        return Icons.videocam_rounded;
      case EchoCategory.electricity:
        return Icons.power_rounded;
      case EchoCategory.food:
        return Icons.restaurant_rounded;
      case EchoCategory.maintenance:
        return Icons.handyman_rounded;
      case EchoCategory.other:
        return Icons.info_outline_rounded;
    }
  }

  String get emoji {
    switch (this) {
      case EchoCategory.wifi:
        return '📡';
      case EchoCategory.equipment:
        return '📽';
      case EchoCategory.electricity:
        return '🔌';
      case EchoCategory.food:
        return '🍽️';
      case EchoCategory.maintenance:
        return '🛠️';
      case EchoCategory.other:
        return '💡';
    }
  }
}
