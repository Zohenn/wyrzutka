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

  group('saveProduct', () {
    late AppUser user;
    const productId = '3';

    setUp(() async {
      user = AppUser(
        id: '1',
        email: 'mmarciniak299@gmail.com',
        name: 'Michał',
        surname: 'Marciniak',
        role: Role.user,
        signUpDate: FirestoreDateTime.serverTimestamp(),
        savedProducts: ['1', '2'],
      );
      await repository.collection.doc(user.id).set(user);
    });

    test('Should add new product to saved list', () async {
      await repository.saveProduct(user, productId);

      final savedUser = (await repository.collection.doc(user.id).get()).data();

      expect(
        savedUser,
        isA<AppUser>()
            .having((o) => o.email, 'email', user.email)
            .having((o) => o.name, 'name', user.name)
            .having((o) => o.surname, 'surname', user.surname)
            .having((o) => o.role, 'role', Role.user)
            .having((o) => o.savedProducts, 'savedProducts', [...user.savedProducts, productId]),
      );
    });

    test('Should return user with updated savedProducts list', () async {
      final updatedUser = await repository.saveProduct(user, productId);

      expect(
        updatedUser,
        isA<AppUser>()
            .having((o) => o.id, 'id', user.id)
            .having((o) => o.email, 'email', user.email)
            .having((o) => o.name, 'name', user.name)
            .having((o) => o.surname, 'surname', user.surname)
            .having((o) => o.role, 'role', Role.user)
            .having((o) => o.savedProducts, 'savedProducts', [...user.savedProducts, productId]),
      );
    });
  });

  group('removeProduct', () {
    const productId = '1';
    late AppUser user;
    late List<String> targetList;

    setUp(() async {
      user = AppUser(
        id: '1',
        email: 'mmarciniak299@gmail.com',
        name: 'Michał',
        surname: 'Marciniak',
        role: Role.user,
        signUpDate: FirestoreDateTime.serverTimestamp(),
        savedProducts: ['1', '2'],
      );
      targetList = [...user.savedProducts]..remove(productId);
      await repository.collection.doc(user.id).set(user);
    });

    test('Should remove product from saved list', () async {
      await repository.removeProduct(user, productId);

      final savedUser = (await repository.collection.doc(user.id).get()).data();

      expect(
        savedUser,
        isA<AppUser>()
            .having((o) => o.email, 'email', user.email)
            .having((o) => o.name, 'name', user.name)
            .having((o) => o.surname, 'surname', user.surname)
            .having((o) => o.role, 'role', Role.user)
            .having((o) => o.savedProducts, 'savedProducts', targetList),
      );
    });

    test('Should return user with updated savedProducts list', () async {
      final updatedUser = await repository.removeProduct(user, productId);

      expect(
        updatedUser,
        isA<AppUser>()
            .having((o) => o.id, 'id', user.id)
            .having((o) => o.email, 'email', user.email)
            .having((o) => o.name, 'name', user.name)
            .having((o) => o.surname, 'surname', user.surname)
            .having((o) => o.role, 'role', Role.user)
            .having((o) => o.savedProducts, 'savedProducts', targetList),
      );
    });
  });
}
