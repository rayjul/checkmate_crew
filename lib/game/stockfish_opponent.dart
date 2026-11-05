import 'package:stockfish/stockfish.dart';

/// Asks Stockfish for a move. Android and iOS only.
class StockfishOpponent {
  Stockfish? _engine;

  /// Starts the engine. skillLevel: 0 (weakest) – 20 (strongest).
  Future<void> start({int skillLevel = 3}) async {
    _engine = await stockfishAsync(); // waits until the engine is ready
    _engine!.stdin = 'uci';
    _engine!.stdin = 'setoption name Skill Level value $skillLevel';
  }

  /// Returns the best move as text like 'e7e5' (or 'e7e8q' for a promotion).
  Future<String> bestMove(String fen, {int thinkMs = 500}) async {
    final engine = _engine!;
    final reply = engine.stdout.firstWhere(
      (line) => line.startsWith('bestmove'),
    );
    engine.stdin = 'position fen $fen';
    engine.stdin = 'go movetime $thinkMs';
    final line = await reply; // e.g. 'bestmove e7e5 ponder g1f3'
    return line.split(' ')[1];
  }

  void dispose() => _engine?.dispose();
}
