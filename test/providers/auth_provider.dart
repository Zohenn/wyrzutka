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
    userRepository = MockUserRepository();
    googleSignIn = MockGoogleSignIn();
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(MockFirebaseAuth(mockUser: mockUser)),
        googleSignInProvider.overrideWithValue(googleSignIn),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
  });

  test('Auth user should be null by default', () {
    expect(container.read(authUserProvider), isNull);
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

  tearDown(() {
    container.dispose();
  });
}
