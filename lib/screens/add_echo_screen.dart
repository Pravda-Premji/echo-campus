import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../models/campus_location.dart';
import '../models/echo.dart';
import '../models/echo_category.dart';
import '../models/echo_severity.dart';
import '../services/duplicate_detector.dart';
import '../services/smart_classifier.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_snack.dart';
import 'add_location_screen.dart';

enum _DuplicateChoice { confirmExisting, postAnyway }

class AddEchoScreen extends StatefulWidget {
  const AddEchoScreen({super.key, this.initialLocation});

  final CampusLocation? initialLocation;

  @override
  State<AddEchoScreen> createState() => _AddEchoScreenState();
}

class _AddEchoScreenState extends State<AddEchoScreen> {
  static const _minDescriptionLength = 8;

  final _classifier = const SmartClassifier();
  final _duplicateDetector = const DuplicateDetector();
  final _observation = TextEditingController();
  CampusLocation? _location;
  EchoCategory _category = EchoCategory.other;
  EchoSeverity? _severity;
  bool _userPickedCategory = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _observation.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final suggested = _classifier.classify(_observation.text);
    if (!_userPickedCategory) {
      setState(() => _category = suggested);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _observation.removeListener(_onTextChanged);
    _observation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = EchoScope.of(context);
    _location ??= widget.initialLocation ?? repo.locations.first;
    final suggested = _classifier.classify(_observation.text);

    return Scaffold(
      appBar: AppBar(title: const Text('NEW ECHO')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'What did you notice?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your observation could help the next student.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Semantics(
            label: 'Observation text',
            textField: true,
            child: TextField(
              controller: _observation,
              minLines: 6,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Example: Projector HDMI 1 is not working...',
                alignLabelWithHint: true,
                errorText: _validationError,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_observation.text.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '✨ Smart classification: ${suggested.label}',
                style: const TextStyle(
                  color: EchoColors.indigo,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text('Location', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<CampusLocation>(
            value: _location,
            items: repo.locations
                .map(
                  (location) => DropdownMenuItem(
                    value: location,
                    child: Text(location.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _location = value);
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              label: 'Add a new location',
              child: TextButton.icon(
                onPressed: _addLocation,
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: const Text('Add a new location'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EchoCategory.values.map((category) {
              final selected = category == _category;
              return ChoiceChip(
                label: Text('${category.emoji} ${category.label}'),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _category = category;
                    _userPickedCategory = true;
                  });
                },
                selectedColor: const Color(0xFFEEF2FF),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? EchoColors.indigo : EchoColors.ink,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Severity (optional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EchoSeverity.values.map((severity) {
              final selected = severity == _severity;
              return ChoiceChip(
                label: Text(severity.label),
                selected: selected,
                onSelected: (_) => setState(() => _severity = selected ? null : severity),
                selectedColor: severity.color.withOpacity(0.14),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? severity.color : EchoColors.ink,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Semantics(
            button: true,
            label: 'Post Echo',
            child: FilledButton(
              onPressed: _post,
              child: const Text('POST ECHO'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addLocation() async {
    final location = await Navigator.of(context).push<CampusLocation>(
      MaterialPageRoute(builder: (_) => const AddLocationScreen()),
    );
    if (location != null && mounted) {
      setState(() => _location = location);
      showEchoSnack(context, '✓ ${location.name} added');
    }
  }

  Future<void> _post() async {
    final text = _observation.text.trim();
    if (text.isEmpty) {
      setState(() => _validationError = 'Please describe what you noticed.');
      return;
    }
    if (text.length < _minDescriptionLength) {
      setState(() => _validationError = 'A few more details would help — try at least $_minDescriptionLength characters.');
      return;
    }
    setState(() => _validationError = null);

    final repo = EchoScope.of(context);
    final location = _location!;
    final duplicate = _duplicateDetector.findLikelyDuplicate(text, repo.activeFor(location));

    if (duplicate != null) {
      final choice = await _askAboutDuplicate(duplicate);
      if (choice == null) return; // user cancelled, stay on the form
      if (choice == _DuplicateChoice.confirmExisting) {
        repo.confirmStillTrue(duplicate.id);
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      // Otherwise: post anyway, falls through below.
    }

    final title = _titleFrom(text);
    repo.addEcho(
      title: title,
      description: text,
      category: _category,
      location: location,
      severity: _severity,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<_DuplicateChoice?> _askAboutDuplicate(Echo duplicate) {
    return showDialog<_DuplicateChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('This looks similar to an existing report'),
        content: Text(
          '"${duplicate.title}" is already active at this location:\n\n'
          '"${duplicate.description}"\n\n'
          'Would you like to confirm that report instead of posting a new one?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_DuplicateChoice.postAnyway),
            child: const Text('POST ANYWAY'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_DuplicateChoice.confirmExisting),
            child: const Text('CONFIRM EXISTING'),
          ),
        ],
      ),
    );
  }

  String _titleFrom(String text) {
    final firstLine = text.split('\n').first.trim();
    if (firstLine.length <= 48) return firstLine;
    return '${firstLine.substring(0, 45).trim()}...';
  }
}
