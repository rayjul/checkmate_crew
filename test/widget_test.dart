import 'package:checkmate_crew/main.dart';
import 'package:checkmate_crew/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app launches the main menu', (WidgetTester tester) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.text('Checkmate Crew'), findsOneWidget);
    expect(find.text('Play vs Human'), findsOneWidget);
  });

  testWidgets('game mode opens setup with timer and board options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    await tester.tap(find.text('Play vs Human'));
    await tester.pumpAndSettle();

    expect(find.text('Use a timer'), findsOneWidget);
    expect(find.text('Board colors'), findsOneWidget);

    final timerSwitch = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(timerSwitch.value, isFalse);
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
}
