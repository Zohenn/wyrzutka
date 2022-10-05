import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/cache_notifier.dart';

final _usersCollection = FirebaseFirestore.instance.collection('users').withConverter(
      fromFirestore: AppUser.fromFirestore,
      toFirestore: AppUser.toFirestore,
    );

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
  CollectionReference<AppUser> get collection => _usersCollection;

  Future<AppUser> create(AppUser user) async {
    final doc = _usersCollection.doc(user.id.isNotEmpty ? user.id : null);
    await doc.set(user);
    return user.copyWith(id: doc.id);
  }

  Future<AppUser> saveProduct(AppUser user, String product) async {
    final userDoc = _usersCollection.doc(user.id);
    userDoc.update({
      'savedProducts': FieldValue.arrayUnion([product]),
    });
    return user.copyWith(savedProducts: [...user.savedProducts, product]);
  }

  Future<AppUser> removeProduct(AppUser user, String product) async {
    final userDoc = _usersCollection.doc(user.id);
    userDoc.update({
      'savedProducts': FieldValue.arrayRemove([product]),
    });
    return user.copyWith(savedProducts: [...user.savedProducts]..remove(product));
  }
}
