import 'package:flutter/material.dart';

enum ChessBoardScheme { classic, forest, ocean, lavender }

extension ChessBoardSchemeStyle on ChessBoardScheme {
  String get label => switch (this) {
    ChessBoardScheme.classic => 'Classic',
    ChessBoardScheme.forest => 'Forest',
    ChessBoardScheme.ocean => 'Ocean',
    ChessBoardScheme.lavender => 'Lavender',
  };

  Color get lightSquareColor => switch (this) {
    ChessBoardScheme.classic => const Color(0xFFF0D9B5),
    ChessBoardScheme.forest => const Color(0xFFEEEED2),
    ChessBoardScheme.ocean => const Color(0xFFDCEAF4),
    ChessBoardScheme.lavender => const Color(0xFFF1E6F7),
  };

  Color get darkSquareColor => switch (this) {
    ChessBoardScheme.classic => const Color(0xFFB58863),
    ChessBoardScheme.forest => const Color(0xFF769656),
    ChessBoardScheme.ocean => const Color(0xFF5B83A6),
    ChessBoardScheme.lavender => const Color(0xFF9276A8),
  };
}

class GameSetupOptions {
  const GameSetupOptions({
    this.useTimer = false,
    this.timeLimit = const Duration(minutes: 5),
    this.boardScheme = ChessBoardScheme.classic,
  });

  final bool useTimer;
  final Duration timeLimit;
  final ChessBoardScheme boardScheme;
}
