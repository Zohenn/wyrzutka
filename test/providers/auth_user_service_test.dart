import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/auth_user_service.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([UserRepository])
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
      savedProducts: ['1', '2']
    );
    mockUserRepository = MockUserRepository();
    when(mockUserRepository.saveProduct(any, any)).thenAnswer((realInvocation) => Future.value((realInvocation.positionalArguments[0] as AppUser).copyWith()));
    when(mockUserRepository.removeProduct(any, any)).thenAnswer((realInvocation) => Future.value((realInvocation.positionalArguments[0] as AppUser).copyWith()));
    createContainer();
    authUserService = container.read(authUserServiceProvider);
  });

  group('updateSavedProduct', () {
    const newProduct = '3';
    const deletedProduct = '1';

    test('Should add product if not on list', () async {
      await authUserService.updateSavedProduct(newProduct);

      verify(mockUserRepository.saveProduct(authUser, newProduct)).called(1);
      expect(container.read(authUserProvider.notifier), isNot(authUser));
    });

    test('Should remove product if on list', () async {
      await authUserService.updateSavedProduct(deletedProduct);

      verify(mockUserRepository.removeProduct(authUser, deletedProduct)).called(1);
      expect(container.read(authUserProvider.notifier), isNot(authUser));
    });
  });
}
