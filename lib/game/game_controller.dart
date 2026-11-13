import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/foundation.dart';

import 'stockfish_opponent.dart';

/// Holds the game and tells the screen when something changes.
class GameController extends ChangeNotifier {
  GameController({this.vsComputer = false, int skillLevel = 3})
    : _skillLevel = skillLevel.clamp(0, 20).toInt() {
    if (vsComputer) _engine.start(skillLevel: _skillLevel);
  }

  /// True when Black is played by the computer.
  final bool vsComputer;

  /// Stockfish skill setting, from 0 (easiest) to 20 (strongest).
  int _skillLevel;

  int get skillLevel => _skillLevel;
  bool isThinking = false;
  bool _disposed = false;
  int _generation = 0;
  String? _computerError;

  final chesslib.Chess _chess = chesslib.Chess();
  final _engine = StockfishOpponent();
  String? _resignedBy; // 'White' or 'Black' after a resignation

  String get fen => _chess.fen;
  String get sideToMove =>
      _chess.turn == chesslib.Color.WHITE ? 'White' : 'Black';
  bool get isGameOver => _resignedBy != null || _chess.game_over;

  /// Changes the Stockfish level for the next computer move.
  void setSkillLevel(int skillLevel) {
    final nextLevel = skillLevel.clamp(0, 20).toInt();
    if (nextLevel == _skillLevel) return;
    _skillLevel = nextLevel;
    notifyListeners();
  }

  /// Text for the screen. At checkmate the side "to move" has lost.
  String get status {
    if (_computerError != null) {
      return 'Computer unavailable. Please start a new game.';
    }
    if (_resignedBy != null) {
      final winner = _resignedBy == 'White' ? 'Black' : 'White';
      return '$_resignedBy resigns – $winner wins!';
    }
    final other = sideToMove == 'White' ? 'Black' : 'White';
    if (_chess.in_checkmate) return 'Checkmate – $other wins!';
    if (_chess.in_stalemate) return 'Stalemate – draw';
    if (_chess.in_draw) return 'Draw';
    if (_chess.in_check) return '$sideToMove to move – check!';
    return '$sideToMove to move';
  }

  /// Plays the move if it's legal. Returns true if it was played.
  bool tryMove({required String from, required String to, String? promotion}) {
    if (isGameOver) return false;
    final ok = _chess.move({'from': from, 'to': to, 'promotion': promotion});
    if (ok) notifyListeners();
    return ok;
  }

  /// Plays a move written like 'e7e5' or 'e7e8q'.
  bool playUciMove(String uci) => tryMove(
    from: uci.substring(0, 2),
    to: uci.substring(2, 4),
    promotion: uci.length > 4 ? uci[4] : null,
  );

  /// Lets the computer (Black) answer. Call after the player's move.
  Future<void> playComputerMove() async {
    if (_disposed ||
        !vsComputer ||
        isGameOver ||
        isThinking ||
        _chess.turn != chesslib.Color.BLACK) {
      return;
    }
    isThinking = true;
    notifyListeners();
    final generation = _generation;
    try {
      await _engine.start(skillLevel: _skillLevel);
      final move = await _engine.bestMove(fen, skillLevel: _skillLevel);
      if (!_disposed && generation == _generation && !isGameOver) {
        playUciMove(move);
      }
    } catch (error) {
      if (!_disposed && generation == _generation) {
        _computerError = error.toString();
      }
    } finally {
      if (!_disposed && generation == _generation) {
        isThinking = false;
        notifyListeners();
      }
    }
  }

  /// The player whose turn it is gives up; the other color wins.
  void resign() {
    if (isGameOver) return;
    _resignedBy = sideToMove;
    notifyListeners();
  }

  void newGame() {
    _generation++;
    isThinking = false;
    _chess.reset();
    _resignedBy = null;
    _computerError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _engine.dispose();
    super.dispose();
  }
}
