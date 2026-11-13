import 'package:checkmate_crew/main.dart';
import 'package:checkmate_crew/screens/main_menu_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app launches the main menu', (tester) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.text('Checkmate Crew'), findsOneWidget);
    expect(find.text('Play vs Human'), findsOneWidget);
  });

  testWidgets('Cancel resignation, resign and play again', (tester) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    await tester.tap(find.text('Play vs Human'));
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