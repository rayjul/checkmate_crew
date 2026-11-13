import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_setup_options.dart';
import '../widgets/game_setup_dialog.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  GameSetupOptions _defaultOptions = const GameSetupOptions();

  void _playMenuSound() {
    if (!kIsWeb) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _handleOption(
    BuildContext context,
    _MenuOptionData option,
  ) async {
    if (option.destination == _MenuDestination.exit) {
      SystemNavigator.pop();
      return;
    }

    final options = await showGameSetupDialog(
      context,
      modeTitle: option.title,
      initialOptions: _defaultOptions,
      settingsOnly: option.destination == _MenuDestination.settings,
    );
    if (!context.mounted || options == null) return;

    if (option.destination == _MenuDestination.settings) {
      setState(() => _defaultOptions = options);
      return;
    }

    final Widget screen = switch (option.destination) {
      _MenuDestination.human => GameScreen(options: options),
      _ => _ComingSoonScreen(title: option.title),
    };
    _openScreen(context, screen);
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final menuOptions = <_MenuOptionData>[
      _MenuOptionData(
        title: 'Play vs Human',
        backgroundColor: const Color(0xFF4F46E5),
        destination: _MenuDestination.human,
      ),
      _MenuOptionData(
        title: 'Play vs Computer',
        backgroundColor: const Color(0xFF0EA5E9),
        destination: _MenuDestination.computer,
      ),
      _MenuOptionData(
        title: 'Local multiplayer',
        backgroundColor: const Color(0xFF14B8A6),
        destination: _MenuDestination.local,
      ),
      _MenuOptionData(
        title: 'Practice / puzzles',
        backgroundColor: const Color(0xFFF59E0B),
        destination: _MenuDestination.practice,
      ),
      _MenuOptionData(
        title: 'Tutorial / how to play',
        backgroundColor: const Color(0xFF8B5CF6),
        destination: _MenuDestination.tutorial,
      ),
      _MenuOptionData(
        title: 'Settings',
        backgroundColor: const Color(0xFF64748B),
        destination: _MenuDestination.settings,
      ),
      _MenuOptionData(
        title: 'Exit',
        backgroundColor: const Color(0xFFDC2626),
        destination: _MenuDestination.exit,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Checkmate Crew',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Choose your match',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 18),
                    ),
                    const SizedBox(height: 28),
                    ...menuOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _playMenuSound();
                              _handleOption(context, option);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: option.backgroundColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              option.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuOptionData {
  const _MenuOptionData({
    required this.title,
    required this.backgroundColor,
    required this.destination,
  });

  final String title;
  final Color backgroundColor;
  final _MenuDestination destination;
}

enum _MenuDestination {
  human,
  computer,
  local,
  practice,
  tutorial,
  settings,
  exit,
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 72, color: Colors.white70),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
