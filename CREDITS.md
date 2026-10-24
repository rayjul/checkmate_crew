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
