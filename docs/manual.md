# Checkmate Crew manual

## What the app does

Checkmate Crew lets two people play chess on the same device. White moves first, followed by Black. The rules engine checks moves and detects check, checkmate and draws.

This manual describes the starter part 4 branch, `69-starter-part-4`, proposed in [pull request #72](https://github.com/rayjul/checkmate_crew/pull/72). A random computer opponent is available as described below; a timer and online multiplayer remain planned features.

## Install and start

Follow the [README quick start](../README.md#quick-start-on-macos-chrome). In Terminal, make sure you are inside the repository folder containing `pubspec.yaml`, then run:

```bash
flutter pub get
flutter run -d chrome
```

Keep Terminal open while using the app. To stop the development session, return to Terminal and press `q`.

## Play a game

1. Check the text above the board to see whose turn it is.
2. Tap or click a piece, then a marked destination square. You can also drag a piece to its destination.
3. The board updates if the move is legal. An illegal move leaves the position unchanged.
4. Pass control to the other player and continue.

The status text also announces check. Checkmate or a draw ends the game and opens the result dialog. Pawns currently promote to queens automatically; choosing a rook, bishop or knight is future work.

## Resign

The flag button in the top bar belongs to the player whose turn it is.

1. Select the flag.
2. Read which player will resign and who will win.
3. Choose **Cancel** to continue, or **Resign** to end the game.

For example, after White makes a move, it is Black's turn. Confirming resignation then produces **Black resigns – White wins!**

There is no undo or restart button during an active game.

## After the game

- **View board** closes the result dialog and keeps the final position. Moves remain disabled.
- **Play again** closes the dialog and resets the board, with White to move.
- After choosing View board, the refresh button in the top bar starts a new game.

Game progress is held in memory. Reloading or closing the app does not preserve the game.

## Verify starter part 4

Run `flutter analyze` and `flutter test`, then check these scenarios in Chrome:

| Scenario | Steps | Expected result |
| --- | --- | --- |
| Legal move | Move e2 to e4 | Pawn moves; status becomes Black to move. |
| Illegal move | From a fresh game, try e2 to e5 | Position and turn remain unchanged. |
| Cancel resignation | Select the flag, then Cancel | Game continues from the same position. |
| Resign | Move e2 to e4, select the flag, confirm Resign | Result says Black resigns – White wins! |
| View final board | Choose View board after resignation | Board accepts no moves; refresh button is available. |
| New game | Select refresh after View board | Starting position returns; White moves first. |
| Checkmate | From a fresh game play f2–f3, e7–e5, g2–g4, d8–h4 | Result says Checkmate – Black wins! |
| Play again | Choose Play again in the result dialog | Starting position returns and the dialog closes. |

## Troubleshooting

**Homebrew reports “Unknown command: brew get.”** Use `brew install --cask flutter`.

**Terminal reports “flutter: command not found.”** Finish installing Flutter, reopen Terminal, and try `flutter --version`. If needed, follow Flutter's [PATH instructions](https://docs.flutter.dev/install/add-to-path).

**Chrome is missing from the device list.** Install Chrome, then run `flutter devices`. See the official [web setup guide](https://docs.flutter.dev/platform-integration/web/setup).

**Flutter cannot find `pubspec.yaml`.** Change to the repository folder before running Flutter commands.

**Dependency resolution reports an incompatible Dart SDK.** Check `flutter --version` against the Dart requirement in `pubspec.yaml`. Install a compatible Flutter release, then rerun `flutter pub get`.

**The counter demo appears.** Check `git branch --show-current`. Starter part 4 lives on `69-starter-part-4` until merged. Save your changes before switching branches, then stop and relaunch the app.

**Flutter doctor warns about Android Studio or Xcode.** Those platform tools are not needed for this Chrome-only workflow. Resolve errors affecting Flutter or Chrome first.

## Report a problem

Create an issue in the repository with the steps to reproduce, the expected result, what actually happened, and any relevant screenshot or error message. Include your operating system, branch and `flutter --version` output.

## Starter part 5: random computer opponent

The starter branch also includes the guide's browser-compatible random opponent. To play White against computer-controlled Black, run:

```bash
flutter run -d chrome --dart-define=VS_COMPUTER=true
```

Without that flag, the app remains in two-player mode. The computer chooses a random legal move after a short delay; it is not Stockfish or a machine learning engine. The board and resignation control pause during its turn. Real Stockfish remains future work because the guide's native version requires Android/iOS and cannot replace the browser version without breaking Chrome.

To check the computer: play e2 to e4, wait for Black's response, and confirm White can move again. Stop the app and rerun without the flag to verify two-player mode.
