import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

/// Asks which piece a pawn becomes. Returns null if the player closes the dialog.
Future<PieceType?> showPromotionDialog(BuildContext context) {
  return showDialog<PieceType>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Promote pawn to'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (name, type) in [
            ('Queen', PieceType.queen),
            ('Rook', PieceType.rook),
            ('Bishop', PieceType.bishop),
            ('Knight', PieceType.knight),
          ])
            ListTile(
              title: Text(name),
              onTap: () => Navigator.of(dialogContext).pop(type),
            ),
        ],
      ),
    ),
  );
}
