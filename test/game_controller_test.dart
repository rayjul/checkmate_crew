import 'package:checkmate_crew/game/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reject illegal moves and moves after resignation; reset the game', () {
    final game = GameController();
    addTearDown(game.dispose);
    final startingFen = game.fen;
    expect(game.tryMove(from: 'e2', to: 'e5'), isFalse);
    expect(game.fen, startingFen);
    expect(game.tryMove(from: 'e2', to: 'e4'), isTrue);
    game.resign();
    expect(game.status, 'Black resigns – White wins!');
    final finalFen = game.fen;
    expect(game.tryMove(from: 'e7', to: 'e5'), isFalse);
    expect(game.fen, finalFen);
    game.newGame();
    expect(game.isGameOver, isFalse);
    expect(game.status, 'White to move');
    expect(game.fen, startingFen);
  });

  test('Fools mate ends the game with Black winning', () {
    final game = GameController();
    addTearDown(game.dispose);
    for (final move in ['f2f3', 'e7e5', 'g2g4', 'd8h4']) {
      expect(game.tryMove(from: move.substring(0, 2), to: move.substring(2)), isTrue);
    }
    expect(game.isGameOver, isTrue);
    expect(game.status, 'Checkmate – Black wins!');
    expect(game.tryMove(from: 'e2', to: 'e4'), isFalse);
  });
}
