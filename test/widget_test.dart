import 'package:flutter_test/flutter_test.dart';

import 'package:meow_meow_store/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MeowMeowApp());
    await tester.pumpAndSettle();
  });
}
