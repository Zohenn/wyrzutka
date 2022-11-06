import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';

final authUserServiceProvider = Provider(AuthUserService.new);

class AuthUserService {
  AuthUserService(this.ref);

  Ref ref;

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