import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

import '../game/game_controller.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.vsComputer = false, this.skillLevel = 3});

  /// True when Black is played by the computer.
  final bool vsComputer;

  /// Stockfish skill setting, from 0 (easiest) to 20 (strongest).
  final int skillLevel;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final _game = GameController(
    vsComputer: widget.vsComputer,
    skillLevel: widget.skillLevel,
  );

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  Future<void> _onMove({required ShortMove move}) async {
    final played = _game.tryMove(
      from: move.from,
      to: move.to,
      promotion: move.promotion?.name,
    );

    if (!played) return;

    await _game.playComputerMove();

    if (_game.isGameOver && mounted) {
      showGameOverDialog(
        context,
        result: _game.status,
        onPlayAgain: _game.newGame,
      );
    }
  }

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

    showGameOverDialog(
      context,
      result: _game.status,
      onPlayAgain: _game.newGame,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _game,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Checkmate Crew'),
          actions: [
            if (!_game.isGameOver)
              IconButton(
                tooltip: 'Resign',
                icon: const Icon(Icons.flag),
                onPressed: _game.isThinking ? null : _confirmResign,
              )
            else
              IconButton(
                tooltip: 'New game',
                icon: const Icon(Icons.refresh),
                onPressed: _game.newGame,
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_game.status, style: const TextStyle(fontSize: 20)),
            ),
            if (_game.vsComputer) _buildComputerDifficulty(),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SimpleChessBoard(
                    fen: _game.fen,
                    whitePlayerType: PlayerType.human,
                    blackPlayerType: _game.vsComputer
                        ? PlayerType.computer
                        : PlayerType.human,
                    engineThinking: _game.isThinking,
                    onMove: _onMove,
                    onPromote: () async => PieceType.queen,
                    onPromotionCommited:
                        ({required moveDone, required pieceType}) {
                          moveDone.promotion = pieceType;
                          _onMove(move: moveDone);
                        },
                    onTap: ({required cellCoordinate}) {},
                    chessBoardColors: ChessBoardColors(),
                    cellHighlights: const {},
                    showPossibleMoves: true,
                    isInteractive: !_game.isGameOver && !_game.isThinking,
                    nonInteractiveText: _game.isGameOver
                        ? 'GAME OVER'
                        : _game.isThinking
                        ? 'Computer is thinking'
                        : '',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComputerDifficulty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Computer difficulty',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Level ${_game.skillLevel} / 20'),
              ],
            ),
            Slider(
              value: _game.skillLevel.toDouble(),
              min: 0,
              max: 20,
              divisions: 20,
              label: '${_game.skillLevel}',
              semanticFormatterCallback: (value) =>
                  'Stockfish level ${value.round()} of 20',
              onChanged: _game.isThinking
                  ? null
                  : (value) => _game.setSkillLevel(value.round()),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Easier', style: TextStyle(color: Colors.black54)),
                Text('Harder', style: TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Changes take effect on the next computer move.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
