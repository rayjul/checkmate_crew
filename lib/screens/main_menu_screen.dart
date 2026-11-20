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

  Future<void> _handleOption(_MenuOption option) async {
    if (option.destination == _MenuDestination.exit) {
      SystemNavigator.pop();
      return;
    }

    final options = await showGameSetupDialog(
      context,
      modeTitle: option.title,
      initialOptions: _defaultOptions,
      settingsOnly: option.destination == _MenuDestination.settings,
      showComputerDifficulty: option.destination == _MenuDestination.computer,
    );
    if (!mounted || options == null) return;

    if (option.destination == _MenuDestination.settings) {
      setState(() => _defaultOptions = options);
      return;
    }

    final screen = switch (option.destination) {
      _MenuDestination.human => GameScreen(options: options),
      _MenuDestination.computer => GameScreen(
        options: options,
        vsComputer: true,
        skillLevel: options.skillLevel,
      ),
      _ => _ComingSoonScreen(title: option.title),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final menuOptions = <_MenuOption>[
      const _MenuOption(
        title: 'Play vs Human',
        backgroundColor: Color(0xFF4F46E5),
        destination: _MenuDestination.human,
      ),
      const _MenuOption(
        title: 'Play vs Computer',
        backgroundColor: Color(0xFF0EA5E9),
        destination: _MenuDestination.computer,
      ),
      const _MenuOption(
        title: 'Local multiplayer',
        backgroundColor: Color(0xFF14B8A6),
        destination: _MenuDestination.local,
      ),
      const _MenuOption(
        title: 'Settings',
        backgroundColor: Color(0xFF64748B),
        destination: _MenuDestination.settings,
      ),
      const _MenuOption(
        title: 'Exit',
        backgroundColor: Color(0xFFDC2626),
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
                    ...menuOptions.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _playMenuSound();
                              _handleOption(option);
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
                      ),
                    ),
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

class _MenuOption {
  const _MenuOption({
    required this.title,
    required this.backgroundColor,
    required this.destination,
  });

  final String title;
  final Color backgroundColor;
  final _MenuDestination destination;
}

enum _MenuDestination { human, computer, local, settings, exit }

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
