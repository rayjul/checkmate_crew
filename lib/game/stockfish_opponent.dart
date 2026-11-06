// STAND-IN: plays a random legal move so the app also runs in Chrome.
// For the real Stockfish engine (phones only), use the version below.
import 'package:chess/chess.dart' as chesslib;

class StockfishOpponent {
  Future<void> start({int skillLevel = 3}) async {}

  /// Plays a random legal move instead of asking Stockfish.
  Future<String> bestMove(String fen, {int thinkMs = 500}) async {
    await Future.delayed(
      Duration(milliseconds: thinkMs),
    ); // feels like "thinking"
    final moves = chesslib.Chess.fromFEN(fen).moves({'verbose': true})
      ..shuffle();
    final move = moves.first as Map;
    final promotion = (move['flags'] as String).contains('p')
        ? 'q'
        : ''; // pawn -> queen
    return '${move['from']}${move['to']}$promotion';
  }

  void dispose() {}
}
