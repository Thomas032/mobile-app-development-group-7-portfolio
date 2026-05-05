import 'package:cal_tab/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the app shell', (tester) async {
    await tester.pumpWidget(const CalTabApp());

    expect(find.text('CalTab'), findsOneWidget);
  });
}
