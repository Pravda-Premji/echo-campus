import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../models/location_category.dart';
import '../theme/app_theme.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _name = TextEditingController();
  final _building = TextEditingController();
  final _floor = TextEditingController();
  LocationCategory _category = LocationCategory.classroom;
  String? _nameError;
  String? _buildingError;

  @override
  void dispose() {
    _name.dispose();
    _building.dispose();
    _floor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADD LOCATION')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Add a campus location',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a place other students can post Echoes about — a lab, a classroom, anywhere on campus.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Text('Location name', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Semantics(
            label: 'Location name',
            textField: true,
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Example: CSE Lab 305',
                errorText: _nameError,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Building / area', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Semantics(
            label: 'Building or area',
            textField: true,
            child: TextField(
              controller: _building,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Example: Block C',
                errorText: _buildingError,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Floor (optional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Semantics(
            label: 'Floor, optional',
            textField: true,
            child: TextField(
              controller: _floor,
              decoration: const InputDecoration(hintText: 'Example: 3'),
            ),
          ),
          const SizedBox(height: 20),
          Text('Location type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LocationCategory.values.map((category) {
              final selected = category == _category;
              return ChoiceChip(
                label: Text(category.label),
                selected: selected,
                onSelected: (_) => setState(() => _category = category),
                selectedColor: const Color(0xFFEEF2FF),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? EchoColors.indigo : EchoColors.ink,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Semantics(
            button: true,
            label: 'Save location',
            child: FilledButton(
              onPressed: _save,
              child: const Text('SAVE LOCATION'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    final building = _building.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Give this location a name.' : null;
      _buildingError = building.isEmpty ? 'Which building or area is this in?' : null;
    });
    if (_nameError != null || _buildingError != null) return;

    final location = EchoScope.of(context).addLocation(
      name: name,
      building: building,
      floor: _floor.text,
      category: _category,
    );
    Navigator.of(context).pop(location);
  }
}
