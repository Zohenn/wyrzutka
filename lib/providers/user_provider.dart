import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/base_repository.dart';
import 'package:inzynierka/providers/cache_notifier.dart';
import 'package:inzynierka/providers/firebase_provider.dart';

const userCollectionPath = 'users';

final _userCacheProvider = createCacheProvider<AppUser>();

final userProvider = createCacheItemProvider(_userCacheProvider);

final userRepositoryProvider = Provider((ref) => UserRepository(ref));

class UserRepository extends BaseRepository<AppUser> {
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

  String? getId(AppUser item) => item.id.isNotEmpty ? item.id : null;

  Future<AppUser> createAndGet(AppUser user) async {
    final docId = await create(user);
    return user.copyWith(id: docId);
  }

  Future<AppUser> saveProduct(AppUser user, String product) async {
    final userDoc = collection.doc(user.id);
    await userDoc.update({
      'savedProducts': FieldValue.arrayUnion([product]),
    });
    return user.copyWith(savedProducts: [...user.savedProducts, product]);
  }

  Future<AppUser> removeProduct(AppUser user, String product) async {
    final userDoc = collection.doc(user.id);
    await userDoc.update({
      'savedProducts': FieldValue.arrayRemove([product]),
    });
    return user.copyWith(savedProducts: [...user.savedProducts]..remove(product));
  }
}
