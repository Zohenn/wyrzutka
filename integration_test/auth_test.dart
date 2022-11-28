import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  defaultPatrolTest(
    'Should show profile screen after sign in',
    ($) async {
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

  defaultPatrolTest(
    'Should show profile screen after sign up',
    ($) async {
      const email = 'jan.kowalski@gmail.com';
      const password = 'qwerty1234';
      const name = 'Jan';
      const surname = 'Kowalski';

      addTearDown(() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        }
        await FirebaseAuth.instance.currentUser?.delete();
      });

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
