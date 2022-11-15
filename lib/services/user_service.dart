import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/repositories/user_repository.dart';

final userServiceProvider = Provider(UserService.new);

class UserService {
  UserService(this.ref);

  final Ref ref;

  Future<void> changeRole(AppUser user, Role role) async {
    final userRepository = ref.read(userRepositoryProvider);
    final newUser = user.copyWith(role: role);
    final updateData = {'role': role.name};
    await userRepository.update(user.id, updateData, newUser);
  }
}
