import 'package:flutter/material.dart';

import '../data/echo_scope.dart';
import '../models/campus_location.dart';
import '../models/echo_category.dart';
import '../services/smart_classifier.dart';
import '../theme/app_theme.dart';
import '../widgets/echo_snack.dart';

class AddEchoScreen extends StatefulWidget {
  const AddEchoScreen({super.key, this.initialLocation});

  final CampusLocation? initialLocation;

  @override
  State<AddEchoScreen> createState() => _AddEchoScreenState();
}

class _AddEchoScreenState extends State<AddEchoScreen> {
  final _classifier = const SmartClassifier();
  final _observation = TextEditingController();
  late CampusLocation _location;
  EchoCategory _category = EchoCategory.other;
  bool _userPickedCategory = false;

  @override
  void initState() {
    super.initState();
    _location = widget.initialLocation ?? CampusLocation.lab204;
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
          TextField(
            controller: _observation,
            minLines: 6,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Example: Projector HDMI 1 is not working...',
              alignLabelWithHint: true,
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
            items: CampusLocation.values
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
          const SizedBox(height: 20),
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

  void _post() {
    final text = _observation.text.trim();
    if (text.isEmpty) {
      showEchoSnack(context, 'Please describe what you noticed.');
      return;
    }
    final title = _titleFrom(text);
    EchoScope.of(context).addEcho(
      title: title,
      description: text,
      category: _category,
      location: _location,
    );
    Navigator.of(context).pop(true);
  }

  String _titleFrom(String text) {
    final firstLine = text.split('\n').first.trim();
    if (firstLine.length <= 48) return firstLine;
    return '${firstLine.substring(0, 45).trim()}...';
  }
}
