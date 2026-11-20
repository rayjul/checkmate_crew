import 'package:checkmate_crew/main.dart';
import 'package:checkmate_crew/models/game_setup_options.dart';
import 'package:checkmate_crew/screens/main_menu_screen.dart';
import 'package:checkmate_crew/widgets/game_setup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app launches the main menu', (tester) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.text('Checkmate Crew'), findsOneWidget);
    expect(find.text('Play vs Human'), findsOneWidget);
    expect(find.text('Practice / puzzles'), findsNothing);
    expect(find.text('Tutorial / how to play'), findsNothing);
  });

  testWidgets('game mode opens setup with timer and board options', (
    tester,
  ) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    await tester.tap(find.text('Play vs Human'));
    await tester.pumpAndSettle();

    expect(find.text('Use a timer'), findsOneWidget);
    expect(find.text('Board colors'), findsOneWidget);

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    await tester.tap(find.text('Use a timer'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(MainMenuScreen), findsOneWidget);
  });

  testWidgets('computer mode setup includes and updates difficulty', (
    tester,
  ) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    await tester.tap(find.text('Play vs Computer'));
    await tester.pumpAndSettle();

    expect(find.text('Computer difficulty'), findsOneWidget);
    expect(find.text('Level 3 / 20'), findsOneWidget);

    tester.widget<Slider>(find.byType(Slider)).onChanged!(14);
    await tester.pumpAndSettle();
    expect(find.text('Level 14 / 20'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(MainMenuScreen), findsOneWidget);
  });

  testWidgets('computer setup returns the selected difficulty', (tester) async {
    late Future<GameSetupOptions?> setupResult;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                setupResult = showGameSetupDialog(
                  context,
                  modeTitle: 'Play vs Computer',
                  initialOptions: const GameSetupOptions(),
                  showComputerDifficulty: true,
                );
              },
              child: const Text('Open setup'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open setup'));
    await tester.pumpAndSettle();
    tester.widget<Slider>(find.byType(Slider)).onChanged!(17);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();

    expect(
      await setupResult,
      isA<GameSetupOptions>().having(
        (options) => options.skillLevel,
        'skillLevel',
        17,
      ),
    );
  });

  testWidgets('Cancel resignation, resign and play again', (tester) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    await tester.tap(find.text('Play vs Human'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();

    expect(find.text('White to move'), findsOneWidget);
    expect(find.byTooltip('Resign'), findsOneWidget);

    await tester.tap(find.byTooltip('Resign'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('White to move'), findsOneWidget);

    await tester.tap(find.byTooltip('Resign'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resign'));
    await tester.pumpAndSettle();

    expect(find.text('Game over'), findsOneWidget);
    expect(find.text('White resigns – Black wins!'), findsWidgets);

    await tester.tap(find.text('View board'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('New game'), findsOneWidget);
    expect(find.byTooltip('Resign'), findsNothing);

    await tester.tap(find.byTooltip('New game'));
    await tester.pumpAndSettle();

    expect(find.text('White to move'), findsOneWidget);

    await tester.tap(find.byTooltip('Resign'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resign'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();

    expect(find.text('White to move'), findsOneWidget);
    expect(find.text('Game over'), findsNothing);
  });
}
