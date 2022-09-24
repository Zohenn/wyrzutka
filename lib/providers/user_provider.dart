import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user.dart';

final _usersCollection = FirebaseFirestore.instance.collection('users').withConverter(
      fromFirestore: AppUser.fromFirestore,
      toFirestore: AppUser.toFirestore,
    );

final userRepositoryProvider = Provider((ref) => UserRepository());

class UserRepository {
  final Map<String, AppUser> cache = {};

  Future<AppUser?> fetchId(String id, [bool skipCache = false]) async {
    if (!skipCache && cache[id] != null) {
      return cache[id];
    }
    final snapshot = await _usersCollection.doc(id).get();
    final user = snapshot.data();
    _addToCache(user);
    return user;
  }

  Future<AppUser> create(AppUser user) async {
    final doc = _usersCollection.doc();
    await doc.set(user);
    return user.copyWith(id: doc.id);
  }

  void _addToCache(AppUser? user) {
    if (user != null) {
      cache[user.id] = user;
    }
  }
}