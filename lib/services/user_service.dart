import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/repositories/query_filter.dart';
import 'package:inzynierka/repositories/user_repository.dart';

final userServiceProvider = Provider(UserService.new);

class UserService {
  UserService(this.ref);

  Ref ref;

  Future<List<AppUser>> fetchNextModeration([DocumentSnapshot? startAfterDocument]) {
    final userRepository = ref.read(userRepositoryProvider);
    final roles = [Role.mod, Role.admin].map((e) => e.name).toList();
    return userRepository.fetchNext(
      filters: [QueryFilter('role', FilterOperator.whereIn, roles)],
      startAfterDocument: startAfterDocument,
    );
  }

  Future<List<AppUser>> search(String value) async {
    final userRepository = ref.read(userRepositoryProvider);
    final results = await Future.wait([
      userRepository.search('searchNS', value),
      userRepository.search('searchSN', value),
    ]);
    final uniqueResults = LinkedHashSet(
      equals: (AppUser user1, AppUser user2) => user1.id == user2.id,
      hashCode: (AppUser user) => Object.hash(user.id, user.id),
    )..addAll(results.flattened);
    return uniqueResults.toList();
  }
}
