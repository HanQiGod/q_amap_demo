import 'package:flutter_test/flutter_test.dart';
import 'package:q_amap_demo/main.dart';

void main() {
  testWidgets('demo app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const QAmapDemoApp());
    expect(find.text('QAmap Flutter Federated Demo'), findsOneWidget);
  });
}
