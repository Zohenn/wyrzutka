import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/screens/profile/dialog/profile_user_info_dialog.dart';
import 'package:wyrzutka/services/auth_user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'profile_user_info_dialog_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthUserService>(),
])
void main() {
  late AppUser authUser = AppUser(
    id: 'GGGtyUFUyMO3OEsYnGRm4jlcrXw1',
    email: 'wojciech.brandeburg@pollub.edu.pl',
    name: 'Wojciech',
    surname: 'Brandeburg',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );
  late MockAuthUserService mockAuthUserService;

  String name = 'Michał';
  String surname = 'Marciniak';

  buildWidget() => wrapForTesting(
    ProfileUserInfoDialog(user: authUser),
    overrides: [
      authUserServiceProvider.overrideWith((ref) => mockAuthUserService),
    ],
  );

  setUp(() {
    mockAuthUserService = MockAuthUserService();
  });

  testWidgets('Should close dialog on tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    await scrollToAndTap(tester, find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Imię'), findsNothing);
    expect(find.textContaining('Nazwisko'), findsNothing);
  });

  testWidgets('Should fill fields with user info', (tester) async {
    await tester.pumpWidget(buildWidget());

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    verify(mockAuthUserService.changeInfo(authUser.name, authUser.surname)).called(1);
  });

  testWidgets('Should not try to change user info with empty data', (tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.enterText(find.bySemanticsLabel('Imię'), '');
    await tester.enterText(find.bySemanticsLabel('Nazwisko'), '');

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    verifyNever(mockAuthUserService.changeInfo(any, any));
  });

  testWidgets('Should change user info on tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.enterText(find.bySemanticsLabel('Imię'), name);
    await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    verify(mockAuthUserService.changeInfo(name, surname)).called(1);
  });

  testWidgets('Should close modal on success', (tester) async {
    when(mockAuthUserService.changeInfo(any , any)).thenAnswer((realInvocation) => Future.value());
    await tester.pumpWidget(buildWidget());

    await tester.enterText(find.bySemanticsLabel('Imię'), name);
    await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Imię'), findsNothing);
  });

  testWidgets('Should show error snackbar on error', (tester) async {
    when(mockAuthUserService.changeInfo(any, any)).thenAnswer((realInvocation) => Future.error(Error()));
    await tester.pumpWidget(buildWidget());

    await tester.enterText(find.bySemanticsLabel('Imię'), name);
    await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('błąd'), findsOneWidget);
  });

  testWidgets('Should not close dialog on error', (tester) async {
    when(mockAuthUserService.changeInfo(any, any)).thenAnswer((realInvocation) => Future.error(Error()));
    await tester.pumpWidget(buildWidget());

    await tester.enterText(find.bySemanticsLabel('Imię'), name);
    await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);

    await scrollToAndTap(tester, find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Imię'), findsOneWidget);
  });
}
