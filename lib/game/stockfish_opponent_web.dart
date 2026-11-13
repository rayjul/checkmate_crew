import 'dart:js_interop';

@JS('stockfishBridge')
external JSObject get _stockfishBridge;

extension type _StockfishBridge(JSObject _) implements JSObject {
  external JSPromise<JSAny?> start(JSNumber skillLevel);
  external JSPromise<JSString> bestMove(JSString fen, JSNumber thinkMs);
  external void dispose();
}

/// Browser Stockfish adapter backed by the JavaScript worker bridge.
class StockfishBackend {
  final _StockfishBridge _bridge = _StockfishBridge(_stockfishBridge);

  Future<void> start({int skillLevel = 3}) async {
    await _bridge.start(skillLevel.toJS).toDart;
  }

  Future<String> bestMove(String fen, {int thinkMs = 500}) async {
    final move = await _bridge.bestMove(fen.toJS, thinkMs.toJS).toDart;
    return move.toDart;
  }

  void dispose() => _bridge.dispose();
}
