import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:wyrzutka/providers/firebase_provider.dart';
import 'package:wyrzutka/repositories/user_repository.dart';
import 'package:mockito/mockito.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late MockUser mockUser;
  late AppUser user;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserRepository userRepository;
  late ProviderContainer container;

  createContainer() {
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
  }

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
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );
    mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);
    userRepository = MockUserRepository();
    createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Auth user should be null by default', () {
    expect(container.read(authUserProvider), isNull);
  });

  group('initialAuthUserProvider', () {
    test('Should fetch user if has logged in before', () async {
      mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      createContainer();
      when(userRepository.fetchId(any, any)).thenAnswer((realInvocation) => Future.value(user));

      await container.read(initialAuthUserProvider.future);

      verify(userRepository.fetchId(mockUser.uid, any)).called(1);
      expect(container.read(authUserProvider), equals(user));
    });

    test('Should complete if has no logged in user', () async {
      await container.read(initialAuthUserProvider.future);

      verifyNever(userRepository.fetchId(any, any));
      expect(container.read(authUserProvider), isNull);
    });
  });
}
