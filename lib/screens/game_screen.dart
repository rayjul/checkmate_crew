import 'dart:async';

import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/material.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

import '../models/game_setup_options.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.options = const GameSetupOptions()});

  final GameSetupOptions options;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _chess = chesslib.Chess();
  late Duration _whiteTime = widget.options.timeLimit;
  late Duration _blackTime = widget.options.timeLimit;
  Timer? _clock;
  String? _timedOutSide;

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
    super.dispose();
  }

  void _tickClock() {
    if (!mounted || _chess.game_over || _timedOutSide != null) return;

    setState(() {
      if (_chess.turn == chesslib.Color.WHITE) {
        _whiteTime -= const Duration(seconds: 1);
        if (_whiteTime.inSeconds <= 0) {
          _whiteTime = Duration.zero;
          _timedOutSide = 'White';
          _clock?.cancel();
        }
      } else {
        _blackTime -= const Duration(seconds: 1);
        if (_blackTime.inSeconds <= 0) {
          _blackTime = Duration.zero;
          _timedOutSide = 'Black';
          _clock?.cancel();
        }
      }
    });
  }

  void _tryMove({required ShortMove move}) {
    if (_timedOutSide != null) return;
    final ok = _chess.move({
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion?.name,
    });

    if (ok) {
      if (_chess.game_over) _clock?.cancel();
      setState(() {});
    }
  }

  String get _status {
    if (_timedOutSide != null) {
      final winner = _timedOutSide == 'White' ? 'Black' : 'White';
      return '$_timedOutSide ran out of time – $winner wins!';
    }
    final side = _chess.turn == chesslib.Color.WHITE ? 'White' : 'Black';
    final other = side == 'White' ? 'Black' : 'White';

    if (_chess.in_checkmate) return 'Checkmate – $other wins!';
    if (_chess.in_stalemate) return 'Stalemate – draw';
    if (_chess.in_draw) return 'Draw';
    if (_chess.in_check) return '$side to move – check!';
    return '$side to move';
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final boardColors = ChessBoardColors()
      ..lightSquaresColor = widget.options.boardScheme.lightSquareColor
      ..darkSquaresColor = widget.options.boardScheme.darkSquareColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkmate Crew')),
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
                  chessBoardColors: boardColors,
                  cellHighlights: const {},
                  showPossibleMoves: true,
                  isInteractive: !_chess.game_over && _timedOutSide == null,
                  nonInteractiveText: 'GAME OVER',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
