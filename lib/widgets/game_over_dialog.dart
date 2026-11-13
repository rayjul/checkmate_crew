import 'package:flutter/material.dart';

/// The game over pop-up with "View board" and "Play again".
Future<void> showGameOverDialog(
  BuildContext context, {
  required String result,
  required VoidCallback onPlayAgain,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Game over'),
      content: Text(result),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('View board'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onPlayAgain();
          },
          child: const Text('Play again'),
        ),
      ],
    ),
  );
}
