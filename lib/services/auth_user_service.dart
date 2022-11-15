import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';

final authUserServiceProvider = Provider(AuthUserService.new);

class AuthUserService {
  AuthUserService(this.ref);

  Ref ref;

  Future<void> changeInfo(String name, String surname) async {
    final authUser = ref.watch(authUserProvider)!;
    final userRepository = ref.read(userRepositoryProvider);

    final newUser = authUser.copyWith(name: name, surname: surname);

    await userRepository.update(authUser.id, {'name': name, 'surname': surname}, newUser);
    ref.read(authUserProvider.notifier).state = newUser;
  }

  Future<void> updateSavedProduct(String productId) async {
    final authUser = ref.read(authUserProvider)!;
    final userRepository = ref.read(userRepositoryProvider);

    final isSaved = authUser.savedProducts.contains(productId);
    if (!isSaved) {
      final user = await userRepository.saveProduct(authUser, productId);
      ref.read(authUserProvider.notifier).state = user;
    } else {
      final user = await userRepository.removeProduct(authUser, productId);
      ref.read(authUserProvider.notifier).state = user;
    }
  }
}
