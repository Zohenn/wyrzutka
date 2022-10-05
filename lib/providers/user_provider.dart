import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/cache_notifier.dart';
import 'package:inzynierka/providers/firebase_provider.dart';

const userCollectionPath = 'users';

final _userCacheProvider = createCacheProvider<AppUser>();

final userProvider = createCacheItemProvider(_userCacheProvider);

final userRepositoryProvider = Provider((ref) => UserRepository(ref));

class UserRepository with CacheNotifierMixin {
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

  Future<AppUser> create(AppUser user) async {
    final doc = collection.doc(user.id.isNotEmpty ? user.id : null);
    await doc.set(user);
    return user.copyWith(id: doc.id);
  }
}
