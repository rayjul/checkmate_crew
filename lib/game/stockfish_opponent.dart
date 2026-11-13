import 'stockfish_opponent_fallback.dart'
    if (dart.library.js_interop) 'stockfish_opponent_web.dart'
    as platform;

/// Provides a computer move using the current platform's engine backend.
class StockfishOpponent {
  final platform.StockfishBackend _backend = platform.StockfishBackend();

  Future<void> start({int skillLevel = 3}) =>
      _backend.start(skillLevel: skillLevel);

  Future<String> bestMove(
    String fen, {
    int thinkMs = 500,
    int skillLevel = 3,
  }) => _backend.bestMove(fen, thinkMs: thinkMs, skillLevel: skillLevel);

  void dispose() => _backend.dispose();
}
