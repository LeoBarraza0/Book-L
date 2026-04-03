import 'package:flutter_test/flutter_test.dart';
import 'package:book_l/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BookLApp());
  });
}
