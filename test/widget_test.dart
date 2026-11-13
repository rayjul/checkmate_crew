import 'package:checkmate_crew/main.dart';
import 'package:checkmate_crew/screens/main_menu_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app launches the main menu', (WidgetTester tester) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.text('Checkmate Crew'), findsOneWidget);
    expect(find.text('Play vs Human'), findsOneWidget);
    expect(find.text('Practice / puzzles'), findsNothing);
    expect(find.text('Tutorial / how to play'), findsNothing);
  });
}
