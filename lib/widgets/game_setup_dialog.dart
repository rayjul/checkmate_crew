import 'package:flutter/material.dart';

import '../models/game_setup_options.dart';

Future<GameSetupOptions?> showGameSetupDialog(
  BuildContext context, {
  required String modeTitle,
  required GameSetupOptions initialOptions,
  bool settingsOnly = false,
  bool showComputerDifficulty = false,
}) {
  return showDialog<GameSetupOptions>(
    context: context,
    builder: (_) => _GameSetupDialog(
      modeTitle: modeTitle,
      initialOptions: initialOptions,
      settingsOnly: settingsOnly,
      showComputerDifficulty: showComputerDifficulty,
    ),
  );
}

class _GameSetupDialog extends StatefulWidget {
  const _GameSetupDialog({
    required this.modeTitle,
    required this.initialOptions,
    required this.settingsOnly,
    required this.showComputerDifficulty,
  });

  final String modeTitle;
  final GameSetupOptions initialOptions;
  final bool settingsOnly;
  final bool showComputerDifficulty;

  @override
  State<_GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<_GameSetupDialog> {
  late bool _useTimer = widget.initialOptions.useTimer;
  late Duration _timeLimit = widget.initialOptions.timeLimit;
  late ChessBoardScheme _boardScheme = widget.initialOptions.boardScheme;
  late int _skillLevel = widget.initialOptions.skillLevel;

  static const _timeLimits = [
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
  ];

  void _complete() {
    Navigator.of(context).pop(
      GameSetupOptions(
        useTimer: _useTimer,
        timeLimit: _timeLimit,
        boardScheme: _boardScheme,
        skillLevel: _skillLevel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.settingsOnly ? 'Settings' : widget.modeTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use a timer'),
              value: _useTimer,
              onChanged: (value) => setState(() => _useTimer = value),
            ),
            DropdownButtonFormField<Duration>(
              initialValue: _timeLimit,
              decoration: const InputDecoration(labelText: 'Time per player'),
              items: _timeLimits
                  .map(
                    (duration) => DropdownMenuItem(
                      value: duration,
                      child: Text('${duration.inMinutes} minutes'),
                    ),
                  )
                  .toList(),
              onChanged: _useTimer
                  ? (value) {
                      if (value != null) {
                        setState(() => _timeLimit = value);
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChessBoardScheme>(
              initialValue: _boardScheme,
              decoration: const InputDecoration(labelText: 'Board colors'),
              items: ChessBoardScheme.values
                  .map(
                    (scheme) => DropdownMenuItem(
                      value: scheme,
                      child: Text(scheme.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _boardScheme = value);
                }
              },
            ),
            if (widget.showComputerDifficulty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Computer difficulty'),
                  Text('Level $_skillLevel / 20'),
                ],
              ),
              Slider(
                value: _skillLevel.toDouble(),
                min: 0,
                max: 20,
                divisions: 20,
                label: '$_skillLevel',
                semanticFormatterCallback: (value) =>
                    'Stockfish level ${value.round()} of 20',
                onChanged: (value) {
                  setState(() => _skillLevel = value.round());
                },
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Easier'), Text('Harder')],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _complete,
          child: Text(widget.settingsOnly ? 'Save' : 'Start game'),
        ),
      ],
    );
  }
}
