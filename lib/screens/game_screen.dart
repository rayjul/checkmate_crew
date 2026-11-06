import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

import '../game/game_controller.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _game = GameController();

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _onMove({required ShortMove move}) {
    final played = _game.tryMove(
      from: move.from,
      to: move.to,
      promotion: move.promotion?.name,
    );
    if (played && _game.isGameOver) {
      showGameOverDialog(context, result: _game.status, onPlayAgain: _game.newGame);
    }
  }

  // Ask first, then the player to move gives up.
  Future<void> _confirmResign() async {
    final winner = _game.sideToMove == 'White' ? 'Black' : 'White';
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${_game.sideToMove} resigns?'),
        content: Text('$winner will win the game.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Resign'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    _game.resign();
    showGameOverDialog(context, result: _game.status, onPlayAgain: _game.newGame);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the screen every time the controller calls notifyListeners().
    return ListenableBuilder(
      listenable: _game,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Checkmate Crew'),
          actions: [
            if (!_game.isGameOver)
              IconButton(tooltip: 'Resign', icon: const Icon(Icons.flag), onPressed: _confirmResign)
            else
              IconButton(tooltip: 'New game', icon: const Icon(Icons.refresh), onPressed: _game.newGame),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_game.status, style: const TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SimpleChessBoard(
                    fen: _game.fen,
                    whitePlayerType: PlayerType.human,
                    blackPlayerType: PlayerType.human,
                    onMove: _onMove,
                    onPromote: () async => PieceType.queen, // always queen for now
                    onPromotionCommited: ({required moveDone, required pieceType}) {
                      moveDone.promotion = pieceType;
                      _onMove(move: moveDone);
                    },
                    onTap: ({required cellCoordinate}) {},
                    chessBoardColors: ChessBoardColors(),
                    cellHighlights: const {},
                    showPossibleMoves: true,
                    isInteractive: !_game.isGameOver,
                    nonInteractiveText: 'GAME OVER',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
