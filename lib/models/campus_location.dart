import 'package:flutter/material.dart';

enum CampusLocation {
  lab204,
  library,
  canteen,
  seminarHall;

  String get id => name;

  String get label {
    switch (this) {
      case CampusLocation.lab204:
        return 'Lab 204';
      case CampusLocation.library:
        return 'Library';
      case CampusLocation.canteen:
        return 'Canteen';
      case CampusLocation.seminarHall:
        return 'Seminar Hall';
    }
  }

  String get labelUpper => label.toUpperCase();

  IconData get icon {
    switch (this) {
      case CampusLocation.lab204:
        return Icons.science_rounded;
      case CampusLocation.library:
        return Icons.menu_book_rounded;
      case CampusLocation.canteen:
        return Icons.restaurant_rounded;
      case CampusLocation.seminarHall:
        return Icons.meeting_room_rounded;
    }
  }

  String get shortHint {
    switch (this) {
      case CampusLocation.lab204:
        return 'Classrooms & lab equipment';
      case CampusLocation.library:
        return 'Study floors & reference section';
      case CampusLocation.canteen:
        return 'Counters, seating & wait times';
      case CampusLocation.seminarHall:
        return 'Events, AV & seating';
    }
  }
}
