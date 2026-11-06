import 'package:checkmate_crew/main.dart';
import 'package:checkmate_crew/screens/game_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app launches the game screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CheckmateCrewApp());

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Checkmate Crew'), findsOneWidget);
  });
}
