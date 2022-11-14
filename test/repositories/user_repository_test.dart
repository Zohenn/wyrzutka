import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;
  late UserRepository repository;

  createContainer() {
    container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
      ],
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    createContainer();
    repository = container.read(userRepositoryProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('createAndGet', () {
    late AppUser user;

    setUp(() {
      user = AppUser(
        id: '',
        email: 'mmarciniak299@gmail.com',
        name: 'Michał',
        surname: 'Marciniak',
        role: Role.user,
        signUpDate: FirestoreDateTime.serverTimestamp(),
      );
    });

    test('Should update id on returned user', () async {
      final newUser = await repository.createAndGet(user);

      expect(newUser.id, isNotEmpty);
    });

    test('Should save user', () async {
      final newUser = await repository.createAndGet(user);

      final savedUser = (await repository.collection.doc(newUser.id).get()).data();

      expect(
        savedUser,
        isA<AppUser>()
            .having((o) => o.email, 'email', user.email)
            .having((o) => o.name, 'name', user.name)
            .having((o) => o.surname, 'surname', user.surname)
            .having((o) => o.role, 'role', Role.user),
      );
    });
  });
}
