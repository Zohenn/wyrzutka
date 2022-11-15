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

  UserRepository get userRepository => ref.read(userRepositoryProvider);

  Future<void> changeInfo(String name, String surname) async {
    final newUser = authUser.copyWith(name: name, surname: surname);

    final userData = AppUser.toFirestore(newUser, SetOptions(merge: true))
      ..removeWhere((key, value) => !['name', 'surname', 'searchNS', 'searchSN'].contains(key));

    await userRepository.update(authUser.id, userData, newUser);
    ref.read(authUserProvider.notifier).state = newUser;
  }

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
