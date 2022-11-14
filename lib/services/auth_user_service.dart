import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';

final authUserServiceProvider = Provider(AuthUserService.new);

class AuthUserService {
  AuthUserService(this.ref);

  Ref ref;

  AppUser get authUser => ref.read(authUserProvider)!;

  Future<void> updateSavedProduct(String productId) async {
    final isSaved = authUser.savedProducts.contains(productId);
    late AppUser newUser;
    if (!isSaved) {
      newUser = await _saveProduct(productId);
    } else {
      newUser = await _removeSavedProduct(productId);
    }
    ref.read(authUserProvider.notifier).state = newUser;
  }

  Future<AppUser> _saveProduct(String productId) async {
    final userRepository = ref.read(userRepositoryProvider);
    final newUser = authUser.copyWith(savedProducts: [...authUser.savedProducts, productId]);
    await userRepository.update(
      authUser.id,
      {
        'savedProducts': FieldValue.arrayUnion([productId])
      },
      newUser,
    );
    return newUser;
  }

  Future<AppUser> _removeSavedProduct(String productId) async {
    final userRepository = ref.read(userRepositoryProvider);
    final newUser = authUser.copyWith(savedProducts: [...authUser.savedProducts]..remove(productId));
    await userRepository.update(
      authUser.id,
      {
        'savedProducts': FieldValue.arrayRemove([productId])
      },
      newUser,
    );
    return newUser;
  }
}
