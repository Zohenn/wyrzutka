import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/repositories/query_filter.dart';
import 'package:wyrzutka/repositories/user_repository.dart';

final userServiceProvider = Provider(UserService.new);

class UserService {
  UserService(this.ref);

  final Ref ref;

  UserRepository get userRepository => ref.read(userRepositoryProvider);

  Future<void> changeRole(AppUser user, Role role) async {
    final newUser = user.copyWith(role: role);
    final updateData = {'role': role.name};
    await userRepository.update(user.id, updateData, newUser);
  }

  Future<List<AppUser>> fetchNextModeration([DocumentSnapshot? startAfterDocument]) {
    final roles = [Role.mod, Role.admin].map((e) => e.name).toList();
    return userRepository.fetchNext(
      filters: [QueryFilter('role', FilterOperator.whereIn, roles)],
      startAfterDocument: startAfterDocument,
    );
  }

  Future<List<AppUser>> fetchUsersForProduct(Product product) {
    final ids = [
      product.user,
      if(product.sort != null) product.sort!.user,
      ...product.sortProposals.values.map((e) => e.user),
    ];
    return userRepository.fetchIds(ids);
  }

  Future<List<AppUser>> search(String value) async {
    final results = await Future.wait([
      userRepository.search('searchNS', value),
      userRepository.search('searchSN', value),
    ]);
    final uniqueResults = LinkedHashSet(
      equals: (AppUser user1, AppUser user2) => user1.id == user2.id,
      hashCode: (AppUser user) => Object.hash(user.id, user.id),
    )..addAll(results.flattened);
    return uniqueResults.take(5).toList();
  }
}
