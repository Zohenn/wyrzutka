import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  defaultPatrolTest(
    'Should allow for permission to be granted again if it was denied before',
    cameraPermissionAction: 'revoke',
    ($) async {
      await $.tester.pump();
      if (!(await $.native.isPermissionDialogVisible())) {
        await $.tester.pump();
      }

      await $.native.denyPermission();
      await $.tester.pumpAndSettle();

      await $.tester.tap(find.text('Spróbuj ponownie'));
      await $.tester.pump();

      await $.native.grantPermissionWhenInUse();
      // give it more time as it tends to be a bit flaky
      await $.tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('Skanuj'), findsAtLeastNWidgets(2));
    },
  );
}
