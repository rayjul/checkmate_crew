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

    if (ok) {
      setState(() {}); // redraw the board with the new position
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkmate Crew')),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: SimpleChessBoard(
            fen: _chess.fen,
            whitePlayerType: PlayerType.human,
            blackPlayerType: PlayerType.human,
            onMove: _tryMove,
            onPromote: () async => PieceType.queen,
            onPromotionCommited: ({required moveDone, required pieceType}) {
              moveDone.promotion = pieceType;
              _tryMove(move: moveDone);
            },
            onTap: ({required cellCoordinate}) {},
            chessBoardColors: ChessBoardColors(),
            cellHighlights: const {},
            showPossibleMoves: true,
          ),
        ),
      ),
    );
  }
}
