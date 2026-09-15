import 'package:flutter/material.dart';

/// The kind of place a [CampusLocation] is — used for its icon and to help
/// users pick a sensible category when adding a new location.
enum LocationCategory {
  lab,
  classroom,
  library,
  canteen,
  hall,
  hostel,
  outdoor,
  other;

  String get label {
    switch (this) {
      case LocationCategory.lab:
        return 'Lab';
      case LocationCategory.classroom:
        return 'Classroom';
      case LocationCategory.library:
        return 'Library';
      case LocationCategory.canteen:
        return 'Canteen';
      case LocationCategory.hall:
        return 'Hall';
      case LocationCategory.hostel:
        return 'Hostel';
      case LocationCategory.outdoor:
        return 'Outdoor';
      case LocationCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationCategory.lab:
        return Icons.science_rounded;
      case LocationCategory.classroom:
        return Icons.school_rounded;
      case LocationCategory.library:
        return Icons.menu_book_rounded;
      case LocationCategory.canteen:
        return Icons.restaurant_rounded;
      case LocationCategory.hall:
        return Icons.meeting_room_rounded;
      case LocationCategory.hostel:
        return Icons.apartment_rounded;
      case LocationCategory.outdoor:
        return Icons.park_rounded;
      case LocationCategory.other:
        return Icons.place_rounded;
    }
  }
}
