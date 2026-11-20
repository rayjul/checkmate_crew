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
    _startClock();
  }

  @override
  void dispose() {
    _clock?.cancel();
    _game.dispose();
    super.dispose();
  }

  void _startClock() {
    if (widget.options.useTimer) {
      _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tickClock());
    }
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

  void _newGame() {
    _clock?.cancel();
    _game.newGame();
    _movesPlayed = 0;
    _timedOutSide = null;
    _whiteTime = widget.options.timeLimit;
    _blackTime = widget.options.timeLimit;
    _startClock();
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
      _clock?.cancel();
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
    _clock?.cancel();
    _game.resign();
    showGameOverDialog(context, result: _game.status, onPlayAgain: _newGame);
  }

  Future<void> _handleBack() async {
    if (!_hasActiveGame) {
      Navigator.of(context).pop();
      return;
    }
    await _confirmLeave();
  }

  Future<void> _confirmLeave() async {
    if (_leaveDialogOpen || !_hasActiveGame) return;
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

  bool get _hasActiveGame =>
      _movesPlayed > 0 && !_game.isGameOver && _timedOutSide == null;

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
      canPop: !_hasActiveGame || _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _hasActiveGame) _confirmLeave();
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
                  onPressed: _newGame,
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_status, style: const TextStyle(fontSize: 20)),
              ),
              if (_game.vsComputer) _buildComputerDifficulty(),
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
