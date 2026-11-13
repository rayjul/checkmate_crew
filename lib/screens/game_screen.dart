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
  int _movesPlayed = 0;
  bool _allowPop = false;
  bool _leaveDialogOpen = false;

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _newGame() {
    _game.newGame();
    _movesPlayed = 0;
  }

  Future<void> _onMove({required ShortMove move}) async {
    final played = _game.tryMove(
      from: move.from,
      to: move.to,
      promotion: move.promotion?.name,
    );

    if (!played) return;
    _movesPlayed++;

    await _game.playComputerMove();

    if (_game.isGameOver && mounted) {
      showGameOverDialog(context, result: _game.status, onPlayAgain: _newGame);
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

    showGameOverDialog(context, result: _game.status, onPlayAgain: _newGame);
  }

  Future<void> _handleBack() async {
    if (_movesPlayed == 0 || _game.isGameOver) {
      Navigator.of(context).pop();
      return;
    }

    await _confirmLeave();
  }

  Future<void> _confirmLeave() async {
    if (_leaveDialogOpen) return;
    _leaveDialogOpen = true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave current game?'),
        content: const Text('Your current game will be lost if you leave.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Leave game'),
          ),
        ],
      ),
    );

    _leaveDialogOpen = false;
    if (shouldLeave != true || !mounted) return;

    _allowPop = true;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _movesPlayed == 0 || _game.isGameOver || _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _movesPlayed > 0 && !_game.isGameOver) {
          _confirmLeave();
        }
      },
      child: ListenableBuilder(
        listenable: _game,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: _handleBack,
            ),
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
                  onPressed: _newGame,
                ),
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
      ),
    );
  }
}
