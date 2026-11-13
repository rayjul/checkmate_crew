import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _chess = chesslib.Chess();
  bool _hasMadeMove = false;
  bool _allowPop = false;
  bool _leaveDialogOpen = false;

  void _tryMove({required ShortMove move}) {
    final ok = _chess.move({
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion?.name,
    });

    if (ok) {
      _hasMadeMove = true;
      setState(() {});
    }
  }

  bool get _hasActiveGame => _hasMadeMove && !_chess.game_over;

  Future<void> _handleBack() async {
    if (!_hasActiveGame) {
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

  String get _status {
    final side = _chess.turn == chesslib.Color.WHITE ? 'White' : 'Black';
    final other = side == 'White' ? 'Black' : 'White';

    if (_chess.in_checkmate) return 'Checkmate – $other wins!';
    if (_chess.in_stalemate) return 'Stalemate – draw';
    if (_chess.in_draw) return 'Draw';
    if (_chess.in_check) return '$side to move – check!';
    return '$side to move';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !_hasActiveGame || _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _hasActiveGame) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          title: const Text('Checkmate Crew'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_status, style: const TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SimpleChessBoard(
                    fen: _chess.fen,
                    whitePlayerType: PlayerType.human,
                    blackPlayerType: PlayerType.human,
                    onMove: _tryMove,
                    onPromote: () async => PieceType.queen,
                    onPromotionCommited:
                        ({required moveDone, required pieceType}) {
                          moveDone.promotion = pieceType;
                          _tryMove(move: moveDone);
                        },
                    onTap: ({required cellCoordinate}) {},
                    chessBoardColors: ChessBoardColors(),
                    cellHighlights: const {},
                    showPossibleMoves: true,
                    isInteractive: !_chess.game_over,
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
