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
  final AppUser regularUser = AppUser(
    id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    email: 'wojciech.brandeburg@pollub.edu.pl',
    name: 'Wojciech',
    surname: 'Brandeburg',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );

  final modUser = regularUser.copyWith(id: '2', role: Role.mod, name: 'mod', surname: 'mod');
  final adminUser = regularUser.copyWith(id: '3', role: Role.admin, name: 'admin', surname: 'admin');
  final privilegedUsers = [modUser, adminUser];

  late MockAuthService mockAuthService;

  late AppUser user;

  buildWidget({required AppUser authUser, AppUser? user}) => wrapForTesting(
        ProfileActionsSheet(userId: (user ?? authUser).id),
        overrides: [
          authUserProvider.overrideWith((ref) => authUser),
          authServiceProvider.overrideWith((ref) => mockAuthService),
          userProvider.overrideWith((ref, id) => user ?? authUser),
        ],
      );

  setUp(() {
    user = regularUser;

    mockAuthService = MockAuthService();
    when(mockAuthService.usedPasswordProvider).thenReturn(true);
  });

  group('profile', () {
    testWidgets('Should show sign out button', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: user));
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Wyloguj się');
      expect(finder, findsOneWidget);
    });

    testWidgets('Should show change info button', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: user));
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Edytuj dane konta');
      expect(finder, findsOneWidget);
    });

    testWidgets('Should show change password button', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: user));
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Zmień hasło');
      expect(finder, findsOneWidget);
    });

    testWidgets('Should not show change role button', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: user));
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Zmień rolę');
      expect(finder, findsNothing);
    });
  });

  group('user profile', () {
    testWidgets('Should not show sign out button', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: modUser, user: user));
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Wyloguj się');
      expect(finder, findsNothing);
    });

    for (var privilegedUser in privilegedUsers) {
      testWidgets('Should show change role button for ${privilegedUser.role.name} user', (tester) async {
        await tester.pumpWidget(buildWidget(authUser: privilegedUser, user: user));
        await tester.pumpAndSettle();

        final finder = find.textContaining('Zmień rolę');
        expect(finder, findsOneWidget);
      });
    }
  });

  group('user buttons', () {
    testWidgets('Should sign out user on tap', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: user));
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Wyloguj się');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);

      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('Should open change info dialog on tap', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: user));
      await tester.pumpAndSettle();

      final buttonFinder = find.textContaining('Edytuj dane konta');
      expect(buttonFinder, findsOneWidget);

      await scrollToAndTap(tester, buttonFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Imię'), findsOneWidget);
      expect(find.textContaining('Nazwisko'), findsOneWidget);
    });

    testWidgets('Should open change password dialog on tap', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: user));
      await tester.pumpAndSettle();

      Finder finder = find.textContaining('Zmień hasło');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Stare hasło'), findsOneWidget);
    });
  });

  group('privileged user buttons', () {
    testWidgets('Should open role dialog on tap', (tester) async {
      await tester.pumpWidget(buildWidget(authUser: modUser, user: user));
      await tester.pumpAndSettle();

      final finder = find.textContaining('Zmień rolę');
      expect(finder, findsOneWidget);

      await scrollToAndTap(tester, finder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Zmiana roli'), findsOneWidget);
    });
  });
}
