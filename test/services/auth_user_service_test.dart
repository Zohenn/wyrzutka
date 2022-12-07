import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:wyrzutka/services/auth_user_service.dart';
import 'package:wyrzutka/repositories/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../providers/auth_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
void main() {
  late AppUser authUser;
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;
  late AuthUserService authUserService;

  createContainer() {
    container = ProviderContainer(
      overrides: [
        authUserProvider.overrideWith((ref) => authUser),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  }

  setUp(() {
    authUser = AppUser(
        id: 'id',
        email: 'email',
        name: 'name',
        surname: 'surname',
        role: Role.user,
        signUpDate: FirestoreDateTime.serverTimestamp(),
        savedProducts: ['1', '2']);
    mockUserRepository = MockUserRepository();
    createContainer();
    authUserService = container.read(authUserServiceProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('updateSavedProduct', () {
    const newProduct = '3';
    const deletedProduct = '1';

    test('Should add product if not on list', () async {
      await authUserService.updateSavedProduct(newProduct);

      final verification = verify(mockUserRepository.update(authUser.id, captureAny, captureAny));
      verification.called(1);
      final updateData = verification.captured[0];
      final newUser = verification.captured[1];
      expect(updateData, {
        'savedProducts': FieldValue.arrayUnion([newProduct])
      });
      expect(
          newUser,
          isA<AppUser>()
              .having((o) => o.savedProducts, 'savedProducts', containsAll([...authUser.savedProducts, newProduct])));
      expect(container.read(authUserProvider.notifier), isNot(authUser));
    });

    test('Should remove product if on list', () async {
      await authUserService.updateSavedProduct(deletedProduct);

      final verification = verify(mockUserRepository.update(authUser.id, captureAny, captureAny));
      verification.called(1);
      final updateData = verification.captured[0];
      final newUser = verification.captured[1];
      expect(updateData, {
        'savedProducts': FieldValue.arrayRemove([deletedProduct])
      });
      expect(
          newUser,
          isA<AppUser>().having((o) => o.savedProducts, 'savedProducts',
              containsAll([...authUser.savedProducts]..remove(deletedProduct))));
      expect(container.read(authUserProvider.notifier), isNot(authUser));
    });
  });

  group('changeInfo', () {
    const name = 'Wojciech';
    const surname = 'Brandeburg';

    test('Should update user name and surname', () async {
      await authUserService.changeInfo(name, surname);

      final verification = verify(mockUserRepository.update(authUser.id, captureAny, captureAny));
      verification.called(1);
      final updateData = verification.captured[0];
      final newUser = verification.captured[1];

      expect(updateData.containsKey('name'), true);
      expect(updateData['name'], name);

      expect(updateData.containsKey('surname'), true);
      expect(updateData['surname'], surname);

      expect(
        newUser,
        isA<AppUser>().having((o) => o.name, 'name', name).having((o) => o.surname, 'surname', surname),
      );
      expect(container.read(authUserProvider.notifier), isNot(authUser));
    });
  });
}
