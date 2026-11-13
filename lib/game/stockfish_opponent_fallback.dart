import 'package:chess/chess.dart' as chesslib;

/// Random-move opponent used on non-web targets.
class StockfishBackend {
  Future<void> start({int skillLevel = 3}) async {}

  Future<String> bestMove(String fen, {int thinkMs = 500}) async {
    await Future<void>.delayed(Duration(milliseconds: thinkMs));
    final moves = chesslib.Chess.fromFEN(fen).moves({'verbose': true})
      ..shuffle();
    final move = moves.first as Map;
    final promotion = (move['flags'] as String).contains('p') ? 'q' : '';
    return '${move['from']}${move['to']}$promotion';
  }

  void dispose() {}
}
