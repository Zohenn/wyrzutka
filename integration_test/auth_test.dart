import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/main.dart' as app;
import 'package:patrol/patrol.dart';

import 'config.dart';
import 'use_firebase_emulator.dart';
import 'utils.dart';

void main() {
  setUp(() async {
    await useFirebaseEmulator();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  patrolTest(
    'Should show profile screen after sign in',
    config: patrolConfig,
    nativeAutomatorConfig: nativeAutomatorConfig,
    nativeAutomation: true,
    ($) async {
      app.main();
      await $.tester.pumpAndSettle();

      await scrollToAndTap($.tester, find.text('Profil'));
      await $.tester.pumpAndSettle();

      await $.tester.ensureVisible(find.textContaining('Zaloguj się'));
      await $.tester.pumpAndSettle();

      textSpanOnTap(find.textContaining('Zaloguj się'), 'Zaloguj się');
      await $.tester.pumpAndSettle();

      await $.tester.enterText(find.bySemanticsLabel('Adres email'), 'mmarciniak299@gmail.com');
      await $.tester.enterText(find.bySemanticsLabel('Hasło'), 'qwerty');

      await scrollToAndTap($.tester, find.text('Zaloguj się'));
      await $.tester.pumpAndSettle();

      expect(find.text('Michał Marciniak'), findsOneWidget);
    },
  );

  patrolTest(
    'Should show profile screen after sign up',
    config: patrolConfig,
    nativeAutomatorConfig: nativeAutomatorConfig,
    nativeAutomation: true,
    ($) async {
      const email = 'jan.kowalski@gmail.com';
      const password = 'qwerty1234';
      const name = 'Jan';
      const surname = 'Kowalski';

      addTearDown(() async {
        await FirebaseAuth.instance.currentUser?.delete();
      });

      app.main();
      await $.tester.pumpAndSettle();

      await scrollToAndTap($.tester, find.text('Profil'));
      await $.tester.pumpAndSettle();

      await scrollToAndTap($.tester, find.text('Zarejestruj się'));
      await $.tester.pumpAndSettle();

      await $.tester.enterText(find.bySemanticsLabel('Imię'), name);
      await $.tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);
      await $.tester.enterText(find.bySemanticsLabel('Adres email'), email);
      await $.tester.enterText(find.bySemanticsLabel('Hasło'), password);

      await scrollToAndTap($.tester, find.text('Zarejestruj się').last);
      await $.tester.pumpAndSettle();

      expect(find.text('$name $surname'), findsOneWidget);
    },
  );
}
