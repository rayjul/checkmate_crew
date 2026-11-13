# Asset credits

## Chess pieces

- Files: `assets/pieces/{w,b}{K,Q,R,B,N,P}.png` (12 transparent PNGs).
- Created for Checkmate Crew with OpenAI's built-in image generation tool.
- Style: classic Staunton pieces, ivory and charcoal, with outlined silhouettes.
- Source: generated in this project's Codex chat; no third-party piece artwork was supplied. The generated white king was used as the style reference for the remaining pieces.
- Usage terms: [OpenAI Terms of Use](https://openai.com/policies/terms-of-use/). No third-party stock-art license is claimed.
- Generation prompts are recorded in `docs/chess-piece-generation.json`.

## App icon and splash emblem

- Files: `assets/branding/app_icon.png` and `assets/branding/splash_logo.png`.
- Created for Checkmate Crew with OpenAI's built-in image generation tool, using the generated knight as the style reference.
- Source and usage terms: [OpenAI Terms of Use](https://openai.com/policies/terms-of-use/). No third-party stock artwork or stock-art license is claimed.
- Prompts: `docs/branding-generation.json`.
- Platform launchers and splash images are exports of these masters, produced by `flutter_launcher_icons` and `flutter_native_splash`. `splash_android12.png` is a padded export made by `tool/export_branding.dart`.

## Sound effects

- Files: `assets/sounds/move.wav`, `capture.wav`, and `check.wav`.
- Source: original procedural synthesis in `tool/generate_sounds.py`; no recordings or third-party samples.
- Mono, 44.1 kHz, 16-bit PCM WAV. Move is a short wooden click, capture is a double impact, and check is a two-note alert.
- No third-party sample license applies. The maintainers can choose the repository's distribution license for these original synthesized assets.

## Chess rules and board

- [chess](https://pub.dev/packages/chess): chess rules, legal moves and game status.
- [simple_chess_board](https://pub.dev/packages/simple_chess_board): board, pieces and move interaction. The board integration follows the package's interactive example, adapted through the team's Checkmate Crew Build Guide (starter part 4).

## Stockfish browser engine

- Stockfish.js v19.0.1, lite single-threaded browser build, by Nathan Rugg and the Stockfish contributors.
- Runtime files: `web/stockfish/stockfish-19-lite-single.js` and matching `.wasm`, copied without changes from the [upstream release](https://github.com/nmrugg/stockfish.js/releases/tag/v19.0.1).
- License: GNU GPL v3; the full license, authors, corresponding source archive, lite evaluation network and provenance are included in [web/stockfish/](web/stockfish/README.md).
- The Chrome computer opponent uses this local browser engine through a JavaScript worker. Non-web builds use a random-move fallback.
