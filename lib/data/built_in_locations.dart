import '../models/campus_location.dart';
import '../models/location_category.dart';

/// The four demo locations ECHO ships with. These always exist — they are
/// the seed data for a first launch and a stable reference point for tests
/// — but users can add more locations of their own alongside them.
class BuiltInLocations {
  const BuiltInLocations._();

  static const lab204 = CampusLocation(
    id: 'lab204',
    name: 'Lab 204',
    building: 'Block A',
    floor: '2',
    category: LocationCategory.lab,
    isBuiltIn: true,
  );

  static const library = CampusLocation(
    id: 'library',
    name: 'Library',
    building: 'Central Library',
    category: LocationCategory.library,
    isBuiltIn: true,
  );

  static const canteen = CampusLocation(
    id: 'canteen',
    name: 'Canteen',
    building: 'Student Center',
    category: LocationCategory.canteen,
    isBuiltIn: true,
  );

  static const seminarHall = CampusLocation(
    id: 'seminarHall',
    name: 'Seminar Hall',
    building: 'Block B',
    category: LocationCategory.hall,
    isBuiltIn: true,
  );

  static List<CampusLocation> all() => [lab204, library, canteen, seminarHall];
}
