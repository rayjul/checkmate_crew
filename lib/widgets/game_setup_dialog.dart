import 'package:flutter/material.dart';

import '../models/game_setup_options.dart';

Future<GameSetupOptions?> showGameSetupDialog(
  BuildContext context, {
  required String modeTitle,
  required GameSetupOptions initialOptions,
  bool settingsOnly = false,
}) {
  return showDialog<GameSetupOptions>(
    context: context,
    builder: (_) => _GameSetupDialog(
      modeTitle: modeTitle,
      initialOptions: initialOptions,
      settingsOnly: settingsOnly,
    ),
  );
}

class _GameSetupDialog extends StatefulWidget {
  const _GameSetupDialog({
    required this.modeTitle,
    required this.initialOptions,
    required this.settingsOnly,
  });

  final String modeTitle;
  final GameSetupOptions initialOptions;
  final bool settingsOnly;

  @override
  State<_GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<_GameSetupDialog> {
  late bool _useTimer = widget.initialOptions.useTimer;
  late Duration _timeLimit = widget.initialOptions.timeLimit;
  late ChessBoardScheme _boardScheme = widget.initialOptions.boardScheme;

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
