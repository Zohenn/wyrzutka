import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/profile/profile_actions_sheet.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'profile_actions_sheet_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthService>(),
])
void main() {
  late AppUser authUser;
  late AppUser user;

  late MockAuthService mockAuthService;

  buildAuthWidget() => wrapForTesting(
    ProfileActionsSheet(userId: authUser.id),
    overrides: [
      authUserProvider.overrideWith((ref) => authUser),
      authServiceProvider.overrideWith((ref) => mockAuthService),
      userProvider.overrideWith((ref, id) => authUser),
    ],
  );

  buildUserWidget() => wrapForTesting(
    ProfileActionsSheet(userId: authUser.id),
    overrides: [
      authUserProvider.overrideWith((ref) => authUser),
      authServiceProvider.overrideWith((ref) => mockAuthService),
      userProvider.overrideWith((ref, id) => user)
    ],
  );

  setUp(() {
    authUser = AppUser(
      id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
      email: 'wojciech.brandeburg@pollub.edu.pl',
      name: 'Wojciech',
      surname: 'Brandeburg',
      role: Role.mod,
      signUpDate: FirestoreDateTime.serverTimestamp(),
      savedProducts: [],
    );

    user = AppUser(
      id: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      email: 'mmarciniak299@gmail.com',
      name: 'Michał',
      surname: 'Marciniak',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );

    mockAuthService = MockAuthService();

    when(mockAuthService.usedPasswordProvider).thenReturn(true);
  });


  group('profile', () {
    testWidgets('Should show sign out button', (tester) async {
      await tester.pumpWidget(buildAuthWidget());
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Wyloguj się');
      expect(finder, findsOneWidget);
    });

    testWidgets('Should sign out user on tap', (tester) async {
      await tester.pumpWidget(buildAuthWidget());
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Wyloguj się');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);

      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('Should show change info button', (tester) async {
      await tester.pumpWidget(buildAuthWidget());
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Edytuj dane konta');
      expect(finder, findsOneWidget);
    });

    testWidgets('Should open change info dialog on tap', (tester) async {
      await tester.pumpWidget(buildAuthWidget());
      await tester.pumpAndSettle();


      final buttonFinder = find.textContaining('Edytuj dane konta');
      expect(buttonFinder, findsOneWidget);

      await scrollToAndTap(tester, buttonFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Imię'), findsOneWidget);
      expect(find.textContaining('Nazwisko'), findsOneWidget);
    });

    testWidgets('Should show change password button', (tester) async {
      await tester.pumpWidget(buildAuthWidget());
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Zmień hasło');
      expect(finder, findsOneWidget);
    });

    testWidgets('Should open change password dialog on tap', (tester) async {
      await tester.pumpWidget(buildAuthWidget());
      await tester.pumpAndSettle();


      Finder finder = find.textContaining('Zmień hasło');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Stare hasło'), findsOneWidget);
    });
  });

  group('user profile', () {
    testWidgets('Should show change role button with role', (tester) async {
      await tester.pumpWidget(buildUserWidget());
      await tester.pumpAndSettle();

      final finder = find.textContaining('Zmień rolę');
      expect(finder, findsOneWidget);
    });

    testWidgets('Should open role dialog on tap', (tester) async {
      await tester.pumpWidget(buildUserWidget());
      await tester.pumpAndSettle();


      final finder = find.textContaining('Zmień rolę');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Zmiana roli'), findsOneWidget);
    });

    testWidgets('Should not show sign out button', (tester) async {
      await tester.pumpWidget(buildUserWidget());
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Wyloguj się');
      expect(finder, findsNothing);
    });
  });
}
