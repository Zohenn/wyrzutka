import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  defaultPatrolTest(
    'Should allow for permission to be granted again if it was denied before',
    cameraPermissionAction: 'revoke',
    ($) async {
      await $.pump();
      if (!(await $.native.isPermissionDialogVisible())) {
        await $.pump();
      }

      await $.native.denyPermission();
      await $.pumpAndSettle();

      await $.tap(find.text('Spróbuj ponownie'));
      await $.pump();

      await $.native.grantPermissionWhenInUse();
      // give it more time as it tends to be a bit flaky
      await $.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text('Skanuj'), findsAtLeastNWidgets(2));
    },
  );
}
