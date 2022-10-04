import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/cache_notifier.dart';

final _usersCollection = FirebaseFirestore.instance.collection('users').withConverter(
      fromFirestore: AppUser.fromFirestore,
      toFirestore: AppUser.toFirestore,
    );

typedef UserCache = CacheNotifier<AppUser>;

final _userCacheProvider =
StateNotifierProvider<UserCache, Map<String, AppUser>>((ref) => CacheNotifier<AppUser>());

final userProvider = Provider.family<AppUser?, String>((ref, id) {
  final cache = ref.watch(_userCacheProvider);
  return cache[id];
});

final userRepositoryProvider = Provider((ref) => UserRepository(ref));

class UserRepository with CacheNotifierMixin {
  UserRepository(this.ref);

  @override
  final Ref ref;

  @override
  UserCache get cache => ref.read(_userCacheProvider.notifier);

  @override
  CollectionReference<AppUser> get collection => _usersCollection;

  Future<AppUser> create(AppUser user) async {
    final doc = _usersCollection.doc(user.id.isNotEmpty ? user.id : null);
    await doc.set(user);
    return user.copyWith(id: doc.id);
  }
}