import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

import '../game/game_controller.dart';
import '../models/game_setup_options.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.vsComputer = false,
    this.skillLevel = 3,
    this.options = const GameSetupOptions(),
  });

  final bool vsComputer;
  final int skillLevel;
  final GameSetupOptions options;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final _game = GameController(
    vsComputer: widget.vsComputer,
    skillLevel: widget.skillLevel,
  );
  Timer? _clock;
  late Duration _whiteTime = widget.options.timeLimit;
  late Duration _blackTime = widget.options.timeLimit;
  String? _timedOutSide;
  int _movesPlayed = 0;
  bool _allowPop = false;
  bool _leaveDialogOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.options.useTimer) {
      _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tickClock());
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    _game.dispose();
    super.dispose();
  }

  void _tickClock() {
    if (!mounted ||
        _game.isGameOver ||
        _game.isThinking ||
        _timedOutSide != null) {
      return;
    }

    setState(() {
      if (_game.sideToMove == 'White') {
        _whiteTime -= const Duration(seconds: 1);
        if (_whiteTime.inSeconds <= 0) {
          _whiteTime = Duration.zero;
          _timedOutSide = 'White';
        }
      } else {
        _blackTime -= const Duration(seconds: 1);
        if (_blackTime.inSeconds <= 0) {
          _blackTime = Duration.zero;
          _timedOutSide = 'Black';
        }
      }
      if (_timedOutSide != null) _clock?.cancel();
    });
  }

  void _resetGame() {
    _game.newGame();
    _movesPlayed = 0;
    _timedOutSide = null;
    _whiteTime = widget.options.timeLimit;
    _blackTime = widget.options.timeLimit;
    if (widget.options.useTimer) {
      _clock?.cancel();
      _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tickClock());
    }
  }

  Future<void> _onMove({required ShortMove move}) async {
    if (_timedOutSide != null) return;
    final played = _game.tryMove(
      from: move.from,
      to: move.to,
      promotion: move.promotion?.name,
    );

    if (!played) return;
    _movesPlayed++;

    await _game.playComputerMove();

    if (_game.isGameOver && mounted) {
      showGameOverDialog(
        context,
        result: _game.status,
        onPlayAgain: _resetGame,
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
    _clock?.cancel();
    showGameOverDialog(context, result: _game.status, onPlayAgain: _resetGame);
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

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _status {
    if (_timedOutSide != null) {
      final winner = _timedOutSide == 'White' ? 'Black' : 'White';
      return '$_timedOutSide ran out of time – $winner wins!';
    }
    return _game.status;
  }

  @override
  Widget build(BuildContext context) {
    final boardColors = ChessBoardColors()
      ..lightSquaresColor = widget.options.boardScheme.lightSquareColor
      ..darkSquaresColor = widget.options.boardScheme.darkSquareColor;

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
              if (!_game.isGameOver && _timedOutSide == null)
                IconButton(
                  tooltip: 'Resign',
                  icon: const Icon(Icons.flag),
                  onPressed: _game.isThinking ? null : _confirmResign,
                )
              else
                IconButton(
                  tooltip: 'New game',
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetGame,
                ),
            ],
          ),
          body: Column(
            children: [
              if (widget.options.useTimer)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('White ${_formatTime(_whiteTime)}'),
                      Text('Black ${_formatTime(_blackTime)}'),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_status, style: const TextStyle(fontSize: 20)),
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
                      chessBoardColors: boardColors,
                      cellHighlights: const {},
                      showPossibleMoves: true,
                      isInteractive:
                          !_game.isGameOver &&
                          !_game.isThinking &&
                          _timedOutSide == null,
                      nonInteractiveText:
                          _game.isGameOver || _timedOutSide != null
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
