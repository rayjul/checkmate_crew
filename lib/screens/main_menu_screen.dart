import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _skillLevel = 3;

  void _playMenuSound() {
    if (!kIsWeb) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _handleExit() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final menuOptions = <_MenuOptionData>[
      _MenuOptionData(
        title: 'Play vs Human',
        backgroundColor: const Color(0xFF4F46E5),
        onPressed: (ctx) => _openScreen(ctx, const GameScreen()),
      ),
      _MenuOptionData(
        title: 'Play vs Computer',
        backgroundColor: const Color(0xFF0EA5E9),
        onPressed: (ctx) => _openScreen(
          ctx,
          GameScreen(vsComputer: true, skillLevel: _skillLevel),
        ),
      ),
      _MenuOptionData(
        title: 'Local multiplayer',
        backgroundColor: const Color(0xFF14B8A6),
        onPressed: (ctx) => _openScreen(
          ctx,
          const _ComingSoonScreen(title: 'Local multiplayer'),
        ),
      ),
      _MenuOptionData(
        title: 'Practice / puzzles',
        backgroundColor: const Color(0xFFF59E0B),
        onPressed: (ctx) => _openScreen(
          ctx,
          const _ComingSoonScreen(title: 'Practice / puzzles'),
        ),
      ),
      _MenuOptionData(
        title: 'Tutorial / how to play',
        backgroundColor: const Color(0xFF8B5CF6),
        onPressed: (ctx) => _openScreen(
          ctx,
          const _ComingSoonScreen(title: 'Tutorial / how to play'),
        ),
      ),
      _MenuOptionData(
        title: 'Settings',
        backgroundColor: const Color(0xFF64748B),
        onPressed: (ctx) => _openScreen(
          ctx,
          _DifficultySettingsScreen(
            skillLevel: _skillLevel,
            onSave: (skillLevel) => setState(() => _skillLevel = skillLevel),
          ),
        ),
      ),
      _MenuOptionData(
        title: 'Exit',
        backgroundColor: const Color(0xFFDC2626),
        onPressed: (_) => _handleExit(),
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
                              option.onPressed(context);
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
    required this.onPressed,
  });

  final String title;
  final Color backgroundColor;
  final void Function(BuildContext context) onPressed;
}

class _DifficultySettingsScreen extends StatefulWidget {
  const _DifficultySettingsScreen({
    required this.skillLevel,
    required this.onSave,
  });

  final int skillLevel;
  final ValueChanged<int> onSave;

  @override
  State<_DifficultySettingsScreen> createState() =>
      _DifficultySettingsScreenState();
}

class _DifficultySettingsScreenState extends State<_DifficultySettingsScreen> {
  late int _skillLevel = widget.skillLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101828),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Computer difficulty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stockfish level $_skillLevel of 20',
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 18,
                    ),
                  ),
                  Slider(
                    value: _skillLevel.toDouble(),
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: '$_skillLevel',
                    semanticFormatterCallback: (value) =>
                        'Stockfish level ${value.round()} of 20',
                    onChanged: (value) {
                      setState(() => _skillLevel = value.round());
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Easier', style: TextStyle(color: Colors.white70)),
                      Text('Harder', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Level 0 is easiest; level 20 is strongest. This is an '
                    'engine setting, not a player rating.',
                    style: TextStyle(color: Color(0xFFD1D5DB)),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      widget.onSave(_skillLevel);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save difficulty'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
