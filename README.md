# Checkmate Crew

Checkmate Crew is a team-built Flutter chess app. It uses the `chess` package to enforce chess rules and `simple_chess_board` to display the board and handle piece interaction.

## Project status

Starter parts 4 and 5 and the browser Stockfish integration are on branch `69-starter-part-4`, proposed in [pull request #72](https://github.com/rayjul/checkmate_crew/pull/72). The branch has not been merged into `main`.

- Two people play on the same device, taking turns as White and Black.
- Legal moves update the board; illegal moves are rejected.
- Status text shows the turn, check, checkmate and draws.
- A confirmation dialog lets the player to move resign.
- At game over, players can view the final board or play again.
- Pawn promotion currently selects a queen automatically.

On Chrome, the optional computer opponent uses the bundled Stockfish.js engine. Non-web builds use the random-move fallback. A chess clock, online multiplayer and custom in-game piece graphics remain future work.

## Quick start on macOS (Chrome)

Install [Homebrew](https://brew.sh/) if needed, then install Flutter:

```bash
brew install --cask flutter
flutter --version
flutter doctor
```

Install Google Chrome. This web setup does not require Android Studio, an Android emulator or full Xcode. Flutter includes Dart; the project's `pubspec.yaml` currently requires Dart `^3.13.1`, so use a compatible Flutter SDK.

Clone the repo and open the starter branch:

```bash
git clone https://github.com/rayjul/checkmate_crew.git
cd checkmate_crew
git switch 69-starter-part-4
flutter pub get
flutter run -d chrome
```

If you already have a clone, use its existing folder instead of cloning again. Save or commit any work before switching branches, then fetch the branch with `git fetch origin`.

See the [manual](docs/manual.md) for controls, troubleshooting and manual test scenarios.

## Development checks

Run these from the folder containing `pubspec.yaml`:

```bash
dart format lib test
flutter analyze
flutter test
```

The branch includes controller tests for illegal moves, resignation, reset and Fool's mate, plus a widget test for the resignation and new-game flow. Run the checks after making changes.

## Code layout

```text
lib/
  main.dart                     App entry point
  game/game_controller.dart     Position, moves, status and resignation
  screens/game_screen.dart      Board, status and controls
  widgets/game_over_dialog.dart Result and replay choices
test/                           Controller and widget tests
assets/                         Branding, piece images and sounds
```

## Contributing

Track work on the [project board](https://github.com/users/rayjul/projects/3/views/1). Coordinate ownership before editing a teammate's task.

Follow the [team rules in issue #3](https://github.com/rayjul/checkmate_crew/issues/3): use an issue-number branch, submit changes through a pull request, obtain one teammate's approval, and let the team lead squash and merge. Include `Closes #<number>` only for issues the pull request fully completes.

## Credits and setup references

See [CREDITS.md](CREDITS.md) for package and asset acknowledgments.

- [Flutter installation](https://docs.flutter.dev/install/manual)
- [Flutter web setup](https://docs.flutter.dev/platform-integration/web/setup)
- [Homebrew Flutter package](https://formulae.brew.sh/cask/flutter)

## Play against the computer

The Chrome build uses the bundled Stockfish engine locally. To play White against computer-controlled Black, run:

```bash
flutter run -d chrome --dart-define=VS_COMPUTER=true
```

Without that flag, the app remains in two-player mode. With it, Black uses the browser Stockfish engine and the board pauses while Stockfish thinks. The local non-web build uses random legal moves as a fallback.

To check the computer: play e2 to e4, wait for Black's response, and confirm White can move again. Stop the app and rerun without the flag to verify two-player mode.

The matching Stockfish.js v19.0.1 lite single-threaded JavaScript and WebAssembly files, license, authors and source are under [`web/stockfish/`](web/stockfish/README.md). Chrome runs Stockfish locally in a browser worker; non-web builds use random legal moves.
