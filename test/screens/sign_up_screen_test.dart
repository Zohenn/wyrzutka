import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/screens/sign_in_screen.dart';
import 'package:inzynierka/screens/sign_up_screen.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_navigator_observer.dart';
import '../utils.dart';
import 'sign_up_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService authService;
  late MockNavigatorObserver popObserver;
  late AppUser user;
  String name = 'Michał';
  String surname = 'Marciniak';
  String email = 'foo@bar.com';
  String password = 'qwerty';

  buildWidget() => wrapForTesting(
        SignUpScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
        observers: [popObserver],
      );

  anySignUp() => authService.signUp(
      name: anyNamed('name'), surname: anyNamed('surname'), email: anyNamed('email'), password: anyNamed('password'));

  signUp(WidgetTester tester) async {
    await tester.enterText(find.bySemanticsLabel('Imię'), name);
    await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);
    await tester.enterText(find.bySemanticsLabel('Adres email'), email);
    await tester.enterText(find.bySemanticsLabel('Hasło'), password);
    await tester.tap(find.bySemanticsLabel('Zarejestruj się'));
  }

  signInWithGoogle(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Dołącz przez Google'));
  }

  setUp(() async {
    authService = MockAuthService();
    popObserver = MockNavigatorObserver();
    user = AppUser(
      id: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      email: 'mmarciniak299@gmail.com',
      name: 'Michał',
      surname: 'Marciniak',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );
    when(anySignUp()).thenAnswer((realInvocation) => Future.value(user));
    when(authService.signInWithGoogle()).thenAnswer((realInvocation) => Future.value(user));
  });

  group('email password sign up', () {
    testWidgets('Should not try to sign up with empty name', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);
      await tester.enterText(find.bySemanticsLabel('Hasło'), password);
      await tester.enterText(find.bySemanticsLabel('Adres email'), email);
      await tester.tap(find.bySemanticsLabel('Zarejestruj się'));

      verifyNever(anySignUp());
    });

    testWidgets('Should not try to sign up with empty surname', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.bySemanticsLabel('Imię'), name);
      await tester.enterText(find.bySemanticsLabel('Hasło'), password);
      await tester.enterText(find.bySemanticsLabel('Adres email'), email);
      await tester.tap(find.bySemanticsLabel('Zarejestruj się'));

      verifyNever(anySignUp());
    });

    testWidgets('Should not try to sign up with empty email', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.bySemanticsLabel('Imię'), name);
      await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);
      await tester.enterText(find.bySemanticsLabel('Hasło'), password);
      await tester.tap(find.bySemanticsLabel('Zarejestruj się'));

      verifyNever(anySignUp());
    });

    testWidgets('Should not try to sign up with empty password', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.bySemanticsLabel('Imię'), name);
      await tester.enterText(find.bySemanticsLabel('Nazwisko'), surname);
      await tester.enterText(find.bySemanticsLabel('Adres email'), email);
      await tester.tap(find.bySemanticsLabel('Zarejestruj się'));

      verifyNever(anySignUp());
    });

    testWidgets('Should sign up on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signUp(tester);

      verify(authService.signUp(name: name, surname: surname, email: email, password: password)).called(1);
    });

    testWidgets('Should close modal after successful sign up', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signUp(tester);

      verify(popObserver.didPop(any, any)).called(1);
    });

    testWidgets('Should show error message on sign up error', (tester) async {
      when(anySignUp()).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signUp(tester);

      await tester.pump();

      expect(find.textContaining('Błąd'), findsOneWidget);
    });

    testWidgets('Should not close modal on sign in error', (tester) async {
      when(anySignUp()).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signUp(tester);

      verifyNever(popObserver.didPop(any, any));
    });

    testWidgets('Should show loading indicator during sign up process', (tester) async {
      final completer = Completer<AppUser>();
      when(anySignUp()).thenAnswer((realInvocation) => completer.future);
      await tester.pumpWidget(buildWidget());

      await signUp(tester);
      await tester.pump();

      expect(find.bySemanticsLabel('Zarejestruj się'), findsNothing);
      expect(find.bySemanticsLabel('Ładowanie'), findsOneWidget);

      completer.complete(user);
      await tester.pump();

      expect(find.bySemanticsLabel('Zarejestruj się'), findsOneWidget);
      expect(find.bySemanticsLabel('Ładowanie'), findsNothing);
    });
  });

  group('google sign in', () {
    testWidgets('Should sign up with google on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verify(authService.signInWithGoogle()).called(1);
    });

    testWidgets('Should close modal after successful sign up', (tester) async {
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verify(popObserver.didPop(any, any)).called(1);
    });

    testWidgets('Should not close modal after sign up cancel', (tester) async {
      when(authService.signInWithGoogle()).thenAnswer((realInvocation) => Future.value(null));
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verifyNever(popObserver.didPop(any, any));
    });

    testWidgets('Should show error message on sign up error', (tester) async {
      when(authService.signInWithGoogle()).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      await tester.pump();

      expect(find.textContaining('Błąd'), findsOneWidget);
    });

    testWidgets('Should not close modal on sign up error', (tester) async {
      when(authService.signInWithGoogle()).thenThrow(Error());
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);

      verifyNever(popObserver.didPop(any, any));
    });

    testWidgets('Should show loading indicator during sign up process', (tester) async {
      final completer = Completer<AppUser>();
      when(authService.signInWithGoogle()).thenAnswer((realInvocation) => completer.future);
      await tester.pumpWidget(buildWidget());

      await signInWithGoogle(tester);
      await tester.pump();

      expect(find.bySemanticsLabel('Dołącz przez Google'), findsNothing);
      expect(find.bySemanticsLabel('Ładowanie'), findsOneWidget);

      completer.complete(user);
      await tester.pump();

      expect(find.bySemanticsLabel('Dołącz przez Google'), findsOneWidget);
      expect(find.bySemanticsLabel('Ładowanie'), findsNothing);
    });
  });

  testWidgets('Should close current modal and open sign in modal on sign in tap', (tester) async {
    await tester.pumpWidget(buildWidget());

    final buttonFinder = find.textContaining('Zaloguj się');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    textSpanOnTap(buttonFinder, 'Zaloguj się');
    await tester.pumpAndSettle();

    verify(popObserver.didPop(any, any)).called(1);
    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
