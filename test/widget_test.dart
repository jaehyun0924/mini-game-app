import 'package:flutter_test/flutter_test.dart';

import 'package:mini_game_app/main.dart';

void main() {
  testWidgets('홈 화면에 사다리타기 버튼이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('사다리타기'), findsOneWidget);
  });
}
