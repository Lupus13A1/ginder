import 'package:flutter_test/flutter_test.dart';
import 'package:ginder/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GinderApp());
    expect(find.text('GINDER'), findsWidgets);
  });
}
