# Game assets

## Pieces

All 12 piece PNGs are 1254 × 1254 with transparent backgrounds. Names follow the issue #5 convention: `w` or `b` for color, then `K`, `Q`, `R`, `B`, `N`, or `P`.

```dart
Image.asset('assets/pieces/wK.png', fit: BoxFit.contain)
```

Use the same square container and `BoxFit.contain` for every piece. These files are PNGs, not SVGs.

## Branding

- `assets/branding/app_icon.png`: opaque launcher master.
- `assets/branding/splash_logo.png`: transparent emblem for a forest-green launch screen.
- Launcher exports: Android, iOS, web, Windows, and macOS.
- Native splash exports: Android (including Android 12+), iOS, and web.

After changing a branding master, regenerate platform resources:

```sh
flutter pub get
dart run tool/export_branding.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

The Android 12 splash export includes padding for the system's circular mask. With `flutter_launcher_icons` 0.14.4, check `ios/Runner.xcodeproj/project.pbxproj` after regenerating: `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` must remain `YES` (the generator can incorrectly replace it with `AppIcon`).

## Sounds

`assets/sounds/move.wav`, `capture.wav`, and `check.wav` are short PCM sound effects. They are registered as assets; the game UI can connect them to its audio player when move interactions are implemented. No audio playback dependency or move behavior is added in this asset contribution.

To reproduce the sound files:

```sh
python3 tool/generate_sounds.py
```

See `CREDITS.md` for provenance and the generation JSON files for image prompts. Team review is still required before merging the asset tasks.
