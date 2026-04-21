import 'package:binance/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BinanceApp boots', (tester) async {
    await tester.pumpWidget(const BinanceApp());
    expect(find.byType(BinanceApp), findsOneWidget);
  });
}
