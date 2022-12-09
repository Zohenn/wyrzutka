import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/repositories/repository.dart';
import 'package:wyrzutka/providers/cache_notifier.dart';
import 'package:wyrzutka/providers/firebase_provider.dart';

const userCollectionPath = 'users';

final _userCacheProvider = createCacheProvider<AppUser>();

final userProvider = createCacheItemProvider(_userCacheProvider);
final usersProvider = createCacheItemsProvider(_userCacheProvider);

final userRepositoryProvider = Provider((ref) => UserRepository(ref));

class UserRepository extends Repository<AppUser> {
  UserRepository(this.ref);

  @override
  final Ref ref;

  @override
  CacheNotifier<AppUser> get cache => ref.read(_userCacheProvider.notifier);

  @override
  late final CollectionReference<AppUser> collection =
      ref.read(firebaseFirestoreProvider).collection(userCollectionPath).withConverter(
            fromFirestore: AppUser.fromFirestore,
            toFirestore: AppUser.toFirestore,
          );

  Future<AppUser> createAndGet(AppUser user) async {
    final docId = await create(user);
    final newUser = user.copyWith(id: docId);
    // add to cache, or exception will be thrown when app opens profile for newly signed up user
    addToCache(docId, newUser);
    return newUser;
  }
}
