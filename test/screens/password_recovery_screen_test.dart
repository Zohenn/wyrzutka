import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/screens/password_recovery_screen.dart';
import 'package:inzynierka/screens/sign_in_screen.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_navigator_observer.dart';
import '../utils.dart';
import 'password_recovery_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  const email = 'mmarciniak299@gmail.com';
  late MockAuthService authService;
  late MockNavigatorObserver popObserver;

  buildWidget() => wrapForTesting(
    PasswordRecoveryScreen(),
    overrides: [authServiceProvider.overrideWithValue(authService)],
    observers: [popObserver],
  );

  sendEmail(WidgetTester tester) async {
    await tester.enterText(find.bySemanticsLabel('Adres email'), email);
    final buttonFinder = find.bySemanticsLabel('Wyślij instrukcje');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
  }

  setUp(() async {
    authService = MockAuthService();
    popObserver = MockNavigatorObserver();
  });

  testWidgets('Should not try to send recovery email with empty email', (tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.tap(find.bySemanticsLabel('Wyślij instrukcje'));

    verifyNever(authService.sendPasswordResetEmail(any));
  });

  testWidgets('Should send email on tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    await sendEmail(tester);

    verify(authService.sendPasswordResetEmail(email)).called(1);

    await tester.pumpAndSettle();
  });

  testWidgets('Should open sign in screen and show snackbar on success', (tester) async {
    await tester.pumpWidget(buildWidget());

    await sendEmail(tester);

    await tester.pump();

    verify(popObserver.didPop(any, any)).called(1);
    expect(find.byType(SignInScreen), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('Should close current modal and open sign up modal on sign up tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    final buttonFinder = find.textContaining('logowania');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    verify(popObserver.didPop(any, any)).called(1);
    expect(find.byType(SignInScreen), findsOneWidget);

    await tester.pumpAndSettle();
  });
}