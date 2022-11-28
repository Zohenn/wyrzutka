import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:inzynierka/main.dart' as app;

import 'config.dart';
import 'use_firebase_emulator.dart';

void main() {
  patrolTest(
    'Should allow for permission to be granted again if it was denied before',
    config: patrolConfig,
    nativeAutomatorConfig: nativeAutomatorConfig,
    nativeAutomation: true,
    ($) async {
      await useFirebaseEmulator();
      app.main();
      await $.tester.pump();
      if (!(await $.native.isPermissionDialogVisible())) {
        await $.tester.pump();
      }

      await $.native.denyPermission();
      await $.tester.pumpAndSettle();

      await $.tester.tap(find.text('Spróbuj ponownie'));
      await $.tester.pump();

      await $.native.grantPermissionWhenInUse();
      await $.tester.pumpAndSettle();

      expect(find.text('Skanuj'), findsAtLeastNWidgets(2));
    },
  );
}
