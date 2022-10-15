import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/password_recovery_screen.dart';
import 'package:inzynierka/screens/sign_in_screen.dart';
import 'package:inzynierka/screens/sign_up_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_navigator_observer.dart';
import '../utils.dart';
import 'sign_in_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService authService;
  late MockNavigatorObserver popObserver;
  late AppUser user;
  String email = 'foo@bar.com';
  String password = 'qwerty';

  buildWidget() => wrapForTesting(
        SignInScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
        observers: [popObserver],
      );

  signIn(WidgetTester tester) async {
    await tester.enterText(find.bySemanticsLabel('Adres email'), email);
    await tester.enterText(find.bySemanticsLabel('Hasło'), password);
    await tester.tap(find.bySemanticsLabel('Zaloguj się'));
  }

  signInWithGoogle(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Zaloguj się przez Google'));
  }

  setUp(() async {
    authService = MockAuthService();
    popObserver = MockNavigatorObserver();
    user = AppUser(
      id: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      email: 'mmarciniak299@gmail.com',
      name: 'Michał',
      surname: 'Marciniak',
    );
    when(authService.signIn(email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((realInvocation) => Future.value(user));
    when(authService.signInWithGoogle()).thenAnswer((realInvocation) => Future.value(user));
  });

  group('email password sign in', () {
    testWidgets('Should not try to sign in with empty email', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.bySemanticsLabel('Hasło'), password);
      await tester.tap(find.bySemanticsLabel('Zaloguj się'));

      verifyNever(authService.signIn(email: anyNamed('email'), password: anyNamed('password')));
    });

    testWidgets('Should not try to sign in with empty password', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.bySemanticsLabel('Adres email'), email);
      await tester.tap(find.bySemanticsLabel('Zaloguj się'));

      verifyNever(authService.signIn(email: anyNamed('email'), password: anyNamed('password')));
    });

    testWidgets('Should sign in on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signIn(tester);

      verify(authService.signIn(email: email, password: password)).called(1);
    });

    testWidgets('Should close modal after successful sign in', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signIn(tester);

      verify(popObserver.didPop(any, any)).called(1);
    });

    testWidgets('Should show error message on sign in error', (tester) async {
      when(authService.signIn(email: anyNamed('email'), password: anyNamed('password'))).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signIn(tester);

      await tester.pump();

      expect(find.textContaining('Błąd'), findsOneWidget);
    });

    testWidgets('Should not close modal on sign in error', (tester) async {
      when(authService.signIn(email: anyNamed('email'), password: anyNamed('password'))).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signIn(tester);

      verifyNever(popObserver.didPop(any, any));
    });

    testWidgets('Should show loading indicator during sign in process', (tester) async {
      final completer = Completer<AppUser>();
      when(authService.signIn(email: anyNamed('email'), password: anyNamed('password'))).thenAnswer((realInvocation) => completer.future);
      await tester.pumpWidget(buildWidget());

      await signIn(tester);
      await tester.pump();

      expect(find.bySemanticsLabel('Zaloguj się'), findsNothing);
      expect(find.bySemanticsLabel('Ładowanie'), findsOneWidget);

      completer.complete(user);
      await tester.pump();

      expect(find.bySemanticsLabel('Zaloguj się'), findsOneWidget);
      expect(find.bySemanticsLabel('Ładowanie'), findsNothing);
    });
  });

  group('google sign in', () {
    testWidgets('Should sign in with google on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verify(authService.signInWithGoogle()).called(1);
    });

    testWidgets('Should close modal after successful sign in', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verify(popObserver.didPop(any, any)).called(1);
    });

    testWidgets('Should not close modal after sign in cancel', (tester) async {
      when(authService.signInWithGoogle()).thenAnswer((realInvocation) => Future.value(null));
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verifyNever(popObserver.didPop(any, any));
    });

    testWidgets('Should show error message on sign in error', (tester) async {
      when(authService.signInWithGoogle()).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      await tester.pump();

      expect(find.textContaining('Błąd'), findsOneWidget);
    });

    testWidgets('Should not close modal on sign in error', (tester) async {
      when(authService.signInWithGoogle()).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verifyNever(popObserver.didPop(any, any));
    });

    testWidgets('Should show loading indicator during sign in process', (tester) async {
      final completer = Completer<AppUser>();
      when(authService.signInWithGoogle()).thenAnswer((realInvocation) => completer.future);
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);
      await tester.pump();

      expect(find.bySemanticsLabel('Zaloguj się przez Google'), findsNothing);
      expect(find.bySemanticsLabel('Ładowanie'), findsOneWidget);

      completer.complete(user);
      await tester.pump();

      expect(find.bySemanticsLabel('Zaloguj się przez Google'), findsOneWidget);
      expect(find.bySemanticsLabel('Ładowanie'), findsNothing);
    });
  });

  testWidgets('Should close current modal and open password recovery modal on password recovery tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    await tester.tap(find.textContaining('Zapomniałeś hasła'));
    await tester.pumpAndSettle();

    verify(popObserver.didPop(any, any)).called(1);
    expect(find.byType(PasswordRecoveryScreen), findsOneWidget);
  });

  testWidgets('Should close current modal and open sign up modal on sign up tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    final buttonFinder = find.textContaining('Zarejestruj się');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    textSpanOnTap(buttonFinder, 'Zarejestruj się');
    await tester.pumpAndSettle();

    verify(popObserver.didPop(any, any)).called(1);
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
