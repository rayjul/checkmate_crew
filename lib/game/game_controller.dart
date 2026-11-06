import 'package:chess/chess.dart' as chesslib;
import 'package:flutter/foundation.dart';

/// Holds the game and tells the screen when something changes.
class GameController extends ChangeNotifier {
  final chesslib.Chess _chess = chesslib.Chess();
  String? _resignedBy; // 'White' or 'Black' after a resignation

  String get fen => _chess.fen;
  String get sideToMove => _chess.turn == chesslib.Color.WHITE ? 'White' : 'Black';
  bool get isGameOver => _resignedBy != null || _chess.game_over;

  /// Text for the screen. At checkmate the side "to move" has lost.
  String get status {
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

  /// The player whose turn it is gives up; the other color wins.
  void resign() {
    if (isGameOver) return;
    _resignedBy = sideToMove;
    notifyListeners();
  }

  void newGame() {
    _chess.reset();
    _resignedBy = null;
    notifyListeners();
  }
}
