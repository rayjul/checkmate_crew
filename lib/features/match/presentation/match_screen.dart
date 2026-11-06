import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _chess = chesslib.Chess(); // starts at the normal starting position

  void _tryMove({required ShortMove move}) {
    final ok = _chess.move({
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion?.name,
    });
    if (!ok) return; // illegal move: nothing changes
    setState(() {}); // redraw the board and the status text
    if (_chess.game_over) _showGameOver();
  }

  // Start a fresh game.
  void _newGame() => setState(() => _chess.reset());

  // The game over pop-up.
  Future<void> _showGameOver() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // must press a button to close it
      builder: (dialogContext) => AlertDialog(
        title: const Text('Game over'),
        content: Text(_status),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('View board'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _newGame();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  // The text above the board. At checkmate the side "to move" has lost.
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkmate Crew'),
        actions: [
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
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: SimpleChessBoard(
                  fen: _chess.fen,
                  whitePlayerType: PlayerType.human,
                  blackPlayerType: PlayerType.human,
                  onMove: _tryMove,
                  onPromote: () async => PieceType.queen, // always queen for now
                  onPromotionCommited: ({required moveDone, required pieceType}) {
                    moveDone.promotion = pieceType;
                    _tryMove(move: moveDone);
                  },
                  onTap: ({required cellCoordinate}) {},
                  chessBoardColors: ChessBoardColors(),
                  cellHighlights: const {},
                  showPossibleMoves: true, // tap-to-move + dots for legal moves
                  isInteractive: !_chess.game_over, // no moves after the game ends
                  nonInteractiveText: 'GAME OVER', // package default is 'VIEWING HISTORY'
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}