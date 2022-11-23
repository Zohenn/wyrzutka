import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/screens/password_recovery_screen.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';
import 'password_recovery_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  const email = 'mmarciniak299@gmail.com';
  late MockAuthService authService;

  buildWidget() => wrapForTesting(
    PasswordRecoveryScreen(),
    overrides: [authServiceProvider.overrideWithValue(authService)],
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
  });

  testWidgets('Should not try to send recovery email with empty email', (tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.tap(find.bySemanticsLabel('Wyślij instrukcje'));

    verifyNever(authService.sendPasswordResetEmail(any));
  });

  testWidgets('Should send email on tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    await sendEmail(tester);
    await tester.pumpAndSettle();

    verify(authService.sendPasswordResetEmail(email)).called(1);
  });

  testWidgets('Should show snackbar on success', (tester) async {
    await tester.pumpWidget(buildWidget());

    await sendEmail(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('Wiadomość wysłana'), findsOneWidget);
  });

  testWidgets('Should show snackbar on error', (tester) async {
    when(authService.sendPasswordResetEmail(any)).thenAnswer((realInvocation) => Future.error(Error()));
    await tester.pumpWidget(buildWidget());

    await sendEmail(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('błąd'), findsOneWidget);
  });

  testWidgets('Should not close modal on error', (tester) async {
    when(authService.sendPasswordResetEmail(any)).thenAnswer((realInvocation) => Future.error(Error()));
    await tester.pumpWidget(buildWidget());

    await sendEmail(tester);
    await tester.pumpAndSettle();

    expect(find.text('Wyślij instrukcje'), findsOneWidget);
  });

  testWidgets('Should close current modal and open sign in screen on success', (tester) async {
    await tester.pumpWidget(buildWidget());

    await sendEmail(tester);
    await tester.pumpAndSettle();

    expect(find.text('Wyślij instrukcje'), findsNothing);
    expect(find.text('Zaloguj się'), findsOneWidget);
  });

  testWidgets('Should close current modal and open sign in modal on sign in tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    final buttonFinder = find.textContaining('logowania');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Wyślij instrukcje'), findsNothing);
    expect(find.text('Zaloguj się'), findsOneWidget);
  });
}