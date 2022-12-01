import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  defaultPatrolTest('Should open product modal from products screen and show its data', ($) async {
    await $.pumpAndSettle();

    await scrollToAndTap($.tester, find.text('Produkty'));
    await $.pumpAndSettle();

    await scrollToAndTap($.tester, find.textContaining('Cisowianka'));
    await $.pumpAndSettle();

    expect(find.text('5902078020001'), findsOneWidget);
    expect(find.text('Nakrętka'), findsOneWidget);
    expect(find.text('Dbaj o czystość'), findsOneWidget);
  });
}