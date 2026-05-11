import 'package:flutter_test/flutter_test.dart';
import 'package:colab_match/main.dart';

void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ColabMatch());
  });
}
