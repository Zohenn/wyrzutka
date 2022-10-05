import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:mockito/mockito.dart';

import 'auth_provider.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late MockUser mockUser;
  late AppUser user;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserRepository userRepository;
  late MockGoogleSignIn googleSignIn;
  late ProviderContainer container;

  setUp(() async {
    mockUser = MockUser(
      uid: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      email: 'mmarciniak299@gmail.com',
      displayName: 'Michał Marciniak',
    );
    user = AppUser(
      id: 'VJHS5rQwHxh08064vjhkMhes2lS2',
      email: 'mmarciniak299@gmail.com',
      name: 'Michał',
      surname: 'Marciniak',
    );
    mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);
    userRepository = MockUserRepository();
    googleSignIn = MockGoogleSignIn();
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
        googleSignInProvider.overrideWithValue(googleSignIn),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
  });

  test('Auth user should be null by default', () {
    expect(container.read(authUserProvider), isNull);
  });

  group('signUp', () {
    test('Should create user doc', () async {
      when(userRepository.create(any))
          .thenAnswer((realInvocation) => Future.value(realInvocation.positionalArguments[0]));
      await container.read(authServiceProvider).signUp(
            name: 'Michał',
            surname: 'Marciniak',
            email: 'michal.marciniak@pollub.edu.pl',
            password: 'qwerty',
          );

      verify(userRepository.create(any)).called(1);
      expect(
        container.read(authUserProvider),
        isA<AppUser>()
            .having((u) => u.id, 'id', mockFirebaseAuth.currentUser!.uid)
            .having((u) => u.name, 'name', 'Michał')
            .having((u) => u.surname, 'surname', 'Marciniak')
            .having((u) => u.email, 'email', 'michal.marciniak@pollub.edu.pl'),
      );
    });

    test('Should update display name on user', () async {
      when(userRepository.create(any))
          .thenAnswer((realInvocation) => Future.value(realInvocation.positionalArguments[0]));
      await container.read(authServiceProvider).signUp(
            name: 'Michał',
            surname: 'Marciniak',
            email: 'michal.marciniak@pollub.edu.pl',
            password: 'qwerty',
          );

      expect(mockFirebaseAuth.currentUser!.displayName, equals('Michał Marciniak'));
    });
  });

  group('signIn', () {
    test('Should set auth user after successful sign in', () async {
      when(userRepository.fetchId(any, any)).thenAnswer((realInvocation) => Future.value(user));

      await container.read(authServiceProvider).signIn(email: 'mmarciniak299@gmail.com', password: 'qwerty');

      expect(container.read(authUserProvider), equals(user));
    });

    test('Should create userDoc if does not exist', () async {
      when(userRepository.fetchId(any, any)).thenAnswer((realInvocation) => Future.value(null));
      when(userRepository.create(any))
          .thenAnswer((realInvocation) => Future.value(realInvocation.positionalArguments[0]));

      await container.read(authServiceProvider).signIn(email: 'mmarciniak299@gmail.com', password: 'qwerty');

      verify(userRepository.create(any)).called(1);
      expect(
        container.read(authUserProvider),
        isA<AppUser>()
            .having((u) => u.id, 'id', user.id)
            .having((u) => u.email, 'email', user.email)
            .having((u) => u.name, 'name', user.name)
            .having((u) => u.surname, 'surname', user.surname),
      );
    });
  });

  group('signInWithGoogle', () {
    test('Should set auth user after successful sign in', () async {
      when(userRepository.fetchId(any, any)).thenAnswer((realInvocation) => Future.value(user));

      await container.read(authServiceProvider).signInWithGoogle();

      expect(container.read(authUserProvider), equals(user));
    });

    test('Should create userDoc if does not exist', () async {
      when(userRepository.fetchId(any, any)).thenAnswer((realInvocation) => Future.value(null));
      when(userRepository.create(any))
          .thenAnswer((realInvocation) => Future.value(realInvocation.positionalArguments[0]));

      await container.read(authServiceProvider).signInWithGoogle();

      verify(userRepository.create(any)).called(1);
      expect(
        container.read(authUserProvider),
        isA<AppUser>()
            .having((u) => u.id, 'id', user.id)
            .having((u) => u.email, 'email', user.email)
            .having((u) => u.name, 'name', user.name)
            .having((u) => u.surname, 'surname', user.surname),
      );
    });

    test('Should not throw if sign in is cancelled', () async {
      googleSignIn.setIsCancelled(true);

      await expectLater(container.read(authServiceProvider).signInWithGoogle(), completes);
    });
  });

  group('signOut', () {
    setUp(() async {
      when(userRepository.fetchId(any, any)).thenAnswer((realInvocation) => Future.value(user));
      await container.read(authServiceProvider).signIn(email: 'mmarciniak299@gmail.com', password: 'qwerty');
      // just for checking that the state is correct
      assert(mockFirebaseAuth.currentUser != null && container.read(authUserProvider) != null);
    });

    test('Should sign out from firebase', () async {
      await container.read(authServiceProvider).signOut();

      expect(mockFirebaseAuth.currentUser, isNull);
    });

    test('Should set auth user to null', () async {
      await container.read(authServiceProvider).signOut();

      expect(container.read(authUserProvider), isNull);
    });
  });

  tearDown(() {
    container.dispose();
  });
}
