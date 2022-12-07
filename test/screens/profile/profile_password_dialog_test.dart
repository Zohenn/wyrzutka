import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/screens/profile/dialog/profile_password_dialog.dart';
import 'package:wyrzutka/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'profile_password_dialog_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthService>(),
])
void main() {
  late AppUser authUser;
  late MockAuthService mockAuthService;

  String oldPassword = "oldPassword";
  String newPassword = "newPassword";

  buildWidget() => wrapForTesting(
    ProfilePasswordDialog(user: authUser),
    overrides: [
      authServiceProvider.overrideWith((ref) => mockAuthService),
    ],
  );

  setUp(() {
    authUser = AppUser(
      id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
      email: 'wojciech.brandeburg@pollub.edu.pl',
      name: 'Wojciech',
      surname: 'Brandeburg',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );

    mockAuthService = MockAuthService();
    when(mockAuthService.auth).thenReturn(MockFirebaseAuth(mockUser: MockUser()));
  });

  testWidgets('Should close dialog on tap', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(find.text('Nowe hasło'), findsNothing);
  });

  testWidgets('Should not try to change when passwords are empty', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();

    verifyNever(mockAuthService.updatePassword(any, any));
  });

  testWidgets('Should change password on tap', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Stare hasło'), oldPassword);
    await tester.enterText(find.bySemanticsLabel('Nowe hasło'), newPassword);

    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();

    verify(mockAuthService.updatePassword(oldPassword, newPassword)).called(1);
  });

  testWidgets('Should close modal on success', (tester) async {
    when(mockAuthService.updatePassword(any , any)).thenAnswer((realInvocation) => Future.value());
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Stare hasło'), oldPassword);
    await tester.enterText(find.bySemanticsLabel('Nowe hasło'), newPassword);

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(find.text('Nowe hasło'), findsNothing);
  });

  testWidgets('Should show error snackbar on error', (tester) async {
    when(mockAuthService.updatePassword(any, any)).thenAnswer((realInvocation) => Future.error(Error()));
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Stare hasło'), oldPassword);
    await tester.enterText(find.bySemanticsLabel('Nowe hasło'), newPassword);

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('błąd'), findsOneWidget);
  });

  testWidgets('Should not close dialog on error', (tester) async {
    when(mockAuthService.updatePassword(any, any)).thenAnswer((realInvocation) => Future.error(Error()));
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nowe hasło'), findsWidgets);
  });
}
