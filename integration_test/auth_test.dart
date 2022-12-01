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
      await $.pumpAndSettle();

      await scrollToAndTap($.tester, find.text('Profil'));
      await $.pumpAndSettle();

      await $.tester.ensureVisible(find.textContaining('Zaloguj się'));
      await $.pumpAndSettle();
      textSpanOnTap(find.textContaining('Zaloguj się'), 'Zaloguj się');
      await $.pumpAndSettle();

      await scrollToAndEnterText($.tester, find.bySemanticsLabel('Adres email'), 'mmarciniak299@gmail.com');
      await scrollToAndEnterText($.tester, find.bySemanticsLabel('Hasło'), 'qwerty');

      await scrollToAndTap($.tester, find.text('Zaloguj się'));
      await $.pumpAndSettle();

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

      await $.pumpAndSettle();

      await scrollToAndTap($.tester, find.text('Profil'));
      await $.pumpAndSettle();

      await scrollToAndTap($.tester, find.text('Zarejestruj się'));
      await $.pumpAndSettle();

      await scrollToAndEnterText($.tester, find.bySemanticsLabel('Imię'), name);
      await scrollToAndEnterText($.tester, find.bySemanticsLabel('Nazwisko'), surname);
      await scrollToAndEnterText($.tester, find.bySemanticsLabel('Adres email'), email);
      await scrollToAndEnterText($.tester, find.bySemanticsLabel('Hasło'), password);

      await scrollToAndTap($.tester, find.text('Zarejestruj się').last);
      await $.pumpAndSettle();

      expect(find.text('$name $surname'), findsOneWidget);
    },
  );
}
